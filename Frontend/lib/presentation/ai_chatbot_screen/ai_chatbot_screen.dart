import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/language_provider.dart';
import './widgets/chat_message_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/quick_action_buttons_widget.dart';
import './widgets/typing_indicator_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../core/config/app_config.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

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

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': message,
        'time': _getCurrentTime(),
      });
      _messages.add({
        'isUser': false,
        'text': '⏳ KrishiMitra AI soch raha hai...',
        'time': _getCurrentTime(),
      });
      _isTyping = true;
    });

    _scrollToBottom();
    _getAIResponse(message);
  }

  Future<void> _getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.chatApiBase}/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': message}),
      ).timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _messages.removeLast();
          _messages.add({
            'isUser': false,
            'text': data['answer'],
            'time': _getCurrentTime(),
          });
          _isTyping = false;
        });
      } else {
        throw Exception(data['message']);
      }
    } on TimeoutException {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'isUser': false,
          'text': '⏱️ Server respond nahi kar raha, thoda wait karke dobara try karein.',
          'time': _getCurrentTime(),
        });
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'isUser': false,
          'text': 'Server se connect nahi ho pa raha, dobara try karein',
          'time': _getCurrentTime(),
        });
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    if (_messages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _addWelcomeMessage(lang));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('KrishiMitra AI'),
            Text(
              lang == 'en' ? 'Online' : 'ऑनलाइन',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: const [SizedBox()],
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
          QuickActionButtonsWidget(onActionTap: _handleSendMessage),
          MessageInputWidget(
            onSendMessage: _handleSendMessage,
            onImagePick: () {},
            onVoiceRecord: () {},
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.chatbot,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
            case CustomBottomBarItem.community:
              Navigator.pushReplacementNamed(context, AppRoutes.communityChat);
            case CustomBottomBarItem.chatbot:
              break;
            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }
}
