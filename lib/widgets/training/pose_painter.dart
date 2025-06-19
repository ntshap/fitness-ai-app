import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<double?> keypoints;
  final Size originalImageSize;
  final Size canvasSize;

  PosePainter({
    required this.keypoints,
    required this.originalImageSize,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final connections = [
      // Torso
      [5, 6], [5, 11], [6, 12], [11, 12],
      // Arms
      [5, 7], [7, 9], [6, 8], [8, 10],
      // Legs
      [11, 13], [13, 15], [12, 14], [14, 16],
    ];

    // Menggambar garis penghubung (tulang)
    for (var connection in connections) {
      final p1Index = connection[0] * 3;
      final p2Index = connection[1] * 3;

      if (keypoints[p1Index + 2]! > 0.2 && keypoints[p2Index + 2]! > 0.2) {
        final p1 = _scalePoint(keypoints[p1Index]!, keypoints[p1Index + 1]!);
        final p2 = _scalePoint(keypoints[p2Index]!, keypoints[p2Index + 1]!);
        canvas.drawLine(p1, p2, paint);
      }
    }
    
    // Menggambar titik kunci (sendi)
    for (int i = 0; i < keypoints.length; i += 3) {
      if (keypoints[i + 2]! > 0.2) {
        final point = _scalePoint(keypoints[i]!, keypoints[i + 1]!);
        canvas.drawCircle(point, 6, paint);
      }
    }
  }

  Offset _scalePoint(double x, double y) {
    // Balik secara horizontal untuk efek cermin (kamera depan)
    final scaledX = (1 - x) * canvasSize.width;
    final scaledY = y * canvasSize.height;
    return Offset(scaledX, scaledY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
