import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/widgets/onboarding/onboarding_app_bar.dart';
import 'package:fitness_ai_app/widgets/onboarding/selection_card.dart';

class GoalsScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const GoalsScreen({super.key, required this.onContinue});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<String> _goals = [
    'Turunkan Berat Badan',
    'Bentuk Otot',
    'Jaga Kebugaran',
    'Tingkatkan Kekuatan',
    'Latihan Kardio',
    'Fleksibilitas'
  ];

  String? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OnboardingAppBar(currentStep: 3, totalSteps: 3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Apa Tujuan Utama Anda?',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih tujuan untuk personalisasi program latihan',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _goals.map((goal) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 32,
                        child: SelectionCard(
                          title: goal,
                          isSelected: _selectedGoal == goal,
                          onTap: () => setState(() => _selectedGoal = goal),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthButton(
                text: 'Selesai',
                onPressed: _selectedGoal != null ? widget.onContinue : () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
