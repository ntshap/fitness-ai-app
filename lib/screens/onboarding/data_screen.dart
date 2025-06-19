import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/widgets/onboarding/onboarding_app_bar.dart';
import 'package:fitness_ai_app/widgets/onboarding/data_slider.dart';

class DataScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const DataScreen({super.key, required this.onContinue});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  double _age = 25;
  double _height = 170;
  double _weight = 65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OnboardingAppBar(currentStep: 2, totalSteps: 3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Detail Fisik Anda',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ini membantu kami menghitung kalori yang terbakar',
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              DataSlider(
                label: 'Usia',
                value: _age,
                min: 15,
                max: 80,
                divisions: 65,
                unit: 'tahun',
                onChanged: (value) => setState(() => _age = value),
              ),
              const SizedBox(height: 24),
               DataSlider(
                label: 'Tinggi Badan',
                value: _height,
                min: 140,
                max: 220,
                divisions: 80,
                unit: 'cm',
                onChanged: (value) => setState(() => _height = value),
              ),
               const SizedBox(height: 24),
               DataSlider(
                label: 'Berat Badan',
                value: _weight,
                min: 40,
                max: 150,
                divisions: 110,
                unit: 'kg',
                onChanged: (value) => setState(() => _weight = value),
              ),
              const Spacer(),
              AuthButton(
                text: 'Lanjut',
                onPressed: widget.onContinue,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}