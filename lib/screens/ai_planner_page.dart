// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/services/api_service.dart';

class AiPlannerPage extends StatefulWidget {
  const AiPlannerPage({Key? key}) : super(key: key);

  @override
  _AiPlannerPageState createState() => _AiPlannerPageState();
}

class _AiPlannerPageState extends State<AiPlannerPage> {
  final TextEditingController _promptController = TextEditingController();
  final MockApiService _apiService = MockApiService();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  void _generatePlan() async {
    if (_promptController.text.isEmpty) return;
    final userPrompt = _promptController.text;

    setState(() {
      _chatHistory.add({"role": "user", "text": userPrompt});
      _isLoading = true;
    });
    _promptController.clear();

    final response = await _apiService.getAiPlan(userPrompt);

    setState(() {
      _chatHistory.add({"role": "ai", "text": response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Travel Planner'), centerTitle: true),
      body: Column(
        children: [
          // Chat History
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                bool isUser = message['role'] == 'user';
                return ChatBubble(text: message['text']!, isUser: isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),

          // Text Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'e.g., "3 days in Penang, budget-friendly"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: subTextColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryGreen),
                      ),
                    ),
                    onSubmitted: (value) => _generatePlan(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _generatePlan,
                  style: IconButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({Key? key, required this.text, required this.isUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? primaryGreen : accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : textColor,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
