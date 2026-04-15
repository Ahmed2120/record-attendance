import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/todo_provider.dart';
import '../../models/todo_item.dart';

class TodoListWidget extends ConsumerStatefulWidget {
  final DateTime date;
  final bool isHighlighted;

  const TodoListWidget({
    super.key,
    required this.date,
    this.isHighlighted = false,
  });

  @override
  ConsumerState<TodoListWidget> createState() => _TodoListWidgetState();
}

class _TodoListWidgetState extends ConsumerState<TodoListWidget> {
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _taskController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    ref.read(todoProvider(widget.date).notifier).addTodo(_taskController.text.trim());
    _taskController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final todosAsync = ref.watch(todoProvider(widget.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dailyTasks,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.isHighlighted ? Colors.white : theme.primaryColor,
              ),
            ),
            todosAsync.whenData((todos) {
              if (todos.isEmpty) return const SizedBox.shrink();
              final doneCount = todos.where((t) => t.isDone).length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isHighlighted ? Colors.white24 : theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$doneCount/${todos.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isHighlighted ? Colors.white : theme.primaryColor,
                  ),
                ),
              );
            }).value ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 12),
        
        // Input field
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: widget.isHighlighted ? Colors.white10 : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isHighlighted ? Colors.white : null,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.addTask,
                    hintStyle: TextStyle(
                      color: widget.isHighlighted ? Colors.white54 : Colors.grey,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              IconButton(
                onPressed: _addTask,
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: widget.isHighlighted ? Colors.white : theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // List of tasks
        todosAsync.when(
          data: (todos) {
            if (todos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    l10n.noTasks,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: widget.isHighlighted ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(todoProvider(widget.date).notifier).toggleTodo(todo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isHighlighted 
                                  ? Colors.white70 
                                  : (todo.isDone ? theme.primaryColor : Colors.grey.withOpacity(0.5)),
                              width: 1.5,
                            ),
                            color: todo.isDone 
                                ? (widget.isHighlighted ? Colors.white : theme.primaryColor) 
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: todo.isDone 
                                ? (widget.isHighlighted ? theme.primaryColor : Colors.white) 
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          todo.task,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isHighlighted 
                                ? (todo.isDone ? Colors.white60 : Colors.white) 
                                : (todo.isDone ? Colors.grey : null),
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(todoProvider(widget.date).notifier).deleteTodo(todo.id!),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: widget.isHighlighted ? Colors.white54 : Colors.grey.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          )),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }
}
