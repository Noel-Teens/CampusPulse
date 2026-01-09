import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);

      return response.text ??
          "I'm having trouble understanding that. Please try again.";
    } catch (e) {
      if (kDebugMode) {
        print('Gemini API Error: $e');
      }
      // Return the actual error to help debugging
      return "Debug Error: $e";
    }
  }
}
