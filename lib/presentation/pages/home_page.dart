import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/core/utils/route_name.dart';

import 'package:taskgenius/presentation/providers/task_provider.dart';
import 'package:taskgenius/domain/entities/task.dart';
import 'package:taskgenius/presentation/widgets/task_tile.dart';
import '../widgets/task_creation_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Text(task.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(Task task, TaskStatus status) {
    final provider = context.read<TaskProvider>();
    provider.updateTask(task.copyWith(status: status));
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Task'),
        content: SingleChildScrollView(child: TaskCreationForm()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Genius'),
        actions: [
          IconButton(
            icon: Icon(Icons.smart_toy),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.aiAssistant),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (taskProvider.error != null) {
            return Center(child: Text('Error: ${taskProvider.error}'));
          }

          return ReorderableListView.builder(
            itemCount: taskProvider.tasks.length,
            onReorder: taskProvider.reorderTasks,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return TaskTile(
                key: ValueKey(task.id),
                task: task,
                onTap: () => _showTaskDetails(context, task),
                onStatusChanged: (status) => _updateTaskStatus(task, status),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
