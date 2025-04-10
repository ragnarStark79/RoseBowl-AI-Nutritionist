import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MealPlanScreen extends StatefulWidget {
  final Map<String, dynamic> dietData;

  const MealPlanScreen({super.key, required this.dietData});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  List<dynamic> meals = [];
  bool isLoading = true;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchMealPlan();
  }

  Future<void> fetchMealPlan() async {
    final String diet = widget.dietData['diet'];
    final apiKey = dotenv.env['SPOONACULAR_API_KEY'];

    final url = Uri.parse(
      'https://api.spoonacular.com/mealplanner/generate?timeFrame=day&diet=$diet&apiKey=$apiKey&includeNutrition=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          meals = data['meals'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load meal plan');
      }
    } catch (e) {
      debugPrint('Error fetching meal plan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndShowRecipeDetails(int id) async {
    final apiKey = dotenv.env['SPOONACULAR_API_KEY'];
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$id/information?includeNutrition=true&apiKey=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final recipe = json.decode(response.body);
        showRecipePopup(recipe);
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      debugPrint('Error fetching recipe details: $e');
    }
  }

  void showRecipePopup(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(recipe['title'], style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(recipe['image']),
                ),
              const SizedBox(height: 10),
              Text(
                'Summary:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _removeHtmlTags(recipe['summary'] ?? 'No summary available.'),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              Text(
                'Ready in: ${recipe['readyInMinutes']} mins\nServings: ${recipe['servings']}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => speakText(recipe['summary']),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Speak'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => saveRecipe(recipe),
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _removeHtmlTags(String htmlString) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(regex, '');
  }

  Future<void> saveRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('savedRecipes') ?? [];

    // Avoid duplicate saves
    if (!savedList.contains(json.encode(recipe))) {
      savedList.add(json.encode(recipe));
      await prefs.setStringList('savedRecipes', savedList);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe already saved.')),
      );
    }
  }

  Future<void> speakText(String? htmlText) async {
    if (htmlText == null) return;
    final plainText = _removeHtmlTags(htmlText);
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(plainText);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String diet = widget.dietData['diet'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${diet[0].toUpperCase()}${diet.substring(1)} Meal Plan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.pushNamed(context, '/saved-recipes');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meals.isEmpty
          ? const Center(child: Text('No meals found.'))
          : ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: ListTile(
              title: Text(meal['title'],
                  style: GoogleFonts.poppins()),
              subtitle: Text(
                  'Ready in ${meal['readyInMinutes']} mins | ID: ${meal['id']}'),
              trailing:
              const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                fetchAndShowRecipeDetails(meal['id']);
              },
            ),
          );
        },
      ),
    );
  }
}
