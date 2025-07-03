import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taskgenius/core/errors/exceptions.dart';
import 'package:taskgenius/domain/entities/task.dart';

class AIService {
  final Dio _dio;
  final String _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';

  AIService(this._dio, String s) {
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
    } catch (e, stack) {
      // Log the error for debugging
      print('AIService.generateTaskSuggestions error: $e\n$stack');
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
    } catch (e, stack) {
      print('AIService.analyzeTaskPriorities error: $e\n$stack');
      throw AIException('Failed to analyze task priorities: ${e.toString()}');
    }
  }

  List<TaskSuggestion> _parseTaskSuggestions(String content) {
    // Try to decode the content as JSON, fallback to empty list on error
    try {
      final data = jsonDecode(content);
      if (data is List) {
        return data.map((e) => TaskSuggestion.fromMap(e)).toList();
      } else if (data is Map && data['tasks'] is List) {
        return (data['tasks'] as List)
            .map((e) => TaskSuggestion.fromMap(e))
            .toList();
      }
    } catch (e, stack) {
      print('AIService._parseTaskSuggestions error: $e\n$stack');
    }
    return [];
  }
}

class TaskSuggestion {
  final String title;
  final String? description;
  final String? suggestedPriority;
  final String? dueDate;
  final String? reasoning;

  TaskSuggestion({
    required this.title,
    this.description,
    this.suggestedPriority,
    this.dueDate,
    this.reasoning,
  });

  factory TaskSuggestion.fromMap(Map<String, dynamic> map) {
    return TaskSuggestion(
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      suggestedPriority:
          map['suggested_priority'] as String? ?? map['priority'] as String?,
      dueDate: map['due_date'] as String?,
      reasoning: map['reasoning'] as String?,
    );
  }
}
