import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Welcome to RoseBowl",
      "description": "Your smart assistant for healthy living and personalized nutrition."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Track & Analyze",
      "description": "Monitor calories, meals, and diets all in one powerful dashboard."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Ask Anything",
      "description": "Use the AI Chatbot for expert advice, food queries, and meal tips!"
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  Widget _buildPage(Map<String, String> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(data["image"]!, height: 300),
        const SizedBox(height: 40),
        Text(
          data["title"]!,
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            data["description"]!,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onboardingData.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.blueAccent : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text("Skip"),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildPage(onboardingData[index]),
              ),
            ),
            _buildDots(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? "Get Started"
                      : "Continue",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
