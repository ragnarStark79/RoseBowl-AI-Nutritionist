// lib/services/nutrition_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class NutritionService {
  static const String _baseUrl = 'https://api.spoonacular.com';
  final String _apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';

  Future<double?> convertToGrams(String amount, String sourceUnit) async {
    if (sourceUnit == 'grams') return double.tryParse(amount) ?? 1.0;

    final url = '$_baseUrl/recipes/convert?ingredientName=generic&sourceAmount=$amount&sourceUnit=$sourceUnit&targetUnit=grams&apiKey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      dev.log('Unit conversion response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['targetAmount'] as double? ?? double.tryParse(amount) ?? 1.0;
      }
      return double.tryParse(amount) ?? 1.0; // Fallback
    } catch (e) {
      dev.log('Error converting units: $e');
      return double.tryParse(amount) ?? 1.0; // Fallback
    }
  }

  Future<Map<String, dynamic>?> fetchNutrition(String food, String quantity, String unit) async {
    final url = '$_baseUrl/food/ingredients/search?query=$food&apiKey=$_apiKey';
    try {
      dev.log('Fetching ingredient ID for: $food');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        dev.log('Search failed with status: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      if (data['results'].isEmpty) {
        dev.log('No results found for: $food');
        return null;
      }

      final ingredientId = data['results'][0]['id'];
      final grams = await convertToGrams(quantity, unit) ?? 1.0;
      dev.log('Converted $quantity $unit to $grams grams');

      final nutritionUrl = '$_baseUrl/food/ingredients/$ingredientId/information?amount=$grams&unit=grams&apiKey=$_apiKey';
      final nutritionResponse = await http.get(Uri.parse(nutritionUrl));
      if (nutritionResponse.statusCode != 200) {
        dev.log('Nutrition fetch failed with status: ${nutritionResponse.statusCode} - ${nutritionResponse.body}');
        return null;
      }

      final nutritionData = jsonDecode(nutritionResponse.body);
      final nutrients = nutritionData['nutrition']['nutrients'] as List;
      dev.log('Nutrition data fetched successfully for $food');

      return {
        'calories': (nutrients.firstWhere((n) => n['name'] == 'Calories', orElse: () => {'amount': 0})['amount'] as num).toInt(),
        'protein': (nutrients.firstWhere((n) => n['name'] == 'Protein', orElse: () => {'amount': 0})['amount'] as num).toDouble(),
        'carbs': (nutrients.firstWhere((n) => n['name'] == 'Carbohydrates', orElse: () => {'amount': 0})['amount'] as num).toDouble(),
        'fat': (nutrients.firstWhere((n) => n['name'] == 'Fat', orElse: () => {'amount': 0})['amount'] as num).toDouble(),
      };
    } catch (e) {
      dev.log('Error fetching nutrition: $e');
      return null;
    }
  }
}