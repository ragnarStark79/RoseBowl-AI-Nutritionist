import 'package:flutter/material.dart';

class DietSelector extends StatelessWidget {
  final String selectedDiet;
  final ValueChanged<String> onDietSelected;

  const DietSelector({
    super.key,
    required this.selectedDiet,
    required this.onDietSelected,
  });

  final List<String> diets = const [
    'Any',
    'Vegan',
    'Keto',
    'Vegetarian',
    'High Protein',
    'Low Carb',
    'Paleo',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: diets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final diet = diets[index];
          final isSelected = selectedDiet == diet;
          return ChoiceChip(
            label: Text(diet),
            selected: isSelected,
            onSelected: (_) => onDietSelected(diet),
            selectedColor: Colors.teal.shade100,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
