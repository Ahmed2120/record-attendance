import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;
  final List<int> weeklyHolidays;
  final bool isSetupComplete;
  final bool isOnboardingComplete;

  AppSettings({
    required this.checkInTime,
    required this.checkOutTime,
    required this.weeklyHolidays,
    required this.isSetupComplete,
    required this.isOnboardingComplete,
  });

  AppSettings copyWith({
    TimeOfDay? checkInTime,
    TimeOfDay? checkOutTime,
    List<int>? weeklyHolidays,
    bool? isSetupComplete,
    bool? isOnboardingComplete,
  }) {
    return AppSettings(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      weeklyHolidays: weeklyHolidays ?? this.weeklyHolidays,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}

class SettingsService extends Notifier<AppSettings> {
  static const String _kCheckInHour = 'check_in_hour';
  static const String _kCheckInMinute = 'check_in_minute';
  static const String _kCheckOutHour = 'check_out_hour';
  static const String _kCheckOutMinute = 'check_out_minute';
  static const String _kIsSetupComplete = 'is_setup_complete';
  static const String _kIsOnboardingComplete = 'is_onboarding_complete';
  static const String _kWeeklyHolidays = 'weekly_holidays';

  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    // Initial dummy state, will be updated by init()
    return AppSettings(
      checkInTime: const TimeOfDay(hour: 9, minute: 0),
      checkOutTime: const TimeOfDay(hour: 17, minute: 0),
      weeklyHolidays: [DateTime.friday, DateTime.saturday],
      isSetupComplete: false,
      isOnboardingComplete: false,
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    final checkInH = _prefs.getInt(_kCheckInHour) ?? 9;
    final checkInM = _prefs.getInt(_kCheckInMinute) ?? 0;
    final checkOutH = _prefs.getInt(_kCheckOutHour) ?? 17;
    final checkOutM = _prefs.getInt(_kCheckOutMinute) ?? 0;
    final isComplete = _prefs.getBool(_kIsSetupComplete) ?? false;
    final isOnboarding = _prefs.getBool(_kIsOnboardingComplete) ?? false;

    final holidayStrings = _prefs.getStringList(_kWeeklyHolidays);
    final weeklyHolidays = holidayStrings?.map((e) => int.parse(e)).toList() ?? [DateTime.friday, DateTime.saturday];

    state = AppSettings(
      checkInTime: TimeOfDay(hour: checkInH, minute: checkInM),
      checkOutTime: TimeOfDay(hour: checkOutH, minute: checkOutM),
      weeklyHolidays: weeklyHolidays,
      isSetupComplete: isComplete,
      isOnboardingComplete: isOnboarding,
    );
  }

  Future<void> updateCheckInTime(TimeOfDay time) async {
    await _prefs.setInt(_kCheckInHour, time.hour);
    await _prefs.setInt(_kCheckInMinute, time.minute);
    state = state.copyWith(checkInTime: time);
  }

  Future<void> updateCheckOutTime(TimeOfDay time) async {
    await _prefs.setInt(_kCheckOutHour, time.hour);
    await _prefs.setInt(_kCheckOutMinute, time.minute);
    state = state.copyWith(checkOutTime: time);
  }

  Future<void> completeSetup() async {
    await _prefs.setBool(_kIsSetupComplete, true);
    state = state.copyWith(isSetupComplete: true);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_kIsOnboardingComplete, true);
    state = state.copyWith(isOnboardingComplete: true);
  }

  Future<void> updateWeeklyHolidays(List<int> days) async {
    final strings = days.map((e) => e.toString()).toList();
    await _prefs.setStringList(_kWeeklyHolidays, strings);
    state = state.copyWith(weeklyHolidays: days);
  }
}

final settingsProvider = NotifierProvider<SettingsService, AppSettings>(() => SettingsService());
