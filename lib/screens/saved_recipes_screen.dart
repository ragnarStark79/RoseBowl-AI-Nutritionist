import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    loadSavedRecipes();
  }

  Future<void> loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('savedRecipes') ?? [];
    setState(() {
      savedRecipes = data.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    });
  }

  Future<void> deleteRecipe(int index) async {
    final prefs = await SharedPreferences.getInstance();
    savedRecipes.removeAt(index);
    final updated = savedRecipes.map((e) => json.encode(e)).toList();
    await prefs.setStringList('savedRecipes', updated);
    loadSavedRecipes();
  }

  void showRecipeDetails(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(recipe['title']),
        content: SingleChildScrollView(
          child: Column(
            children: [
              if (recipe['image'] != null)
                Image.network(recipe['image']),
              const SizedBox(height: 10),
              Text(recipe['summary'] ?? 'No details available'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Recipes')),
      body: savedRecipes.isEmpty
          ? const Center(child: Text("No saved recipes yet."))
          : ListView.builder(
        itemCount: savedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = savedRecipes[index];
          return ListTile(
            title: Text(recipe['title']),
            subtitle: Text(recipe['sourceName'] ?? 'Unknown'),
            leading: recipe['image'] != null
                ? Image.network(recipe['image'], width: 50, fit: BoxFit.cover)
                : null,
            onTap: () => showRecipeDetails(recipe),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => deleteRecipe(index),
            ),
          );
        },
      ),
    );
  }
}
