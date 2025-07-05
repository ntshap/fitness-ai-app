import 'package:flutter/material.dart';
import 'package:fitness_ai_app/widgets/home/metric_card.dart';
import 'package:fitness_ai_app/widgets/home/weekly_chart.dart';
import 'package:fitness_ai_app/widgets/home/daily_challenge_card.dart';
import 'package:fitness_ai_app/widgets/shared/user_header.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/services/workout_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SimpleAuthService _authService = SimpleAuthService();
  final WorkoutService _workoutService = WorkoutService();
  Map<String, dynamic> _userStats = {
    'workoutCount': 0,
    'totalCalories': 0,
    'totalExercises': 0,
    'analysisCount': 0,
    'averageAccuracy': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use the new workout service for more accurate stats
      final stats = await _workoutService.getWorkoutStats();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshStats() async {
    await _loadUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _refreshStats,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UserHeader(),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(color: AppColors.primary),
                                    SizedBox(height: 16),
                                    Text(
                                      'Memuat statistik...',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  // First row of metrics
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MetricCard(
                                          icon: Icons.fitness_center,
                                          value: '${_userStats['workoutCount']}',
                                          label: 'WORKOUTS',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: MetricCard(
                                          icon: Icons.local_fire_department,
                                          value: '${_userStats['totalCalories']}',
                                          label: 'CAL BURN',
                                          unit: 'KCAL',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: MetricCard(
                                          icon: Icons.analytics,
                                          value: '${_userStats['analysisCount']}',
                                          label: 'AI ANALYSIS',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Second row of metrics
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MetricCard(
                                          icon: Icons.repeat,
                                          value: '${_userStats['totalExercises']}',
                                          label: 'EXERCISES',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: MetricCard(
                                          icon: Icons.trending_up,
                                          value: '${(_userStats['averageAccuracy'] as double).toStringAsFixed(1)}%',
                                          label: 'ACCURACY',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Empty space for symmetry
                                      const Expanded(child: SizedBox()),
                                    ],
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
              ),
            );
          },
        ),
      ),
    );
  }
}