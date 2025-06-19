import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class HistoryListItem extends StatelessWidget {
  final String date;
  final String time;
  final String totalSquats;
  final String caloriesBurned;
  final String duration;

  const HistoryListItem({
    super.key,
    required this.date,
    required this.time,
    required this.totalSquats,
    required this.caloriesBurned,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: AppTextStyles.headline2.copyWith(fontSize: 18),
              ),
              Text(
                time,
                style: AppTextStyles.bodyRegular,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.background),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total Squat', totalSquats, Icons.fitness_center),
              _buildStat('Kalori Terbakar', caloriesBurned, Icons.local_fire_department),
              _buildStat('Durasi', duration, Icons.timer_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headline2.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.metricLabel,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}