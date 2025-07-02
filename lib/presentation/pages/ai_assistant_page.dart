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
