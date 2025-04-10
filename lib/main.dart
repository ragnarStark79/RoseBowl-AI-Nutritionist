import 'package:ai_nutritionist_flutter/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/calorie_tracker_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/diet_selector.dart';
import 'screens/saved_recipes_screen.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(AINutritionistApp(
    showOnboarding: !onboardingComplete,
    isDarkMode: isDarkMode,
  ));
}

class AINutritionistApp extends StatefulWidget {
  final bool showOnboarding;
  final bool isDarkMode;

  const AINutritionistApp({
    super.key,
    required this.showOnboarding,
    required this.isDarkMode,
  });

  @override
  State<AINutritionistApp> createState() => _AINutritionistAppState();
}

class _AINutritionistAppState extends State<AINutritionistApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Nutritionist',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      initialRoute: widget.showOnboarding ? '/onboarding' : '/',
      routes: {
        '/': (context) => HomeScreen(
          toggleTheme: _toggleTheme,
          isDarkMode: _isDarkMode,
        ),
        '/onboarding': (context) => const OnboardingScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/calorie-tracker': (context) => const CalorieTrackerScreen(),
        '/diet-selector': (context) => const DietSelector(),
        '/saved-recipes': (context) => const SavedRecipesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/meal-plan') {
          final args = settings.arguments;
          if (args != null &&
              args is Map<String, dynamic> &&
              args.containsKey('diet')) {
            return MaterialPageRoute(
              builder: (context) => MealPlanScreen(dietData: args),
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text(
                    'No diet data provided!',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
