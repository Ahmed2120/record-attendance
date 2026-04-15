class TodoItem {
  final int? id;
  final String date; // YYYY-MM-DD
  final String task;
  final bool isDone;

  TodoItem({
    this.id,
    required this.date,
    required this.task,
    this.isDone = false,
  });

  TodoItem copyWith({
    int? id,
    String? date,
    String? task,
    bool? isDone,
  }) {
    return TodoItem(
      id: id ?? this.id,
      date: date ?? this.date,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'task': task,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      date: map['date'],
      task: map['task'],
      isDone: map['is_done'] == 1,
    );
  }
}
