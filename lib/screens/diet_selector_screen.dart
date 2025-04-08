import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DietSelectorScreen extends StatefulWidget {
  const DietSelectorScreen({super.key});

  @override
  State<DietSelectorScreen> createState() => _DietSelectorScreenState();
}

class _DietSelectorScreenState extends State<DietSelectorScreen> {
  final List<String> _diets = [
    "Vegetarian",
    "Vegan",
    "Pescetarian",
    "Keto",
    "Paleo",
    "Mediterranean",
    "Low-Carb",
    "Gluten-Free",
  ];

  String? _selectedDiet;

  void _onSelectDiet(String diet) {
    setState(() => _selectedDiet = diet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You selected $diet diet",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: Text(
          "Select Diet",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _diets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final diet = _diets[index];
          final isSelected = _selectedDiet == diet;

          return GestureDetector(
            onTap: () => _onSelectDiet(diet),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey.shade300,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.teal : Colors.grey,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    diet,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
