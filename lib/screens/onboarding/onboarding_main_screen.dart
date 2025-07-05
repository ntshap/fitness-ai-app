import 'package:flutter/material.dart';
import 'package:fitness_ai_app/screens/onboarding/gender_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/data_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/goals_screen.dart';
import 'package:fitness_ai_app/screens/onboarding/success_screen.dart';

import 'package:fitness_ai_app/services/simple_auth_service.dart';

class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({super.key});

  @override
  State<OnboardingMainScreen> createState() => _OnboardingMainScreenState();
}

class _OnboardingMainScreenState extends State<OnboardingMainScreen> {
  final PageController _pageController = PageController();
  final SimpleAuthService _authService = SimpleAuthService();

  // Profile data collection
  String? _selectedGender;
  int _age = 25;
  double _height = 170;
  double _weight = 65;
  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Menonaktifkan swipe
        children: [
          GenderScreen(
            selectedGender: _selectedGender,
            onGenderSelected: (gender) => setState(() => _selectedGender = gender),
            onContinue: () => _nextPage(),
          ),
          DataScreen(
            age: _age,
            height: _height,
            weight: _weight,
            onAgeChanged: (age) => setState(() => _age = age.round()),
            onHeightChanged: (height) => setState(() => _height = height),
            onWeightChanged: (weight) => setState(() => _weight = weight),
            onContinue: () => _nextPage(),
          ),
          GoalsScreen(
            selectedGoal: _selectedGoal,
            onGoalSelected: (goal) => setState(() => _selectedGoal = goal),
            onContinue: () => _saveProfileAndContinue(),
          ),
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

  Future<void> _saveProfileAndContinue() async {
    // Save profile data to database
    if (_authService.isLoggedIn && _selectedGender != null && _selectedGoal != null) {
      final profileData = {
        'gender': _selectedGender,
        'age': _age,
        'height': _height,
        'weight': _weight,
        'fitness_goal': _selectedGoal,
      };

      print('Saving profile data: $profileData'); // Debug
      final result = await _authService.updateUserProfile(profileData);
      print('Profile save result: $result'); // Debug
    }

    _nextPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
