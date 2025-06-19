import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';

class DailyChallengeCard extends StatelessWidget {
  final String imagePath;
  const DailyChallengeCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withAlpha(230),
                Colors.black.withAlpha(102),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'JUST LIKE\nYOUR LAST\nWORKOUT',
                        style: AppTextStyles.headline1.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '20 Squats for win',
                      style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Squats'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
