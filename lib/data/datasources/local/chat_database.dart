import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:taskgenius/domain/entities/chat_message.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_history (
        id TEXT PRIMARY KEY,
        userMessage TEXT,
        aiResponses TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertChat(ChatMessage chat) async {
    final db = await instance.database;
    await db.insert(
      'chat_history',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getChats({int limit = 10}) async {
    final db = await instance.database;
    final result = await db.query(
      'chat_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((e) => ChatMessage.fromMap(e)).toList();
  }

  Future<void> deleteChat(String id) async {
    final db = await instance.database;
    await db.delete('chat_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('chat_history');
  }
}
