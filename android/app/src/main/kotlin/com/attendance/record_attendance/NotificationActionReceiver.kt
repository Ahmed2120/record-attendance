package com.attendance.record_attendance

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.attendance.record_attendance.NotificationConstants as Const

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val type = intent.getStringExtra(Const.EXTRA_TYPE) ?: ""
        
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Dismiss the notification immediately upon action
        val notificationId = if (type == Const.TYPE_CHECK_IN) Const.NOTIFICATION_ID_CHECK_IN else Const.NOTIFICATION_ID_CHECK_OUT
        notificationManager.cancel(notificationId)
        
        // Update state in SharedPreferences for Flutter to see
        val prefs = context.getSharedPreferences(Const.PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        if (action == Const.ACTION_CHECK_IN) {
            editor.putBoolean(Const.PREF_IS_CHECKED_IN, true)
            editor.putLong("flutter.last_check_in_time", System.currentTimeMillis())
            editor.putBoolean("flutter.pending_native_check_in", true)
        } else if (action == Const.ACTION_CHECK_OUT) {
            editor.putBoolean(Const.PREF_IS_CHECKED_IN, false)
            editor.putBoolean("flutter.is_checked_out", true)
            editor.putLong("flutter.last_check_out_time", System.currentTimeMillis())
            editor.putBoolean("flutter.pending_native_check_out", true)
        }
        editor.apply()
        
        // If the app is already running, we might need a MethodChannel, but 
        // since we are in background, we launch the main activity to trigger Flutter's resume
        // or just rely on the next app open to process the 'pending' flags.
        // Actually, user wants "don't move it from status bar until he make checkin",
        // so clicking the button IS making checkin.
        
        // Optionally, wake up the app
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        context.startActivity(launchIntent)
    }
}
