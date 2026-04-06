package com.attendance.record_attendance

object NotificationConstants {
    const val CHANNEL_ID = "attendance_reminders"
    const val CHANNEL_NAME = "Attendance Reminders"
    const val CHANNEL_DESC = "Notifications for check-in and check-out reminders"
    
    const val ACTION_CHECK_IN = "ACTION_CHECK_IN"
    const val ACTION_CHECK_OUT = "ACTION_CHECK_OUT"
    const val EXTRA_TYPE = "extra_type"
    const val TYPE_CHECK_IN = "check_in"
    const val TYPE_CHECK_OUT = "check_out"
    
    const val NOTIFICATION_ID_CHECK_IN = 1001
    const val NOTIFICATION_ID_CHECK_OUT = 1002
    
    const val PREFS_NAME = "FlutterSharedPreferences"
    const val PREF_IS_CHECKED_IN = "flutter.is_checked_in" // Matches SharedPreferences plugin prefix
}
