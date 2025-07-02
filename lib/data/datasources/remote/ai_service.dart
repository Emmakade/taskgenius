import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:taskgenius/core/errors/exceptions.dart';
import 'package:taskgenius/domain/entities/task.dart';

class AIService {
  final Dio _dio;
  final String _apiKey;

  AIService(this._dio, this._apiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.baseUrl = 'https://api.deepseek.com/v1';
  }

  Future<String> generateTaskSuggestions(String input) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful task management assistant. 
            When given a natural language input, extract and structure task information.
            Respond with JSON format containing tasks with title, description, priority, and due_date.''',
            },
            {'role': 'user', 'content': input},
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      throw AIException('Failed to generate task suggestions: ${e.toString()}');
    }
  }

  Future<List<TaskSuggestion>> analyzeTaskPriorities(List<Task> tasks) async {
    final taskData = tasks
        .map(
          (task) => {
            'title': task.title,
            'description': task.description,
            'due_date': task.dueDate?.toIso8601String(),
            'current_priority': task.priority.name,
          },
        )
        .toList();

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''Analyze the given tasks and suggest priority adjustments and scheduling optimizations.
            Return JSON with suggested changes including reasoning.''',
            },
            {'role': 'user', 'content': jsonEncode(taskData)},
          ],
          'max_tokens': 1500,
          'temperature': 0.5,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseTaskSuggestions(content);
    } catch (e) {
      throw AIException('Failed to analyze task priorities: ${e.toString()}');
    }
  }
}
