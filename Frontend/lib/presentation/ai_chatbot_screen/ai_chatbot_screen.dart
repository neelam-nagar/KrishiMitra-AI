import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/quick_action_buttons_widget.dart';
import './widgets/suggested_questions_widget.dart';
import './widgets/typing_indicator_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    // welcome message will be added after build using provider
  }

  // ================= TIME =================
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // ================= WELCOME =================
  void _addWelcomeMessage(String lang) {
    _messages.clear();
    _messages.add({
      'isUser': false,
      'text': lang == 'en'
          ? 'Namaste! I am KrishiMitra AI Assistant. How can I help you today?'
          : 'नमस्ते! मैं कृषि मित्र AI सहायक हूँ। मैं आपकी कैसे मदद कर सकता हूँ?',
      'time': _getCurrentTime(),
    });
  }

  // ================= SCROLL =================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ================= SEND MESSAGE =================
  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': message,
        'time': _getCurrentTime(),
      });
      _isTyping = true;
      _showSuggestions = false;
    });

    _scrollToBottom();

    _getAIResponse(message);
  }

  Future<void> _getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/chat"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "question": message,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': data["answer"],
            'time': _getCurrentTime(),
          });
          _isTyping = false;
        });
      } else {
        throw Exception(data["message"]);
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'isUser': false,
          'text': "Server se connect nahi ho pa raha, dobara try karein",
          'time': _getCurrentTime(),
        });
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    if (_messages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addWelcomeMessage(lang);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('KrishiMitra AI'),
            Text(
              lang == 'en'
                  ? 'Online'
                  : 'ऑनलाइन',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          const SizedBox(), // language controlled from Profile screen
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return TypingIndicatorWidget(isTyping: _isTyping);
                }
                return ChatMessageWidget(message: _messages[index]);
              },
            ),
          ),

          QuickActionButtonsWidget(
            onActionTap: _handleSendMessage,
          ),
          MessageInputWidget(
            onSendMessage: _handleSendMessage,
            onImagePick: () {},
            onVoiceRecord: () {},
          ),
        ],
      )
      ,
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.chatbot,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
              break;
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
              break;
            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, AppRoutes.communityChat);
              break;

            case CustomBottomBarItem.chatbot:
              // already here
              break;

            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
      )
    );
  }
}