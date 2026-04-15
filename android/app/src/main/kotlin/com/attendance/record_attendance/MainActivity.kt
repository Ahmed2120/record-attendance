package com.attendance.record_attendance

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.attendance.record_attendance.NotificationConstants as Const
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.attendance.record_attendance/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scheduleAlarms") {
                val checkInH = call.argument<Int>("checkInHour") ?: 9
                val checkInM = call.argument<Int>("checkInMinute") ?: 0
                val checkOutH = call.argument<Int>("checkOutHour") ?: 17
                val checkOutM = call.argument<Int>("checkOutMinute") ?: 0
                
                scheduleAllAlarms(checkInH, checkInM, checkOutH, checkOutM)
                result.success(true)
            } else if (call.method == "testNotification") {
                val type = call.argument<String>("type") ?: Const.TYPE_CHECK_IN
                val intent = Intent(this, AlarmReceiver::class.java).apply {
                    putExtra(Const.EXTRA_TYPE, type)
                    putExtra("offset", 0)
                    putExtra("isTest", true)
                }
                sendBroadcast(intent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scheduleAllAlarms(cinH: Int, cinM: Int, coutH: Int, coutM: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Schedule stage: type, hour, minute, offset (30, 15, 0)
        scheduleStage(alarmManager, Const.TYPE_CHECK_IN, cinH, cinM, 30)
        scheduleStage(alarmManager, Const.TYPE_CHECK_IN, cinH, cinM, 15)
        scheduleStage(alarmManager, Const.TYPE_CHECK_IN, cinH, cinM, 0)

        scheduleStage(alarmManager, Const.TYPE_CHECK_OUT, coutH, coutM, 30)
        scheduleStage(alarmManager, Const.TYPE_CHECK_OUT, coutH, coutM, 15)
        scheduleStage(alarmManager, Const.TYPE_CHECK_OUT, coutH, coutM, 0)
    }

    private fun scheduleStage(alarmManager: AlarmManager, type: String, hr: Int, min: Int, offset: Int) {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hr)
            set(Calendar.MINUTE, min)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.MINUTE, -offset)
            
            if (timeInMillis <= System.currentTimeMillis()) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra(Const.EXTRA_TYPE, type)
            putExtra("offset", offset)
        }
        
        val requestCode = (type.hashCode() + offset)
        val pendingIntent = PendingIntent.getBroadcast(
            this, 
            requestCode, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        }
    }
}
