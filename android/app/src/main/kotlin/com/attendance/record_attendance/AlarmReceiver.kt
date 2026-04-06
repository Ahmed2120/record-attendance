package com.attendance.record_attendance

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.attendance.record_attendance.NotificationConstants as Const

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val type = intent.getStringExtra(Const.EXTRA_TYPE) ?: return
        val offset = intent.getIntExtra("offset", 0)
        
        // Check if we should skip (e.g. already checked in)
        val prefs = context.getSharedPreferences(Const.PREFS_NAME, Context.MODE_PRIVATE)
        val isCheckedIn = prefs.getBoolean(Const.PREF_IS_CHECKED_IN, false)
        
        if (type == Const.TYPE_CHECK_IN && isCheckedIn) return
        if (type == Const.`TYPE_CHECK_OUT` && !isCheckedIn) return
        // Also check if already checked out today? We'll need another flag.
        val isCheckedOut = prefs.getBoolean("flutter.is_checked_out", false)
        if (type == Const.TYPE_CHECK_OUT && isCheckedOut) return

        showNotification(context, type, offset)
    }

    private fun showNotification(context: Context, type: String, offset: Int) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(Const.CHANNEL_ID, Const.CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
                description = Const.CHANNEL_DESC
            }
            notificationManager.createNotificationChannel(channel)
        }

        val isCheckIn = type == Const.TYPE_CHECK_IN
        val titleRes = when (offset) {
            30 -> if (isCheckIn) R.string.check_in_reminder_30 else R.string.check_out_reminder_30
            15 -> if (isCheckIn) R.string.check_in_reminder_15 else R.string.check_out_reminder_15
            else -> if (isCheckIn) R.string.check_in_reminder_time else R.string.check_out_reminder_time
        }

        val actionIntent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = if (isCheckIn) Const.ACTION_CHECK_IN else Const.ACTION_CHECK_OUT
            putExtra(Const.EXTRA_TYPE, type)
        }
        
        val actionPendingIntent = PendingIntent.getBroadcast(
            context, 
            if (isCheckIn) 1 else 2, 
            actionIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val actionText = context.getString(if (isCheckIn) R.string.check_in else R.string.check_out)
        
        val builder = NotificationCompat.Builder(context, Const.CHANNEL_ID)
            .setSmallIcon(R.drawable.launch_background) // Placeholder icon
            .setContentTitle(context.getString(titleRes))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setOngoing(true)
            .setAutoCancel(false)
            .setTimeoutAfter(3600000) // 1 hour in milliseconds
            .addAction(R.drawable.launch_background, actionText, actionPendingIntent)

        notificationManager.notify(if (isCheckIn) Const.NOTIFICATION_ID_CHECK_IN else Const.NOTIFICATION_ID_CHECK_OUT, builder.build())
        
        // Schedule auto-dismissal after 1 hour if not acted upon
        // We'll handle this in NotificationActionReceiver or a deferred task.
    }
}
