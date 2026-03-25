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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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

    Future.delayed(const Duration(seconds: 2), () {
      _generateAIResponse(message);
    });
  }

  // ================= AI RESPONSE =================
  void _generateAIResponse(String userMessage) {
    final lang = context.read<LanguageProvider>().currentLanguage;
    final msg = userMessage.toLowerCase();

    Map<String, dynamic> response = {
      'isUser': false,
      'time': _getCurrentTime(),
    };

    if (msg.contains('weather')) {
      response['text'] = lang == 'en'
          ? 'Today the weather is clear with 28°C temperature.'
          : 'आज मौसम साफ है और तापमान 28°C है।';

    } else if (msg.contains('price') || msg.contains('mandi')) {
      response['text'] = lang == 'en'
          ? 'Today wheat price is ₹2,150 per quintal.'
          : 'आज गेहूं का भाव ₹2,150 प्रति क्विंटल है।';

    } else if (msg.contains('scheme')) {
      response['text'] = lang == 'en'
          ? 'PM-KISAN provides ₹6,000 annual support to farmers.'
          : 'PM-KISAN योजना में किसानों को ₹6,000 सालाना मिलते हैं।';

    } else if (msg.contains('organic')) {
      response['text'] = lang == 'en'
          ? 'Organic farming improves soil health and income.'
          : 'जैविक खेती मिट्टी की गुणवत्ता और आय बढ़ाती है।';

    } else if (msg.contains('market')) {
      response['text'] = lang == 'en'
          ? 'You can buy and sell crops using marketplace.'
          : 'आप मार्केटप्लेस से फसल खरीद और बेच सकते हैं।';

    } else {
      response['text'] = lang == 'en'
          ? 'I can help with weather, mandi prices, schemes and farming tips.'
          : 'मैं मौसम, मंडी भाव, योजनाओं और खेती की जानकारी दे सकता हूँ।';
    }

    setState(() {
      _messages.add(response);
      _isTyping = false;
    });

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
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const TypingIndicatorWidget();
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