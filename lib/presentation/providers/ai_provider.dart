import 'package:flutter/foundation.dart';
import 'package:taskgenius/core/utils/cache_manager.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:taskgenius/data/datasources/remote/ai_service.dart';

class AIProvider with ChangeNotifier {
  final AIService _aiService;
  final CacheManager _cacheManager;

  AIProvider(this._aiService, this._cacheManager);

  bool _isLoading = false;
  String? _error;
  List<TaskSuggestion> _suggestions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskSuggestion> get suggestions => _suggestions;

  Future<void> generateTasksFromText(String input) async {
    if (input.trim().isEmpty) return;

    _setLoading(true);

    try {
      // Check cache first
      final cacheKey = 'task_generation_${input.hashCode}';
      final cached = _cacheManager.get<List<TaskSuggestion>>(cacheKey);

      if (cached != null) {
        _suggestions = cached;
      } else {
        final response = await _aiService.generateTaskSuggestions(input);
        _suggestions = _parseTaskSuggestions(response);
        _cacheManager.set(cacheKey, _suggestions);
      }

      _error = null;
    } catch (e, stack) {
      _error = e.toString();
      _suggestions = [];
      log('AIProvider.generateTasksFromText error: $e\n$stack');
    } finally {
      _setLoading(false);
    }
  }

  List<TaskSuggestion> _parseTaskSuggestions(String response) {
    // Try to decode the response as JSON and map to TaskSuggestion
    try {
      final cleanedResponse = _cleanJson(response);
      final decoded = jsonDecode(cleanedResponse);
      if (decoded is List) {
        return decoded
            .map<TaskSuggestion>((e) => TaskSuggestion.fromMap(e))
            .toList();
      } else if (decoded is Map && decoded['tasks'] is List) {
        return (decoded['tasks'] as List)
            .map<TaskSuggestion>((e) => TaskSuggestion.fromMap(e))
            .toList();
      }
    } catch (e, stack) {
      log('AIProvider._parseTaskSuggestions error: $e\n$stack');
    }
    return [];
  }

  String _cleanJson(String input) {
    // Remove code block markers and trim whitespace
    return input.replaceAll(RegExp(r'```json|```'), '').trim();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
