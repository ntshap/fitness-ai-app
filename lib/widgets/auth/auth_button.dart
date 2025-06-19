import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: AppTextStyles.headline2.copyWith(fontSize: 16),
      ),
      child: Text(text),
    );
  }
}
