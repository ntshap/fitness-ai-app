import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class StatsWidget extends StatelessWidget {
  final String value;
  final String label;

  const StatsWidget({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline2.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyRegular,
        ),
      ],
    );
  }
}
