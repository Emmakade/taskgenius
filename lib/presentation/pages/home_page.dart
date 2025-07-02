import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/presentation/providers/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: Text('Task Manager Pro'),
        actions: [
          IconButton(
            icon: Icon(Icons.smart_toy),
            onPressed: () => Navigator.pushNamed(context, '/ai-assistant'),
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
