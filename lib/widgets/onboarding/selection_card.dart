import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 60, color: isSelected ? AppColors.primary : Colors.white),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: AppTextStyles.headline2.copyWith(
                fontSize: 16,
                color: isSelected ? AppColors.primary : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
