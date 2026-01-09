import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIController extends ChangeNotifier {
  final AIService _aiService = AIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  // Add initial greeting
  AIController() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your generic Campus AI Assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    _isLoading = true;
    notifyListeners();

    try {
      // Get response from Gemini
      final response = await _aiService.sendMessage(text);

      // Add AI response
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: "Error: Could not fetch response.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
