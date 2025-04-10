import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];

  int get _totalCalories =>
      _entries.fold(0, (sum, item) => sum + item['calories'] as int);

  void _addEntry() {
    final food = _foodController.text.trim();
    final calories = int.tryParse(_calorieController.text.trim());

    if (food.isEmpty || calories == null) return;

    setState(() {
      _entries.insert(0, {'food': food, 'calories': calories});
      _foodController.clear();
      _calorieController.clear();
    });
  }

  @override
  void dispose() {
    _foodController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  Widget _buildEntry(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_dining, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry['food'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          Text(
            '${entry['calories']} cal',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black87
          : const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: Text(
          'Calorie Tracker',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Total: $_totalCalories cal',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                _buildInputField(
                  controller: _foodController,
                  hint: 'Enter food item',
                  icon: Icons.fastfood_rounded,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _calorieController,
                  hint: 'Enter calories',
                  icon: Icons.local_fire_department_outlined,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _addEntry,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add Entry',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _entries.length,
              itemBuilder: (_, index) {
                return _buildEntry(_entries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
