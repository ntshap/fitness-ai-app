import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/widgets/onboarding/onboarding_app_bar.dart';
import 'package:fitness_ai_app/widgets/onboarding/selection_card.dart';

class GenderScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const GenderScreen({super.key, required this.onContinue});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  int? _selectedGender; // 0 for male, 1 for female

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OnboardingAppBar(currentStep: 1, totalSteps: 3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Beri Tahu Kami Tentang Anda',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk memberikan pengalaman yang lebih personal',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SelectionCard(
                      title: 'Pria',
                      icon: Icons.male,
                      isSelected: _selectedGender == 0,
                      onTap: () => setState(() => _selectedGender = 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SelectionCard(
                      title: 'Wanita',
                      icon: Icons.female,
                      isSelected: _selectedGender == 1,
                      onTap: () => setState(() => _selectedGender = 1),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AuthButton(
                text: 'Lanjut',
                onPressed: _selectedGender != null ? widget.onContinue : () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
