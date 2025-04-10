import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import '../services/chatbot_service.dart';
import '../theme/theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isListening = false;
  bool isSpeakingEnabled = true;

  late AnimationController _sendButtonController;
  late AnimationController _micButtonController;
  late AnimationController _bubbleAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadMessages();
    _initializeAnimations();
    _checkAndAddWelcomeMessage();
  }

  void _initializeAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _micButtonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-GB");
    final voices = await flutterTts.getVoices;

    if (voices != null && voices is List) {
      for (final voice in voices) {
        if (voice is Map &&
            voice['name'] != null &&
            voice['name'].toString().toLowerCase().contains('en-gb') &&
            voice['name'].toString().toLowerCase().contains('female')) {
          await flutterTts.setVoice({"name": voice['name'], "locale": "en-GB"});
          print("Selected voice: ${voice['name']}");
          break;
        }
      }
    }

    await flutterTts.setVoice({"name": "en-gb-x-gba", "locale": "en-GB"});
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {});
  }

  Future<void> _checkAndAddWelcomeMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    if (!hasSeenWelcome) {
      setState(() {
        messages.add({
          "role": "bot",
          "content": "👋 Hi there! I'm your RoseBowl Nutrition assistant. Ask me anything about nutrition, healthy eating, or meal plans!",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });
      });
      await prefs.setBool('hasSeenWelcome', true);
      await _saveMessages();

      if (isSpeakingEnabled) {
        _speak("Hi there! I'm your RoseBowl Nutrition assistant. Ask me anything about nutrition, healthy eating, or meal plans!");
      }
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('chatHistory') ?? [];
    setState(() {
      messages = stored.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
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

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      messages.add({
        "role": "user",
        "content": text,
        "timestamp": timestamp,
      });
      _controller.clear();
      isTyping = true;
    });

    _scrollToBottom();
    await _saveMessages();

    _bubbleAnimationController.reset();
    _bubbleAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    // Pass the entire message history to processMessage
    final response = await ChatbotService.processMessage(text, messages);

    setState(() {
      messages.add({
        "role": "bot",
        "content": response,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      isTyping = false;
    });

    await _saveMessages();
    _scrollToBottom();

    if (isSpeakingEnabled) {
      _speak(response);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void _startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => isListening = false);
          _micButtonController.reset();
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        setState(() => isListening = false);
        _micButtonController.reset();
      },
    );

    if (available) {
      FocusScope.of(context).unfocus();
      HapticFeedback.mediumImpact();

      setState(() => isListening = true);
      _micButtonController.repeat(reverse: true);

      speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
    _micButtonController.reset();
  }

  Future<void> _clearChat() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat History',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to clear all chat messages?',
            style: GoogleFonts.inter()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        elevation: 5,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                )),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text('Clear',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() => messages.clear());
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chatHistory');
      await prefs.remove('hasSeenWelcome');
      _checkAndAddWelcomeMessage();
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleSpeakEnabled() {
    setState(() {
      isSpeakingEnabled = !isSpeakingEnabled;
    });

    if (!isSpeakingEnabled) {
      flutterTts.stop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSpeakingEnabled
                  ? [AppColors.accent.withOpacity(0.8), AppColors.accent]
                  : [Colors.grey.shade700, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSpeakingEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isSpeakingEnabled
                    ? 'Auto-speech enabled'
                    : 'Auto-speech disabled',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat.jm().format(dateTime);
  }

  Widget _buildMessage(Map<String, dynamic> message, int index) {
    final isUser = message['role'] == 'user';
    final timestamp = message['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
    final timeString = _formatTimestamp(timestamp);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withBlue(200)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.health_and_safety_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(
                    left: isUser ? 64.0 : 0,
                    right: isUser ? 0 : 64.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isUser
                          ? [AppColors.accent, AppColors.accent.withBlue(200)]
                          : isDarkMode
                          ? [Color(0xFF2A2C35), Color(0xFF323440)]
                          : [Color(0xFFF0F4F9), Color(0xFFE6EBF5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isUser ? 18 : 4),
                      topRight: Radius.circular(isUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppColors.accent.withOpacity(0.3)
                            : AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['content'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.4,
                          color: isUser
                              ? Colors.white
                              : isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          timeString,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isUser
                                ? Colors.white70
                                : isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withBlue(200)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 4.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF2A2C35) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _speak(message['content'] ?? ''),
                      tooltip: 'Read aloud',
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF2A2C35) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message['content'] ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Copied to clipboard',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accent.withBlue(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              width: 32,
              height: 32,
              child: const Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Color(0xFF2A2C35), Color(0xFF323440)]
                    : [Color(0xFFF0F4F9), Color(0xFFE6EBF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'Typing...',
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    flutterTts.stop();
    speech.stop();
    _sendButtonController.dispose();
    _micButtonController.dispose();
    _bubbleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accent.withBlue(200)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(right: 10),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Text(
                'RoseBowl Nutrition',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isSpeakingEnabled ? Icons.volume_up : Icons.volume_off,
                  color: isSpeakingEnabled ? AppColors.accent : null,
                ),
                tooltip: "Toggle auto-speak",
                onPressed: _toggleSpeakEnabled,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: "Clear Chat",
                onPressed: _clearChat,
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Color(0xFF1A1C24), Color(0xFF242630)]
                  : [Color(0xFFF5F8FC), Color(0xFFEDF1F9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 40,
                          color: isDarkMode ? Colors.white30 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [Color(0xFF2A2C35), Color(0xFF323440)]
                                : [Color(0xFFF0F4F9), Color(0xFFE6EBF5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Ask anything about nutrition',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _buildTypingAnimation();
                    }
                    return _buildMessage(messages[index], index);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            _sendMessage(text);
                          }
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _micButtonController,
                      builder: (context, child) {
                        return Container(
                          height: 45,
                          width: 45,
                          margin: const EdgeInsets.only(left: 8.0),
                          decoration: BoxDecoration(
                            color: isListening
                                ? Colors.redAccent
                                : isDarkMode
                                ? AppColors.darkSecondarySurface
                                : AppColors.secondarySurface,
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: isListening
                                  ? Icon(
                                Icons.mic_off,
                                key: const ValueKey('mic_off'),
                                color: Colors.white,
                                size: 22,
                              )
                                  : Icon(
                                Icons.mic,
                                key: const ValueKey('mic_on'),
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                size: 22,
                              ),
                            ),
                            onPressed: () {
                              if (isListening) {
                                _stopListening();
                              } else {
                                _startListening();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _sendButtonController,
                      builder: (context, child) {
                        return Container(
                          height: 45,
                          width: 45,
                          margin: const EdgeInsets.only(left: 8.0),
                          decoration: BoxDecoration(
                            color: _controller.text.trim().isNotEmpty
                                ? AppColors.accent
                                : isDarkMode
                                ? AppColors.darkSecondarySurface
                                : AppColors.secondarySurface,
                            borderRadius: BorderRadius.circular(22.5),
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: _controller.text.trim().isEmpty
                                  ? Icon(
                                Icons.send,
                                key: const ValueKey('send_inactive'),
                                color: isDarkMode ? Colors.white38 : Colors.black38,
                                size: 22,
                              )
                                  : Icon(
                                Icons.send,
                                key: const ValueKey('send_active'),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                _sendMessage(_controller.text);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}