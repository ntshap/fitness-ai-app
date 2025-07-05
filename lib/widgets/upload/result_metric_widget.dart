import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class ResultMetricWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const ResultMetricWidget({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyRegular,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: color ?? AppColors.primary, size: 28),
              if (icon != null) const SizedBox(width: 8),
              Text(
                value,
                style: AppTextStyles.headline1.copyWith(
                  fontSize: 32,
                  color: color ?? Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}