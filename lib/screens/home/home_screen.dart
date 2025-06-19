import 'package:flutter/material.dart';
import 'package:fitness_ai_app/widgets/home/metric_card.dart';
import 'package:fitness_ai_app/widgets/home/weekly_chart.dart';
import 'package:fitness_ai_app/widgets/home/daily_challenge_card.dart';
import 'package:fitness_ai_app/widgets/shared/user_header.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const UserHeader(
                        userName: 'CAROLINA REAPER',
                        profileImagePath: 'assets/images/user_profile.png',
                      ),
                      const SizedBox(height: 30),
                      const Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              icon: Icons.fitness_center,
                              value: '55',
                              label: 'SQUATS',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.local_fire_department,
                              value: '3.115',
                              label: 'CAL BURN',
                              unit: 'KCAL',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.favorite,
                              value: '123',
                              label: 'HEARTBEAT',
                              unit: 'BPM',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const WeeklyChart(),
                      const SizedBox(height: 30),
                      Text(
                        'DAILY CHALLENGES',
                        style: AppTextStyles.bodyRegular.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const DailyChallengeCard(
                        imagePath: 'assets/images/squat_challenge.png',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}