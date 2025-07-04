import 'package:flutter/material.dart';
import 'package:taskgenius/domain/entities/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChanged;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    switch (task.status) {
      case TaskStatus.todo:
        backgroundColor = null; // Default card color
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.orange.withAlpha((0.15 * 255).round());
        break;
      case TaskStatus.completed:
        backgroundColor = Colors.blue.withAlpha((0.15 * 255).round());
        break;
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          task.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: DropdownButton<TaskStatus>(
          value: task.status,
          onChanged: (status) {
            if (status != null) onStatusChanged(status);
          },
          items: TaskStatus.values.map((status) {
            return DropdownMenuItem(value: status, child: Text(status.name));
          }).toList(),
        ),
        onTap: onTap,
      ),
    );
  }
}
