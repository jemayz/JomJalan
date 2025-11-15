import 'dart:convert'; // <-- ADD THIS
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/services/mock_api_service.dart';
import 'package:provider/provider.dart'; // <-- ADD THIS
import 'package:jomjalan/providers/itinerary_provider.dart'; // <-- ADD THIS

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
  final ScrollController _scrollController =
      ScrollController(); // For auto-scroll

  void _generatePlan() async {
    if (_promptController.text.isEmpty) return;
    final userPrompt = _promptController.text;

    // Get the ItineraryProvider *before* the async call
    final itineraryProvider = context.read<ItineraryProvider>();

    setState(() {
      _chatHistory.add({"role": "user", "text": userPrompt});
      _isLoading = true;
    });
    _promptController.clear();
    _scrollToBottom();

    // 1. Get the raw JSON string from the server
    final String jsonResponse = await _apiService.getAiPlan(userPrompt);

    // 2. Decode the JSON string into a Map
    Map<String, dynamic> aiData;
    String friendlyText;
    List<dynamic> itineraryDays = [];

    try {
      aiData = jsonDecode(jsonResponse);
      friendlyText =
          aiData['friendly_response'] ?? "Sorry, I had trouble planning.";
      itineraryDays = aiData['itinerary_days'] ?? [];
    } catch (e) {
      print("Error decoding AI JSON: $e");
      // This is a fallback if the AI sends plain text (or an error)
      friendlyText = jsonResponse;
    }

    // 3. Add *only* the friendly response to the chat
    setState(() {
      _chatHistory.add({"role": "ai", "text": friendlyText});
      _isLoading = false;
    });
    _scrollToBottom();

    // 4. Automatically add the new spots to your itinerary page
    if (itineraryDays.isNotEmpty) {
      await itineraryProvider.addSpotsFromAi(itineraryDays, _apiService);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to "My Itinerary"!'),
          backgroundColor: primaryGreen,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // --- NEW: Auto-scroll function ---
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
              controller: _scrollController, // <-- ADDED controller
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
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Destination, duration, budget...',
                      hintStyle: const TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: secondaryBackgroundColor,
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
  // ... (this widget is unchanged) ...
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
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? primaryGreen : secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        // --- UPDATED: Use the new RichText function ---
        child: _buildFormattedText(text),
        // --------------------------------------------
      ),
    );
  }
}
