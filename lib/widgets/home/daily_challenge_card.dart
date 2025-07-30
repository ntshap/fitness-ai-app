import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/training/training_screen.dart';

class DailyChallengeCard extends StatelessWidget {
  final String imagePath;
  const DailyChallengeCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate appropriate height based on available width
        final cardHeight = constraints.maxWidth > 0
            ? (constraints.maxWidth / (16 / 9)).clamp(120.0, 300.0)
            : 180.0;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: OverflowBox(
              maxHeight: cardHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Text content - takes most of the space
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'JUST LIKE\nYOUR LAST\nWORKOUT',
                            style: AppTextStyles.headline1.copyWith(
                              fontSize: (cardHeight * 0.12).clamp(14.0, 20.0),
                              height: 0.9,
                            ),
                          ),
                        ),
                        SizedBox(height: (cardHeight * 0.02).clamp(2.0, 8.0)),
                        Text(
                          '20 Squats for win',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: Colors.white70,
                            fontSize: (cardHeight * 0.08).clamp(9.0, 12.0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Button - fixed size at bottom
                  if (cardHeight > 100)
                    SizedBox(
                      height: (cardHeight * 0.15).clamp(24.0, 32.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrainingScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            size: (cardHeight * 0.08).clamp(12.0, 16.0),
                          ),
                          label: Text(
                            'Squats',
                            style: TextStyle(
                              fontSize: (cardHeight * 0.06).clamp(9.0, 12.0),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: (cardHeight * 0.04).clamp(6.0, 12.0),
                              vertical: 2,
                            ),
                            minimumSize: Size(0, (cardHeight * 0.15).clamp(24.0, 32.0)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
