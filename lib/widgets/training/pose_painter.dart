import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';

class PosePainter extends CustomPainter {
  final List<KeyPoint> keyPoints;

  PosePainter({required this.keyPoints});

  // Hubungan antar keypoint untuk menggambar "kerangka" tubuh
  final List<List<int>> connections = [
    // Garis Wajah
    [0, 1], [1, 3], [0, 2], [2, 4],
    // Garis Tubuh
    [5, 6], [5, 7], [7, 9], [6, 8], [8, 10],
    [5, 11], [6, 12], [11, 12],
    // Garis Kaki
    [11, 13], [13, 15], [12, 14], [14, 16]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Gambar garis koneksi dengan threshold yang lebih rendah untuk mock data
    for (var connection in connections) {
      if (connection[0] < keyPoints.length && connection[1] < keyPoints.length) {
        final p1 = keyPoints[connection[0]];
        final p2 = keyPoints[connection[1]];

        // Threshold lebih rendah untuk menampilkan mock keypoints
        if (p1.score > 0.3 && p2.score > 0.3) {
          canvas.drawLine(
            Offset(p1.x * size.width, p1.y * size.height),
            Offset(p2.x * size.width, p2.y * size.height),
            paint,
          );
        }
      }
    }

    // Gambar titik keypoint dengan threshold yang lebih rendah
    for (var point in keyPoints) {
      // Threshold lebih rendah untuk menampilkan mock keypoints  
      if (point.score > 0.3) {
        Color pointColor;
        if (point.score > 0.7) {
          pointColor = Colors.green; // AI detection
        } else {
          pointColor = Colors.yellow; // Mock keypoints
        }
        
        canvas.drawCircle(
          Offset(point.x * size.width, point.y * size.height),
          6.0,
          paint..color = pointColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
