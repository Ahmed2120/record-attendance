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
      version: 2,
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
        await db.execute('''
          CREATE TABLE vacations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE todo_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            task TEXT NOT NULL,
            is_done INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE todo_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              task TEXT NOT NULL,
              is_done INTEGER DEFAULT 0
            )
          ''');
        }
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

  // Vacations
  Future<List<Map<String, dynamic>>> getVacations() async {
    final db = await database;
    return await db.query('vacations', orderBy: 'date ASC');
  }

  Future<int> insertVacation(String date) async {
    final db = await database;
    return await db.insert('vacations', {'date': date}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> deleteVacation(int id) async {
    final db = await database;
    return await db.delete('vacations', where: 'id = ?', whereArgs: [id]);
  }

  // To-Do Items
  Future<List<Map<String, dynamic>>> getTodosForDate(String date) async {
    final db = await database;
    return await db.query(
      'todo_items',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
  }

  Future<int> insertTodo(Map<String, dynamic> todo) async {
    final db = await database;
    return await db.insert('todo_items', todo);
  }

  Future<int> updateTodo(Map<String, dynamic> todo) async {
    final db = await database;
    return await db.update(
      'todo_items',
      todo,
      where: 'id = ?',
      whereArgs: [todo['id']],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todo_items', where: 'id = ?', whereArgs: [id]);
  }
}

