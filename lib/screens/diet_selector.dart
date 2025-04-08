import 'package:flutter/material.dart';

class DietSelector extends StatelessWidget {
  const DietSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final diets = ['balanced', 'vegetarian', 'vegan', 'keto', 'paleo'];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Diet')),
      body: ListView.builder(
        itemCount: diets.length,
        itemBuilder: (context, index) {
          final selectedDiet = diets[index];

          return ListTile(
            title: Text(
              selectedDiet[0].toUpperCase() + selectedDiet.substring(1),
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/meal-plan',
                arguments: {
                  'diet': selectedDiet,
                },
              );
            },
          );
        },
      ),
    );
  }
}
