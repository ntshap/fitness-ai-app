import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/history/history_list_item.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Data dummy untuk riwayat latihan
  final List<Map<String, String>> historyData = const [
    {
      "date": "12 Juni 2025",
      "time": "08:15",
      "totalSquats": "55",
      "caloriesBurned": "32 kkal",
      "duration": "5m 30d"
    },
    {
      "date": "11 Juni 2025",
      "time": "17:30",
      "totalSquats": "70",
      "caloriesBurned": "45 kkal",
      "duration": "7m 10d"
    },
    {
      "date": "10 Juni 2025",
      "time": "08:00",
      "totalSquats": "50",
      "caloriesBurned": "30 kkal",
      "duration": "5m 02d"
    },
    {
      "date": "09 Juni 2025",
      "time": "18:00",
      "totalSquats": "65",
      "caloriesBurned": "41 kkal",
      "duration": "6m 45d"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Latihan', style: AppTextStyles.headline1),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final item = historyData[index];
          return HistoryListItem(
            date: item['date']!,
            time: item['time']!,
            totalSquats: item['totalSquats']!,
            caloriesBurned: item['caloriesBurned']!,
            duration: item['duration']!,
          );
        },
      ),
    );
  }
}
