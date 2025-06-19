import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/main_screen.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.check_circle_outline_rounded,
                size: 120,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Profil Anda Siap!',
                style: AppTextStyles.headline1.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Kami telah mempersonalisasi program latihan berdasarkan data Anda.',
                style: AppTextStyles.bodyRegular.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AuthButton(
                text: 'Mulai Sekarang',
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}