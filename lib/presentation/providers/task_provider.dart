import 'package:flutter/material.dart';
import 'package:taskgenius/domain/entities/task.dart';
import 'package:taskgenius/domain/entities/project.dart';
import 'package:taskgenius/domain/repositories/task_repository.dart';
import 'package:taskgenius/domain/repositories/project_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  TaskProvider(this._taskRepository, this._projectRepository);

  List<Task> _tasks = [];
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _taskRepository.getAllTasks();
      _projects = await _projectRepository.getAllProjects();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final createdTask = await _taskRepository.createTask(task);
      _tasks.add(createdTask);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;

    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);

    // Update order for affected tasks
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].order != i) {
        _tasks[i] = _tasks[i].copyWith(order: i);
        await _taskRepository.updateTask(_tasks[i]);
      }
    }

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
