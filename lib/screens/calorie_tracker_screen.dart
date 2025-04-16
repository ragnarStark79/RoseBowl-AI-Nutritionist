import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/nutrition_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'history_screen.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];
  List<String> _foodSuggestions = [];
  String _selectedUnit = 'grams';
  final List<String> _units = ['grams', 'ounces', 'cups'];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final NutritionService _nutritionService = NutritionService();
  late GlobalKey<SliverAnimatedListState> _listKey; // Updated to SliverAnimatedListState

  int get _totalCalories =>
      _entries.fold(0, (sum, item) => sum + (item['nutrition']['calories'] as int));

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<SliverAnimatedListState>(); // Initialize for SliverAnimatedList
    _loadEntries();
    _foodController.addListener(_fetchFoodSuggestions);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutQuint);
    _animationController.forward();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEntries = prefs.getString('calorieEntries');
    if (savedEntries != null) {
      setState(() {
        _entries.addAll(
          (jsonDecode(savedEntries) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calorieEntries', jsonEncode(_entries));
  }

  Future<void> _fetchFoodSuggestions() async {
    final query = _foodController.text.trim();
    debugPrint('Fetching suggestions for query: "$query"');
    if (query.length < 2) {
      setState(() => _foodSuggestions = []);
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/food/ingredients/autocomplete?query=$query&number=5&apiKey=${dotenv.env['SPOONACULAR_API_KEY']!}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _foodSuggestions = data.map((item) => item['name'] as String).toList();
        });
      } else {
        debugPrint('Autocomplete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
    }
  }

  void _addEntry() async {
    final food = _foodController.text.trim();
    final quantity = _quantityController.text.trim();

    if (food.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both food and quantity.',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final quantityNum = double.tryParse(quantity);
    if (quantityNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid quantity number.',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final nutrition = await _nutritionService.fetchNutrition(food, quantity, _selectedUnit);
    setState(() => _isLoading = false);

    if (nutrition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch nutrition data. Check your input or API key.',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final newEntry = {
      'food': food,
      'quantity': '$quantity $_selectedUnit',
      'nutrition': nutrition,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 600));
    setState(() => _entries.insert(0, newEntry));
    _foodController.clear();
    _quantityController.clear();
    await _saveEntries();
    FocusScope.of(context).unfocus(); // Dismiss the keyboard after adding entry
  }

  void _deleteEntry(int index) async {
    final removedItem = _entries[index];
    _entries.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: const Duration(milliseconds: 600),
    );
    await _saveEntries();
  }

  Widget _buildRemovedItem(Map<String, dynamic> item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red.withOpacity(0.1),
        ),
        child: ListTile(
          title: Text(item['food'], style: GoogleFonts.poppins(color: Colors.redAccent)),
          trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
        ),
      ),
    );
  }

  Future<void> _clearAllEntries() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Entries', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to clear all calorie entries?', style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() => _entries.clear());
      await _saveEntries();
    }
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen(entries: _entries)),
    );
  }

  @override
  void dispose() {
    _foodController.removeListener(_fetchFoodSuggestions);
    _foodController.dispose();
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildEntry(BuildContext context, int index, Animation<double> animation) {
    final entry = _entries[index];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final nutrition = entry['nutrition'] as Map<String, dynamic>;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuint)),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF2D3250), const Color(0xFF424769)]
                    : [Colors.white, const Color(0xFFF8FBFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: Colors.transparent,
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7BD389), Color(0xFF4CAF50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.local_dining, color: Colors.white, size: 24),
                  ),
                  title: Text(
                    entry['food'],
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A3C34),
                    ),
                  ),
                  subtitle: Text(
                    entry['quantity'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF5E7C6B),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${nutrition['calories']} cal',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 24),
                        color: Colors.redAccent,
                        onPressed: () => _deleteEntry(index),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          _buildNutritionRow('Protein', '${nutrition['protein']}g'),
                          const SizedBox(height: 12),
                          _buildNutritionRow('Carbs', '${nutrition['carbs']}g'),
                          const SizedBox(height: 12),
                          _buildNutritionRow('Fat', '${nutrition['fat']}g'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FBFE), const Color(0xFFE6F4F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: height * 0.18,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Calorie Tracker',
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A3C34))),
                  background: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFE6F4F1), const Color(0xFFD0E8E4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history_toggle_off),
                    color: const Color(0xFF4CAF50),
                    onPressed: _showHistory,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    color: Colors.redAccent,
                    onPressed: _clearAllEntries,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7BD389).withOpacity(0.15),
                          const Color(0xFF4CAF50).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Calories',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : const Color(0xFF1A3C34))),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text('$_totalCalories cal',
                              key: ValueKey<int>(_totalCalories),
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4CAF50))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _foodController,
                        hint: 'Search food...',
                        icon: Icons.search,
                        suggestions: _foodSuggestions,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _quantityController,
                              hint: 'Quantity',
                              icon: Icons.monitor_weight_outlined,
                              inputType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7BD389), Color(0xFF4CAF50)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedUnit,
                                items: _units
                                    .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14, color: Colors.white)),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) setState(() => _selectedUnit = value);
                                },
                                dropdownColor: const Color(0xFF4CAF50),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.95, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, value, child) => Transform.scale(
                            scale: value,
                            child: child,
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addEntry,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text('Add Entry',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: _entries.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: Text('Start tracking your nutrition!',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF5E7C6B))),
                  ),
                )
                    : SliverAnimatedList(
                  key: _listKey,
                  initialItemCount: _entries.length,
                  itemBuilder: (context, index, animation) =>
                      _buildEntry(context, index, animation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    List<String> suggestions = const [],
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty || suggestions.isEmpty) return const Iterable<String>.empty();
        return suggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        controller.text = selection;
        setState(() => _foodSuggestions = []);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: inputType,
          style: GoogleFonts.poppins(fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF1A3C34)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D3250) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option,
                        style: GoogleFonts.poppins(
                            color: isDarkMode ? Colors.white : const Color(0xFF1A3C34))),
                    onTap: () => onSelected(option),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}