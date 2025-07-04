import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/core/utils/route_name.dart';

import 'package:taskgenius/presentation/providers/task_provider.dart';
import 'package:taskgenius/presentation/providers/auth_provider.dart';
import 'package:taskgenius/domain/entities/task.dart';
import 'package:taskgenius/presentation/widgets/task_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  void _deleteTask(Task task) {
    final provider = context.read<TaskProvider>();
    provider.deleteTask(task.id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task deleted Successfukky.')));
    }
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<AuthProvider>().signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
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
              return Slidable(
                key: ValueKey(task.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _deleteTask(task),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: TaskTile(
                  task: task,
                  onTap: () => _showTaskDetails(context, task),
                  onStatusChanged: (status) => _updateTaskStatus(task, status),
                ),
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
