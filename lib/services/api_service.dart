import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _geminiApiKey = dotenv.env['GEMINI_API_KEY']!;
  static final String _spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  static final String _geminiModelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_geminiApiKey';
  static const String _spoonacularBaseUrl = 'https://api.spoonacular.com';

  static Future<String> sendMessageToGemini(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_geminiModelUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            "No response from AI.";
      } else {
        return "Gemini Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect to Gemini: $e";
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMealPlan(
      {String diet = "vegetarian"}) async {
    final url =
        '$_spoonacularBaseUrl/mealplanner/generate?timeFrame=day&diet=$diet&apiKey=$_spoonacularApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['meals']);
      } else {
        throw Exception("Spoonacular Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch meal plan: $e");
    }
  }

  static Future<Map<String, dynamic>> fetchMealNutrition(int mealId) async {
    final url =
        '$_spoonacularBaseUrl/recipes/$mealId/nutritionWidget.json?apiKey=$_spoonacularApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Spoonacular Nutrition Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch nutrition: $e");
    }
  }
}
