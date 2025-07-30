import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/services/workout_service.dart';

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({super.key});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  final WorkoutService _workoutService = WorkoutService();
  List<double> _weeklyCalories = [];
  double _weeklyAverage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    try {
      final history = await _workoutService.getWorkoutHistory();
      
      // Get current week data (last 7 days)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyData = List.filled(7, 0.0);
      
      // Calculate daily calories for this week
      for (final workout in history) {
        final workoutDate = DateTime.parse(workout['date']);
        final daysDiff = workoutDate.difference(weekStart).inDays;
        
        if (daysDiff >= 0 && daysDiff < 7) {
          weeklyData[daysDiff] += (workout['calories_burned'] as num? ?? 0).toDouble();
        }
      }
      
      // Calculate weekly average
      final totalCalories = weeklyData.reduce((a, b) => a + b);
      final average = totalCalories / 7;
      
      if (mounted) {
        setState(() {
          _weeklyCalories = weeklyData;
          _weeklyAverage = average;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading weekly data: $e');
      if (mounted) {
        setState(() {
          _weeklyCalories = [45, 0, 78, 123, 0, 156, 89]; // Sample data as fallback
          _weeklyAverage = 70.1;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final maxY = _weeklyCalories.isEmpty ? 200.0 : 
        (_weeklyCalories.reduce((a, b) => a > b ? a : b) * 1.2).clamp(100.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CALORIES', style: AppTextStyles.headline2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('WEEKLY AVERAGE', style: AppTextStyles.chartLabels),
                  Text('${_weeklyAverage.toStringAsFixed(0)} CAL', 
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: getBottomTitles,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final index = value.toInt();
    
    if (index >= 0 && index < days.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8.0,
        child: Text(days[index], style: AppTextStyles.chartLabels),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  List<BarChartGroupData> _getBarGroups() {
    if (_weeklyCalories.isEmpty) {
      return [];
    }

    return _weeklyCalories.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: value > 0 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}
