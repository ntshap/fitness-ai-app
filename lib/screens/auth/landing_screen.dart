import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/auth/login_screen.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Konten utama
            Column(
              children: [
                const Spacer(flex: 1),
                Text(
                  'AI SQUAT TRAINER',
                  style: AppTextStyles.bodyRegular.copyWith(
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SEMPURNAKAN\nSQUAT ANDA. KAPAN\nPUN, DI MANA PUN.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline1.copyWith(
                    fontSize: 36,
                    height: 1.3,
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  height: size.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRotatedImage('assets/images/landing_1.png',-0.1),
                      _buildCenterImage('assets/images/landing_2.png'),
                      _buildRotatedImage('assets/images/landing_3.png', 0.1),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            // Tombol di bagian bawah
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: AuthButton(
                text: 'MULAI LATIHAN AI ANDA',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterImage(String path) {
    return Transform.scale(
      scale: 1.25,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(path, fit: BoxFit.cover, width: 140, height: 280),
        ),
      ),
    );
  }

  Widget _buildRotatedImage(String path, double rotation) {
     return Transform.rotate(
      angle: rotation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(path, fit: BoxFit.cover, width: 110, height: 220),
      ),
    );
  }
}