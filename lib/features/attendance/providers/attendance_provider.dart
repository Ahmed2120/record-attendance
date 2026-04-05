import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import '../../../core/services/database_service.dart';

import '../../../core/services/settings_service.dart';

// Provide the DatabaseService
final databaseServiceProvider = Provider((ref) => DatabaseService());

// Provide the Repository
final attendanceRepositoryProvider = Provider((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return AttendanceRepository(dbService);
});

// Provide the Attendance List (for a specific month) using StateNotifier
final attendanceRecordsProvider = StateNotifierProvider.family<AttendanceListNotifier, AsyncValue<List<AttendanceRecord>>, DateTime>((ref, date) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return AttendanceListNotifier(repo, date, ref);
});

class AttendanceListNotifier extends StateNotifier<AsyncValue<List<AttendanceRecord>>> {
  final AttendanceRepository _repo;
  final DateTime _date;
  final Ref _ref;

  AttendanceListNotifier(this._repo, this._date, this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final records = await _repo.getMonthlyRecords(_date.month, _date.year);
      state = AsyncValue.data(records);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> checkIn() async {
    state = const AsyncValue.loading();
    final settings = _ref.read(settingsProvider);
    final now = DateTime.now();
    
    // Calculate Latetime
    final targetTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      settings.checkInTime.hour, 
      settings.checkInTime.minute,
    );
    
    int lateMinutes = 0;
    if (now.isAfter(targetTime)) {
      lateMinutes = now.difference(targetTime).inMinutes;
    }

    final newRecord = AttendanceRecord(
      checkInTime: now,
      lateMinutes: lateMinutes,
    );

    await _repo.checkIn(newRecord);
    await refresh();
  }

  Future<void> checkOut() async {
    state = const AsyncValue.loading();
    final todayRecord = await _repo.getTodayRecord();
    if (todayRecord == null || todayRecord.checkOutTime != null) return;

    final now = DateTime.now();
    final workingMinutes = now.difference(todayRecord.checkInTime).inMinutes;

    final updatedRecord = todayRecord.copyWith(
      checkOutTime: now,
      workingMinutes: workingMinutes,
    );

    await _repo.checkOut(updatedRecord);
    await refresh();
  }

  Future<void> updateNote(AttendanceRecord record, String note) async {
    final updatedRecord = record.copyWith(notes: note);
    await _repo.checkOut(updatedRecord); // checkOut uses updateRecord, which is what we need
    await refresh();
  }
}

// Provider for today's status (to enable/disable buttons)
final todayAttendanceProvider = FutureProvider<AttendanceRecord?>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  
  // Watch current month's list to refresh when check-in/out happens
  final now = DateTime.now();
  ref.watch(attendanceRecordsProvider(DateTime(now.year, now.month)));
  
  return await repo.getTodayRecord();
});
