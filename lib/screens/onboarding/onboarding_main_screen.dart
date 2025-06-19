import 'package:flutter/material.dart';
import 'package:fitness_ai_app/screens/onboarding/gender_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/data_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/goals_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/success_screen.dart';

class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({super.key});

  @override
  State<OnboardingMainScreen> createState() => _OnboardingMainScreenState();
}

class _OnboardingMainScreenState extends State<OnboardingMainScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Menonaktifkan swipe
        children: [
          GenderScreen(onContinue: () => _nextPage()),
          DataScreen(onContinue: () => _nextPage()),
          GoalsScreen(onContinue: () => _nextPage()),
          const SuccessScreen(),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
