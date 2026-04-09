package com.attendance.record_attendance

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import androidx.core.content.ContextCompat
import com.attendance.record_attendance.NotificationConstants as Const
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val type = intent.getStringExtra(Const.EXTRA_TYPE) ?: ""
        
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Dismiss the notification immediately upon action
        val notificationId = if (type == Const.TYPE_CHECK_IN) Const.NOTIFICATION_ID_CHECK_IN else Const.NOTIFICATION_ID_CHECK_OUT
        notificationManager.cancel(notificationId)
        
        // Background DB Recording
        try {
            recordToDatabase(context, action)
            // Optional: Show a small success notification or update the existing one
            updateNotificationToSuccess(context, type)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        // Update state in SharedPreferences for Flutter UI sync
        val prefs = context.getSharedPreferences(Const.PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        if (action == Const.ACTION_CHECK_IN) {
            editor.putBoolean(Const.PREF_IS_CHECKED_IN, true)
            editor.putBoolean("flutter.is_checked_out", false) // Reset checkout state
            editor.remove("flutter.pending_native_check_in") // No longer needed as a flag for Flutter wakeup
        } else if (action == Const.ACTION_CHECK_OUT) {
            editor.putBoolean(Const.PREF_IS_CHECKED_IN, false)
            editor.putBoolean("flutter.is_checked_out", true)
            editor.remove("flutter.pending_native_check_out")
        }
        editor.apply()
        
        // Removed context.startActivity(launchIntent) to keep it background-only as requested
    }

    private fun updateNotificationToSuccess(context: Context, type: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationId = if (type == Const.TYPE_CHECK_IN) Const.NOTIFICATION_ID_CHECK_IN else Const.NOTIFICATION_ID_CHECK_OUT
        
        val builder = androidx.core.app.NotificationCompat.Builder(context, Const.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher)
            .setColor(ContextCompat.getColor(context, R.color.notification_color))
            .setContentTitle("Success")
            .setContentText(if (type == Const.TYPE_CHECK_IN) "Check-in recorded" else "Check-out recorded")
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .setTimeoutAfter(3000) // Dismiss after 3 seconds
            
        notificationManager.notify(notificationId + 100, builder.build())
    }

    private fun recordToDatabase(context: Context, action: String) {
        // Use a more robust way to get the database path
        val dbFile = context.getDatabasePath("attendance.db")
        val dbPath = if (dbFile.exists()) {
            dbFile.absolutePath
        } else {
            // Fallback to the known Flutter path if getDatabasePath fails to find it
            File(context.filesDir.parentFile, "app_flutter/attendance.db").absolutePath
        }
        
        val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)
        
        val now = Date()
        val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
        val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(now)
        val nowStr = isoFormat.format(now)
        
        val prefs = context.getSharedPreferences(Const.PREFS_NAME, Context.MODE_PRIVATE)

        try {
            if (action == Const.ACTION_CHECK_IN) {
                // Check if already checked in today to avoid duplicates
                val cursor = db.query("attendance", null, "check_in LIKE ?", arrayOf("$todayStr%"), null, null, null)
                val alreadyExists = cursor.count > 0
                cursor.close()

                if (!alreadyExists) {
                    val targetHour = prefs.getInt("flutter.check_in_hour", 9)
                    val targetMin = prefs.getInt("flutter.check_in_minute", 0)
                    
                    val calendar = Calendar.getInstance()
                    calendar.time = now
                    val currentHour = calendar.get(Calendar.HOUR_OF_DAY)
                    val currentMin = calendar.get(Calendar.MINUTE)
                    
                    var lateMinutes = 0
                    if (currentHour > targetHour || (currentHour == targetHour && currentMin > targetMin)) {
                        lateMinutes = (currentHour - targetHour) * 60 + (currentMin - targetMin)
                    }

                    val values = ContentValues().apply {
                        put("check_in", nowStr)
                        put("late_minutes", lateMinutes)
                        put("notes", "")
                    }
                    db.insert("attendance", null, values)
                }
            } else if (action == Const.ACTION_CHECK_OUT) {
                // Find today's record that hasn't been checked out yet
                val cursor = db.query("attendance", null, "check_in LIKE ? AND check_out IS NULL", arrayOf("$todayStr%"), null, null, "id DESC", "1")
                if (cursor.moveToFirst()) {
                    val id = cursor.getInt(cursor.getColumnIndexOrThrow("id"))
                    val checkInStr = cursor.getString(cursor.getColumnIndexOrThrow("check_in"))
                    
                    val checkInDate = isoFormat.parse(checkInStr)
                    if (checkInDate != null) {
                        val diffMs = now.time - checkInDate.time
                        val workingMinutes = (diffMs / (1000 * 60)).toInt()
                        
                        val values = ContentValues().apply {
                            put("check_out", nowStr)
                            put("working_minutes", workingMinutes)
                        }
                        db.update("attendance", values, "id = ?", arrayOf(id.toString()))
                    }
                }
                cursor.close()
            }
        } finally {
            db.close()
        }
    }
}
