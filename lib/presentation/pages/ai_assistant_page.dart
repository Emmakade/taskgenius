import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskgenius/presentation/providers/ai_provider.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  _AIAssistantPageState createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AIProvider>(
              builder: (context, aiProvider, child) {
                return ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildWelcomeCard(),
                    SizedBox(height: 16),
                    if (aiProvider.isLoading) _buildLoadingCard(),
                    if (aiProvider.error != null)
                      _buildErrorCard(aiProvider.error!),
                    ...aiProvider.suggestions.map(_buildSuggestionCard),
                  ],
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
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
    // Accepts TaskSuggestion or Map
    final title = suggestion.title ?? '';
    final description = suggestion.description ?? '';
    final priority = suggestion.suggestedPriority ?? '';
    final dueDate = suggestion.dueDate ?? '';
    final reasoning = suggestion.reasoning ?? '';

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
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
            color: Colors.black.withOpacity(0.1),
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<AIProvider>().generateTasksFromText(text);
      _textController.clear();
    }
  }
}
