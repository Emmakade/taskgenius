// presentation/providers/ai_provider.dart
import 'package:flutter/foundation.dart';
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
      final cached = await _cacheManager.getCachedResponse(cacheKey);

      if (cached != null) {
        _suggestions = cached;
      } else {
        final response = await _aiService.generateTaskSuggestions(input);
        _suggestions = _parseTaskSuggestions(response);
        await _cacheManager.cacheResponse(cacheKey, _suggestions);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _suggestions = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
