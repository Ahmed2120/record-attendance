import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/attendance/models/attendance_record.dart';

class DatabaseService {
  static const String _tableName = 'attendance';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            check_in TEXT NOT NULL,
            check_out TEXT,
            late_minutes INTEGER DEFAULT 0,
            working_minutes INTEGER DEFAULT 0,
            notes TEXT DEFAULT ''
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.insert(_tableName, record.toMap());
  }

  Future<int> updateRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.update(
      _tableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<List<AttendanceRecord>> getRecordsForMonth(int month, int year) async {
    final db = await database;
    
    // YYYY-MM
    final monthStr = month < 10 ? '0$month' : '$month';
    final prefix = '$year-$monthStr';

    final result = await db.query(
      _tableName,
      where: "check_in LIKE ?",
      whereArgs: ['$prefix%'],
      orderBy: 'check_in DESC',
    );

    return result.map((map) => AttendanceRecord.fromMap(map)).toList();
  }

  Future<AttendanceRecord?> getTodayRecord() async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final result = await db.query(
      _tableName,
      where: "check_in LIKE ?",
      whereArgs: ['$todayStr%'],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AttendanceRecord.fromMap(result.first);
  }
}
