import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool) toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: isDark ? Colors.white70 : Colors.black87),
            const SizedBox(width: 20),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black54),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoseBowl'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.toggleTheme,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F3F3),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'AI Nutritionist',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Smart. Simple. Nutritious.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const Spacer(),
            buildButton(
              label: "Chatbot",
              icon: Icons.chat_bubble_outline,
              onTap: () => Navigator.pushNamed(context, '/chatbot'),
            ),
            buildButton(
              label: "Meal Plan",
              icon: Icons.restaurant_menu_rounded,
              onTap: () => Navigator.pushNamed(context, '/diet-selector'),
            ),
            buildButton(
              label: "Calorie Tracker",
              icon: Icons.local_fire_department_outlined,
              onTap: () => Navigator.pushNamed(context, '/calorie-tracker'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
