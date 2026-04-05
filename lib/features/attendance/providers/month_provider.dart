import 'package:flutter_riverpod/flutter_riverpod.dart';

// Selection of the filter month in the UI
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});
