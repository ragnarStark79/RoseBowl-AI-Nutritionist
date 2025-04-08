import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:animated_text_kit/animated_text_kit.dart';
import '../services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  List<Map<String, String>> messages = [];
  bool isTyping = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('chatHistory') ?? [];
    setState(() {
      messages = stored.map((e) => Map<String, String>.from(json.decode(e))).toList();
    });
    _scrollToBottom();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = messages.map((e) => json.encode(e)).toList();
    await prefs.setStringList('chatHistory', saved);
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": text});
      _controller.clear();
      isTyping = true;
    });
    _scrollToBottom();
    await _saveMessages();

    final response = await GeminiService.sendMessage(text);
    setState(() {
      messages.add({"role": "bot", "content": response});
      isTyping = false;
    });

    await _saveMessages();
    _scrollToBottom();
    _speak(response);
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(text);
  }

  void _startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => isListening = false);
      },
    );
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) {
          _controller.text = result.recognizedWords;
        },
      );
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  Future<void> _clearChat() async {
    setState(() => messages.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatHistory');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> message, int index) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blueAccent.shade100
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              message['content'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isUser
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          if (!isUser)
            TextButton.icon(
              onPressed: () => _speak(message['content'] ?? ''),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text("Speak"),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Bot is typing...',
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              speed: const Duration(milliseconds: 70),
            ),
          ],
          totalRepeatCount: 1,
          isRepeatingAnimation: false,
          pause: const Duration(milliseconds: 100),
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('Nutritionist Chatbot', style: GoogleFonts.poppins()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear Chat",
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  return _buildMessage(messages[index], index);
                } else {
                  return _buildTypingAnimation();
                }
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  onPressed: isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask your nutritionist...',
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
