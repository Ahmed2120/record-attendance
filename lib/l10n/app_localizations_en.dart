// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Record Your Attendance';

  @override
  String get helloBuddy => 'Hello Buddy';

  @override
  String get onboardingDescription =>
      'We help you record your\nattendance and departure\nfrom work';

  @override
  String get getStarted => 'Get Started';

  @override
  String get myAttendance => 'My attendance';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get notes => 'Notes';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get companyHours => 'Company Hours';

  @override
  String get checkInTime => 'Check-in Time';

  @override
  String get checkOutTime => 'Check-out Time';

  @override
  String get hoursDisabledMessage =>
      'Updating hours is disabled because you have attendance records for this month.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get companySetup => 'Company Setup';

  @override
  String get setupDescription =>
      'Set your company\'s working hours to track attendance accurately.';

  @override
  String get noRecords => 'No records this month';

  @override
  String get total => 'Total';

  @override
  String get late => 'Late';

  @override
  String get hr => 'Hr';

  @override
  String get absent => 'Absent';

  @override
  String get onTime => 'On Time';

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get saveNote => 'Save';

  @override
  String get noNotesYet => 'No notes recorded';

  @override
  String minutesLate(int minutes) {
    return '${minutes}m Late';
  }

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noRecordsFound => 'No attendance records found for this month';

  @override
  String get notRecorded => 'Not Recorded';

  @override
  String get testNotifications => 'Test Notifications';

  @override
  String get testCheckInNotification => 'Test Check In Notification';

  @override
  String get testCheckOutNotification => 'Test Check Out Notification';

  @override
  String get vacations => 'Vacation Days';

  @override
  String get weeklyHolidays => 'Weekly Holidays';

  @override
  String get addVacation => 'Add Vacation Day';

  @override
  String get vacation => 'Vacation';

  @override
  String get noVacationsFound => 'No vacation days added';

  @override
  String get deleteVacation => 'Delete Vacation';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get dailyTasks => 'Daily Tasks';

  @override
  String get addTask => 'Add Task...';

  @override
  String get noTasks => 'No tasks for today';

  @override
  String get moveToTomorrow => 'Move to Tomorrow';

  @override
  String get tasksFromYesterday => 'Tasks from yesterday';

  @override
  String get remindMeTomorrow => 'Remind me tomorrow';
}
