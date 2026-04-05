// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get helloBuddy => 'مرحباً يا صديقي';

  @override
  String get onboardingDescription =>
      'نحن نساعدك في تسجيل\nحضورك وانصرافك\nمن العمل';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get myAttendance => 'سجل حضوري';

  @override
  String get checkIn => 'تسجيل الدخول';

  @override
  String get checkOut => 'تسجيل الخروج';

  @override
  String get notes => 'ملاحظات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String get companyHours => 'ساعات العمل';

  @override
  String get checkInTime => 'وقت الحضور';

  @override
  String get checkOutTime => 'وقت الانصراف';

  @override
  String get hoursDisabledMessage =>
      'تم تعطيل تعديل الساعات لوجود سجلات حضور لهذا الشهر.';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get companySetup => 'إعداد الشركة';

  @override
  String get setupDescription => 'قم بتعيين ساعات عمل شركتك لتتبع الحضور بدقة.';

  @override
  String get noRecords => 'لا توجد سجلات هذا الشهر';

  @override
  String get total => 'المجموع';

  @override
  String get late => 'تأخير';

  @override
  String get hr => 'ساعة';

  @override
  String get absent => 'غائب';

  @override
  String get onTime => 'في الوقت';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get saveNote => 'حفظ';

  @override
  String get noNotesYet => 'لا توجد ملاحظات مسجلة';

  @override
  String minutesLate(int minutes) {
    return '$minutes دقيقة تأخير';
  }

  @override
  String get upcoming => 'قادم';

  @override
  String get noRecordsFound => 'لا توجد سجلات حضور لهذا الشهر';

  @override
  String get notRecorded => 'لم يتم التسجيل';
}
