package com.attendance.record_attendance

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.attendance.record_attendance.NotificationConstants as Const
import java.util.Calendar

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            rescheduleAlarms(context)
        }
    }

    private fun rescheduleAlarms(context: Context) {
        val prefs = context.getSharedPreferences(Const.PREFS_NAME, Context.MODE_PRIVATE)
        
        // Recover check-in/out times from SharedPreferences 
        // (These keys match what I'll ensure Flutter writes)
        val checkInHour = prefs.getInt("flutter.check_in_hour", 9)
        val checkInMin = prefs.getInt("flutter.check_in_minute", 0)
        val checkOutHour = prefs.getInt("flutter.check_out_hour", 17)
        val checkOutMin = prefs.getInt("flutter.check_out_minute", 0)

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Schedule for both check-in and check-out at all 3 stages: -30, -15, 0
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_IN, checkInHour, checkInMin, 30)
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_IN, checkInHour, checkInMin, 15)
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_IN, checkInHour, checkInMin, 0)
        
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_OUT, checkOutHour, checkOutMin, 30)
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_OUT, checkOutHour, checkOutMin, 15)
        scheduleStage(context, alarmManager, Const.TYPE_CHECK_OUT, checkOutHour, checkOutMin, 0)
    }

    private fun scheduleStage(context: Context, alarmManager: AlarmManager, type: String, hr: Int, min: Int, offset: Int) {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hr)
            set(Calendar.MINUTE, min)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.MINUTE, -offset)
            
            // If time is past, schedule for tomorrow
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra(Const.EXTRA_TYPE, type)
            putExtra("offset", offset)
        }
        
        val requestCode = (type.hashCode() + offset) // Unique enough for these states
        val pendingIntent = PendingIntent.getBroadcast(
            context, 
            requestCode, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Using setExactAndAllowWhileIdle for battery optimization compliance
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        }
    }
}
