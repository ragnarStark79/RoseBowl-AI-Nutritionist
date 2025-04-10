import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeStorageService {
  static const _key = 'saved_recipes';

  Future<void> saveRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipes = await getSavedRecipes();
    savedRecipes.add(recipe);
    await prefs.setString(_key, jsonEncode(savedRecipes));
  }

  Future<List<Map<String, dynamic>>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> removeRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipes = await getSavedRecipes();
    savedRecipes.removeWhere((r) => r['id'] == id);
    await prefs.setString(_key, jsonEncode(savedRecipes));
  }

  Future<bool> isRecipeSaved(int id) async {
    final saved = await getSavedRecipes();
    return saved.any((r) => r['id'] == id);
  }
}
