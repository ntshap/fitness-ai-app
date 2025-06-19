import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingAppBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'Langkah $currentStep dari $totalSteps',
        style: AppTextStyles.bodyRegular,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
