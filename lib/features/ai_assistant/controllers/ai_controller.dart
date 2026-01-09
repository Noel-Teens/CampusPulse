import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  AIService _aiService = AIService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentUid;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  // Set current user UID and isolate chats
  void setUid(String? uid) {
    if (_currentUid == uid) return;
    _currentUid = uid;
    _messages = [];
    // Reset AI service to clear Gemini chat history session
    _aiService = AIService();

    if (uid != null) {
      _addGreeting();
    }
    notifyListeners();
  }

  void _addGreeting() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your Campus AI Assistant. I can help you with campus maps, reporting issues, or answering questions about ongoing events and notices. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_currentUid == null) {
      _messages.add(
        ChatMessage(
          text: "Please sign in to use the AI Assistant.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
      return;
    }

    // Add user message
    _messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Campus Context (Notices, Issues)
      // Note: Events are stored as notices with isEvent=true
      final contexts = <String>[];

      // Fetch all notices and split into Notices and Events
      try {
        final snap = await FirebaseFirestore.instance
            .collection('notices')
            .get();
        if (snap.docs.isNotEmpty) {
          final allNotices = snap.docs.toList();

          // Separate and Sort
          final notices =
              allNotices.where((doc) => doc.data()['isEvent'] != true).toList()
                ..sort((a, b) {
                  final tA = a.data()['createdAt'] as Timestamp?;
                  final tB = b.data()['createdAt'] as Timestamp?;
                  if (tA == null) return 1;
                  if (tB == null) return -1;
                  return tB.compareTo(tA);
                });

          final events =
              allNotices.where((doc) => doc.data()['isEvent'] == true).toList()
                ..sort((a, b) {
                  final tA = a.data()['createdAt'] as Timestamp?;
                  final tB = b.data()['createdAt'] as Timestamp?;
                  if (tA == null) return 1;
                  if (tB == null) return -1;
                  return tB.compareTo(tA);
                });

          if (notices.isNotEmpty) {
            String info = "LATEST NOTICES:\n";
            for (var doc in notices.take(5)) {
              final data = doc.data();
              info +=
                  "- ${data['title'] ?? 'Notice'}: ${data['content'] ?? data['description'] ?? ''}\n";
            }
            contexts.add(info);
          }

          if (events.isNotEmpty) {
            String info = "\nUPCOMING EVENTS:\n";
            for (var doc in events.take(5)) {
              final data = doc.data();
              final dateStr = data['eventDate'] != null
                  ? (data['eventDate'] as Timestamp).toDate().toString().split(
                      ' ',
                    )[0]
                  : (data['date'] ?? 'TBA');
              info +=
                  "- ${data['title'] ?? 'Event'} on $dateStr: ${data['content'] ?? data['description'] ?? ''}\n";
            }
            contexts.add(info);
          }
        }
      } catch (e) {
        debugPrint("AI Fetch Error (notices/events): $e");
      }

      // ISSUES
      try {
        final snap = await FirebaseFirestore.instance
            .collection('issues')
            .get();
        if (snap.docs.isNotEmpty) {
          final filtered = snap.docs.where((doc) {
            final s = doc.data()['status']?.toString().toLowerCase();
            return s != 'resolved';
          }).toList();

          filtered.sort((a, b) {
            final tA = a.data()['createdAt'] as Timestamp?;
            final tB = b.data()['createdAt'] as Timestamp?;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          String info = "\nONGOING ISSUES:\n";
          for (var doc in filtered.take(5)) {
            final data = doc.data();
            info +=
                "- ${data['title'] ?? 'Issue'} (${data['status'] ?? 'Open'}): ${data['description'] ?? data['content'] ?? ''}\n";
          }
          contexts.add(info);
        }
      } catch (e) {
        debugPrint("AI Fetch Error (issues): $e");
      }

      String contextString = "CURRENT CAMPUS CONTEXT:\n\n";
      if (contexts.isEmpty) {
        contextString += "No recent updates found on campus yet.\n";
      } else {
        contextString += contexts.join("\n");
      }
      contextString += "\nUser Question: $text";

      // 2. Get response from Gemini
      final response = await _aiService.sendMessage(contextString);

      // Add AI response
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    } catch (e) {
      debugPrint("AI Assistant Global Error: $e");
      _messages.add(
        ChatMessage(
          text:
              "I'm sorry, I'm having trouble connecting to the latest campus updates. Please try again in a moment.",
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
