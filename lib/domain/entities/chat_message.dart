import 'dart:convert';

class ChatMessage {
  final String id;
  final String userMessage;
  final List<dynamic> aiResponses; // List of TaskSuggestion or String
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userMessage,
    required this.aiResponses,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    // Store aiResponses as a JSON string for DB compatibility
    return {
      'id': id,
      'userMessage': userMessage,
      'aiResponses': jsonEncode(aiResponses),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    List<dynamic> aiResponsesParsed = [];
    if (map['aiResponses'] is String) {
      try {
        aiResponsesParsed = jsonDecode(map['aiResponses']);
      } catch (_) {
        aiResponsesParsed = [];
      }
    } else if (map['aiResponses'] is List) {
      aiResponsesParsed = List<dynamic>.from(map['aiResponses']);
    }
    return ChatMessage(
      id: map['id'] as String,
      userMessage: map['userMessage'] as String,
      aiResponses: aiResponsesParsed,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
