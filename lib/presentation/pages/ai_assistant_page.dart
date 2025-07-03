import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/presentation/providers/ai_provider.dart';
import 'package:taskgenius/presentation/providers/task_provider.dart';
import 'package:taskgenius/domain/entities/task.dart';
import 'package:taskgenius/domain/entities/chat_message.dart';
import 'package:taskgenius/presentation/providers/chat_provider.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  AIAssistantPageState createState() => AIAssistantPageState();
}

class AIAssistantPageState extends State<AIAssistantPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        context.read<ChatProvider>().loadChats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Column(
        children: [
          _buildWelcomeCard(),
          Consumer<AIProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.isLoading) {
                return _buildLoadingCard();
              }
              if (aiProvider.error != null) {
                return _buildErrorCard(aiProvider.error!);
              }
              return SizedBox.shrink();
            },
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User message card
                        Card(
                          color: Colors.blue.shade50,
                          child: ListTile(
                            title: Text(
                              'You',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(chat.userMessage),
                            trailing: Text(
                              _formatTime(chat.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // AI responses
                        ...chat.aiResponses.asMap().entries.map((entry) {
                          final ai = entry.value;
                          // If the AI response is a JSON object, show a suggestion card, else show as plain text
                          if (ai is Map<String, dynamic> ||
                              (ai?.title != null && ai?.description != null)) {
                            return GestureDetector(
                              onTap: () => _addTaskFromAI(context, ai),
                              onLongPress: () => _deleteChat(context, chat.id),
                              child: _buildSuggestionCard(ai),
                            );
                          } else {
                            final aiText = ai is String ? ai : ai.toString();
                            return GestureDetector(
                              onTap: () => _addTaskFromAI(context, ai),
                              onLongPress: () => _deleteChat(context, chat.id),
                              child: Card(
                                color: Colors.green.shade50,
                                child: ListTile(
                                  title: Text(
                                    'AI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(aiText.trim()),
                                  trailing: Icon(
                                    Icons.add_task,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                        SizedBox(height: 12),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.purple.shade50,
        child: Container(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to your AI Task Assistant!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Describe your tasks in natural language and get structured suggestions instantly.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      color: Colors.purple.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Thinking... Please wait.'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(error, style: TextStyle(color: Colors.red.shade900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(dynamic suggestion) {
    String title = '';
    String description = '';
    String priority = '';
    String dueDate = '';
    String reasoning = '';
    if (suggestion is Map<String, dynamic>) {
      title = suggestion['title'] ?? '';
      description = suggestion['description'] ?? '';
      priority =
          suggestion['priority'] ?? suggestion['suggested_priority'] ?? '';
      dueDate = suggestion['due_date'] ?? '';
      reasoning = suggestion['reasoning'] ?? '';
    } else if (suggestion.title != null) {
      title = suggestion.title ?? '';
      description = suggestion.description ?? '';
      priority = suggestion.suggestedPriority ?? suggestion.priority ?? '';
      dueDate = suggestion.dueDate ?? '';
      reasoning = suggestion.reasoning ?? '';
    }
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty && title != 'AI Response')
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            if (priority.isNotEmpty || dueDate.isNotEmpty) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  if (priority.isNotEmpty)
                    Chip(label: Text('Priority: $priority')),
                  if (dueDate.isNotEmpty) ...[
                    SizedBox(width: 8),
                    Chip(label: Text('Due: $dueDate')),
                  ],
                ],
              ),
            ],
            if (reasoning.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Reasoning: $reasoning',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Describe your tasks naturally...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final aiProvider = context.read<AIProvider>();
      await aiProvider.generateTasksFromText(text);

      // Save chat to chat provider and persist in DB
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.addChat(
        ChatMessage(
          id: UniqueKey().toString(),
          userMessage: text,
          aiResponses: List.from(aiProvider.suggestions),
          timestamp: DateTime.now(),
        ),
      );

      _textController.clear();
    }
  }

  void _addTaskFromAI(BuildContext context, dynamic suggestion) async {
    final taskProvider = context.read<TaskProvider>();
    final now = DateTime.now();
    String title = '';
    String description = '';
    String? priorityStr;
    String? dueDateStr;
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate;

    if (suggestion is Map<String, dynamic>) {
      title = suggestion['title'] ?? '';
      description = suggestion['description'] ?? '';
      priorityStr = suggestion['priority'] ?? suggestion['suggested_priority'];
      dueDateStr = suggestion['due_date'];
    } else if (suggestion.title != null) {
      title = suggestion.title ?? '';
      description = suggestion.description ?? '';
      priorityStr = suggestion.suggestedPriority ?? suggestion.priority;
      dueDateStr = suggestion.dueDate;
    } else if (suggestion is String) {
      title = suggestion;
    }

    // Parse priority
    if (priorityStr != null) {
      switch (priorityStr.toString().toLowerCase()) {
        case 'high':
          priority = TaskPriority.high;
          break;
        case 'low':
          priority = TaskPriority.low;
          break;
        case 'urgent':
          priority = TaskPriority.urgent;
          break;
        default:
          priority = TaskPriority.medium;
      }
    }
    // Parse due date
    if (dueDateStr != null && dueDateStr.toString().isNotEmpty) {
      try {
        dueDate = DateTime.parse(dueDateStr);
      } catch (_) {}
    }

    if (title.isNotEmpty) {
      final task = Task(
        id: UniqueKey().toString(),
        projectId: '',
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        status: TaskStatus.todo,
        order: taskProvider.tasks.length,
        createdAt: now,
        updatedAt: now,
      );
      await taskProvider.createTask(task);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added from AI response!')));
      }
    }
  }

  void _deleteChat(BuildContext context, String chatId) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.deleteChat(chatId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chat deleted.')));
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// Helper to parse priority string to your enum
