import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static Future<String> sendMessage(String prompt) async {
    if (_apiKey.isEmpty) {
      return 'API key not found. Please check your configuration.';
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response received.';
      } else {
        // Hide all internal details on failure
        return 'Sorry, I couldn’t understand that. Please try again.';
      }
    } catch (e) {
      // Never print or return actual error in production
      return 'Network error. Please check your internet connection.';
    }
  }
}
