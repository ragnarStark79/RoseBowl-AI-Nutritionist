import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Sorry, I couldn’t understand that. Please try again.';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }
}
