import '../models/attendance_record.dart';
import '../../../core/services/database_service.dart';

class AttendanceRepository {
  final DatabaseService _databaseService;

  AttendanceRepository(this._databaseService);

  Future<List<AttendanceRecord>> getMonthlyRecords(int month, int year) async {
    return await _databaseService.getRecordsForMonth(month, year);
  }

  Future<AttendanceRecord?> getTodayRecord() async {
    return await _databaseService.getTodayRecord();
  }

  Future<int> checkIn(AttendanceRecord record) async {
    return await _databaseService.insertRecord(record);
  }

  Future<int> checkOut(AttendanceRecord record) async {
    return await _databaseService.updateRecord(record);
  }
}
