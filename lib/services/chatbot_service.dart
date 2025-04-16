import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ChatbotService {
  static const String botName = 'Nutritionist Assistant';
  static const String botAvatar = 'assets/images/bot_avatar.png';

  static Future<String> processMessage(String userMessage, List<Map<String, dynamic>> chatHistory) async {
    final startTime = DateTime.now();

    try {
      String conversationHistory = '';
      for (var message in chatHistory) {
        final role = message['role'] == 'user' ? 'User' : 'Assistant';
        conversationHistory += '$role: ${message['content']}\n';
      }

      final prompt = '''
You are a professional nutritionist assistant named RoseBowl Nutrition.
Respond to user queries about nutrition, diet, healthy eating, and meal planning.
Be helpful, accurate, and concise. Limit responses to 3-4 sentences when possible.
Use the following conversation history to maintain context:
$conversationHistory
Current query: $userMessage
''';

      final response = await ApiService.sendMessageToGemini(prompt);

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      if (processingTime < 800) {
        await Future.delayed(Duration(milliseconds: 800 - processingTime));
      }

      return response;
    } catch (e) {
      debugPrint('ChatbotService Error: ${e.runtimeType}');
      return "I'm having trouble connecting right now. Please try again in a moment.";
    }
  }

  static bool isNutritionQuery(String message) {
    final keywords = [
      'food', 'diet', 'nutrition', 'eat', 'meal', 'calorie', 'protein',
      'carb', 'fat', 'vitamin', 'mineral', 'weight', 'healthy', 'recipe'
    ];
    message = message.toLowerCase();
    return keywords.any((keyword) => message.contains(keyword));
  }

  static String classifyMessageIntent(String message) {
    message = message.toLowerCase();
    if (message.contains('meal plan') || message.contains('diet plan')) {
      return 'meal_planning';
    } else if (message.contains('recipe') || message.contains('how to make')) {
      return 'recipe_request';
    } else if (message.contains('calorie') || message.contains('macros')) {
      return 'nutrition_info';
    } else if (message.contains('weight') || message.contains('lose') || message.contains('gain')) {
      return 'weight_management';
    } else {
      return 'general_nutrition';
    }
  }
}
