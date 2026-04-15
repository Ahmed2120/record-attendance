import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vacation_day.dart';
import 'attendance_provider.dart';

final vacationProvider = StateNotifierProvider<VacationNotifier, AsyncValue<List<VacationDay>>>((ref) {
  return VacationNotifier(ref);
});

class VacationNotifier extends StateNotifier<AsyncValue<List<VacationDay>>> {
  final Ref _ref;

  VacationNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadVacations();
  }

  Future<void> loadVacations() async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseServiceProvider);
      final maps = await db.getVacations();
      final vacations = maps.map((m) => VacationDay.fromMap(m)).toList();
      state = AsyncValue.data(vacations);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addVacation(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final db = _ref.read(databaseServiceProvider);
    await db.insertVacation(dateStr);
    await loadVacations();
  }

  Future<void> removeVacation(int id) async {
    final db = _ref.read(databaseServiceProvider);
    await db.deleteVacation(id);
    await loadVacations();
  }
}
