import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];

  ChatProvider() {
    _loadMessages();
  }

  List<ChatMessage> get messages => _messages;

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        _messages = decoded.map((m) => ChatMessage.fromJson(m)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading chat history: $e');
      }
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history', data);
  }

  void addMessage(String role, String text) {
    _messages.add(ChatMessage(
      role: role,
      text: text,
      timestamp: DateTime.now(),
    ));
    _saveMessages();
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _saveMessages();
    notifyListeners();
  }
}
