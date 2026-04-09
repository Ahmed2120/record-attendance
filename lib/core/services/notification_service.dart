import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import '../../features/attendance/providers/attendance_provider.dart';

class NotificationService {
  static const _channel = MethodChannel('com.attendance.record_attendance/notifications');
  
  final Ref _ref;
  
  NotificationService(this._ref);

  Future<void> init() async {
    // Request permissions
    if (Platform.isAndroid) {
      await Permission.notification.request();
      // On Android 13+, exact alarms also might need permission
      await Permission.scheduleExactAlarm.request();
    } else if (Platform.isIOS) {
      // iOS specific setup via MethodChannel if needed, 
      // but usually local_notifications handles it.
      // Since we want "native", we'll implement it in AppDelegate.
    }
    
    // Sync current settings to Native on init
    await refreshAlarms();
    
    // Check for pending actions from Native
    await checkPendingActions();
  }

  Future<void> refreshAlarms() async {
    final settings = _ref.read(settingsProvider);
    
    // Update SharedPreferences with native-accessible keys
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('flutter.check_in_hour', settings.checkInTime.hour);
    await prefs.setInt('flutter.check_in_minute', settings.checkInTime.minute);
    await prefs.setInt('flutter.check_out_hour', settings.checkOutTime.hour);
    await prefs.setInt('flutter.check_out_minute', settings.checkOutTime.minute);

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('scheduleAlarms', {
          'checkInHour': settings.checkInTime.hour,
          'checkInMinute': settings.checkInTime.minute,
          'checkOutHour': settings.checkOutTime.hour,
          'checkOutMinute': settings.checkOutTime.minute,
        });
      }
    } catch (e) {
      print('Failed to schedule alarms: $e');
    }
  }

  Future<void> checkPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    
    final bool pendingCheckIn = prefs.getBool('flutter.pending_native_check_in') ?? false;
    final bool pendingCheckOut = prefs.getBool('flutter.pending_native_check_out') ?? false;

    if (pendingCheckIn || pendingCheckOut) {
      // Just refresh the data from DB since the native side already created the record
      final now = DateTime.now();
      _ref.read(attendanceRecordsProvider(DateTime(now.year, now.month)).notifier).refresh();
      
      // Clear flags
      if (pendingCheckIn) await prefs.setBool('flutter.pending_native_check_in', false);
      if (pendingCheckOut) await prefs.setBool('flutter.pending_native_check_out', false);
    }
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService(ref));
