import 'package:flutter/material.dart';

import 'package:taskgenius/domain/entities/chat_message.dart';
import 'package:taskgenius/data/datasources/local/chat_database.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _chats = [];
  final ChatDatabase _db = ChatDatabase.instance;

  List<ChatMessage> get chats => List.unmodifiable(_chats);

  Future<void> loadChats() async {
    final loaded = await _db.getChats(limit: 10);
    _chats
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> addChat(ChatMessage chat) async {
    await _db.insertChat(chat);
    await loadChats();
  }

  Future<void> deleteChat(String id) async {
    await _db.deleteChat(id);
    await loadChats();
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    await loadChats();
  }
}
