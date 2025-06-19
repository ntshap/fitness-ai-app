import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text('102 CAL', style: AppTextStyles.bodyRegular.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                maxY: 160,
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
    String text = '';
    switch (value.toInt()) {
      case 0: text = 'SUN'; break;
      case 1: text = 'MON'; break;
      case 2: text = 'TUE'; break;
      case 3: text = 'WED'; break;
      case 4: text = 'THU'; break;
      case 5: text = 'FRI'; break;
      case 6: text = 'SAT'; break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(text, style: AppTextStyles.chartLabels),
    );
  }
  
  List<BarChartGroupData> _getBarGroups() {
    final List<double> weeklyData = [40, 90, 140, 50, 110, 100, 30];
    return List.generate(weeklyData.length, (index) {
      final isToday = index == 2;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyData[index],
            color: isToday ? AppColors.primary : AppColors.background,
            width: 22,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }
}
