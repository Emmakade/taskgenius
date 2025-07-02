import 'package:taskgenius/domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/database_helper.dart';

class TaskRepositoryImpl implements TaskRepository {
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
  Future<void> addTask(Task task) async {
    final db = await databaseHelper.database;
    await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate?.toIso8601String(),
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
