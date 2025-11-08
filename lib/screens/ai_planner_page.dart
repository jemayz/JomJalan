import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/services/mock_api_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Scroll to the bottom
    // We can add a ScrollController for this later

    final response = await _apiService.getAiPlan(userPrompt);

    setState(() {
      _chatHistory.add({"role": "ai", "text": response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Travel Planner',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
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
                    // --- FIX #1: Make typing text white ---
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Destination, duration, budget...',
                      // --- FIX #2: Make hint text grey ---
                      hintStyle: const TextStyle(color: subTextColor),

                      // --- FIX #3: Make text field visible ---
                      filled: true,
                      fillColor: secondaryBackgroundColor,

                      // ------------------------------------
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
                    // --- FIX #4: Use primary green for button ---
                    backgroundColor: primaryGreen,
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

  // --- NEW FUNCTION TO RENDER BOLD TEXT ---
  Widget _buildFormattedText(String text) {
    // This is the default style for all text
    final baseStyle = const TextStyle(
      color: textColor,
      fontSize: 16,
      height: 1.4,
    );

    // This is the style for the bolded parts
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    List<TextSpan> spans = [];
    // Split the text by the bold delimiter
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      // Even-numbered parts (0, 2, 4...) are normal text
      // Odd-numbered parts (1, 3, 5...) are the bolded text
      spans.add(
        TextSpan(
          text: parts[i],
          style:
              i % 2 == 1 ? boldStyle : baseStyle, // Apply style based on index
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // --- FIX #5: User bubble is green, AI bubble is dark grey ---
          color: isUser ? accentColor : secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildFormattedText(text),
      ),
    );
  }
}
