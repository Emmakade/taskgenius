import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import 'custom_text_field.dart';
import 'custom_button.dart';

class TaskCreationForm extends StatefulWidget {
  final void Function()? onTaskCreated;
  const TaskCreationForm({super.key, this.onTaskCreated});

  @override
  State<TaskCreationForm> createState() => _TaskCreationFormState();
}

class _TaskCreationFormState extends State<TaskCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _titleController,
            label: 'Title',
            hintText: 'Enter task title',
            keyboardType: TextInputType.text,
            prefixIcon: Icons.title,
            validator: (v) => v == null || v.isEmpty ? 'Title required' : null,
            obscureText: false,
            suffixIcon: null,
          ),
          SizedBox(height: 12),
          CustomTextField(
            controller: _descController,
            label: 'Description',
            hintText: 'Enter task description',
            keyboardType: TextInputType.text,
            prefixIcon: Icons.description,
            validator: (v) => null,
            obscureText: false,
            suffixIcon: null,
          ),
          SizedBox(height: 16),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: TaskPriority.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.name[0].toUpperCase() + p.name.substring(1),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (p) =>
                      setState(() => _priority = p ?? TaskPriority.medium),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'Select date'
                          : _dueDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _dueTime = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _dueTime == null
                          ? 'Select time'
                          : _dueTime!.format(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          CustomButton(text: 'Create Task', onPressed: _submit),
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<TaskProvider>();
      final task = Task(
        id: UniqueKey().toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate,
        dueTime: _dueTime,
        priority: _priority,
        status: TaskStatus.todo,
        projectId: '',
        order: provider.tasks.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await provider.createTask(task);
      widget.onTaskCreated?.call();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task created successfully!')));
      }
    }
  }
}
