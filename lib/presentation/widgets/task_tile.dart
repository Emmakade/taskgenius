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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (task.dueDate != null || task.dueTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    if (task.dueDate != null)
                      Text(
                        'Due: '
                        '${task.dueDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    if (task.dueTime != null) ...[
                      if (task.dueDate != null) SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 2),
                      Text(
                        task.dueTime!.format(context),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
          ],
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
