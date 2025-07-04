import 'package:taskgenius/domain/entities/task.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/database_helper.dart';

class TaskRepositoryImpl implements TaskRepository {
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  final DatabaseHelper databaseHelper;

  TaskRepositoryImpl(this.databaseHelper);

  @override
  Future<List<Task>> getTasks() async {
    final db = await databaseHelper.database;
    final taskMaps = await db.query('tasks');
    return taskMaps
        .map(
          (map) => Task(
            id: map['id'] as String,
            title: map['title'] as String,
            description: map['description'] as String? ?? '',
            dueDate: map['due_date'] != null
                ? DateTime.tryParse(map['due_date'] as String)
                : null,
            dueTime:
                map['due_time'] != null &&
                    map['due_time'] is String &&
                    (map['due_time'] as String).isNotEmpty
                ? _parseTimeOfDay(map['due_time'] as String)
                : null,
            priority: TaskPriority.values[map['priority'] as int],
            status: TaskStatus.values[map['status'] as int],
            projectId: map['project_id'] as String,
            order: map['order_index'] as int,
            createdAt: DateTime.parse(map['created_at'] as String),
            updatedAt: DateTime.parse(map['updated_at'] as String),
          ),
        )
        .toList();
  }

  @override
  Future<List<Task>> getAllTasks() async {
    return await getTasks();
  }

  @override
  Future<Task> createTask(Task task) async {
    await addTask(task);
    return task;
  }

  @override
  Future<void> addTask(Task task) async {
    final db = await databaseHelper.database;
    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate?.toIso8601String(),
      'due_time': task.dueTime != null ? _formatTimeOfDay(task.dueTime!) : null,
      'priority': task.priority.index,
      'status': task.status.index,
      'project_id': task.projectId,
      'order_index': task.order,
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await databaseHelper.database;
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'due_date': task.dueDate?.toIso8601String(),
        'due_time': task.dueTime != null
            ? _formatTimeOfDay(task.dueTime!)
            : null,
        'priority': task.priority.index,
        'status': task.status.index,
        'project_id': task.projectId,
        'order_index': task.order,
        'created_at': task.createdAt.toIso8601String(),
        'updated_at': task.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await databaseHelper.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
