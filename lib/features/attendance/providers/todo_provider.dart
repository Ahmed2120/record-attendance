import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../repositories/todo_repository.dart';
import 'attendance_provider.dart';

final todoRepositoryProvider = Provider((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return TodoRepository(dbService);
});

final todoProvider = StateNotifierProvider.family<TodoListNotifier, AsyncValue<List<TodoItem>>, DateTime>((ref, date) {
  final repo = ref.watch(todoRepositoryProvider);
  return TodoListNotifier(repo, date);
});

class TodoListNotifier extends StateNotifier<AsyncValue<List<TodoItem>>> {
  final TodoRepository _repo;
  final DateTime _date;

  TodoListNotifier(this._repo, this._date) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final todos = await _repo.getTodosForDate(_date);
      state = AsyncValue.data(todos);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addTodo(String task) async {
    final dateStr = "${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}";
    final todo = TodoItem(date: dateStr, task: task);
    await _repo.addTodo(todo);
    await refresh();
  }

  Future<void> toggleTodo(TodoItem todo) async {
    final updatedTodo = todo.copyWith(isDone: !todo.isDone);
    await _repo.updateTodo(updatedTodo);
    await refresh();
  }

  Future<void> deleteTodo(int id) async {
    await _repo.deleteTodo(id);
    await refresh();
  }
}
