import '../../../core/services/database_service.dart';
import '../models/todo_item.dart';

class TodoRepository {
  final DatabaseService _dbService;

  TodoRepository(this._dbService);

  Future<List<TodoItem>> getTodosForDate(DateTime date) async {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final result = await _dbService.getTodosForDate(dateStr);
    return result.map((map) => TodoItem.fromMap(map)).toList();
  }

  Future<int> addTodo(TodoItem todo) async {
    return await _dbService.insertTodo(todo.toMap());
  }

  Future<int> updateTodo(TodoItem todo) async {
    return await _dbService.updateTodo(todo.toMap());
  }

  Future<int> deleteTodo(int id) async {
    return await _dbService.deleteTodo(id);
  }
}
