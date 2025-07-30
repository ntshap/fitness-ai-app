import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';

class EnhancedPosePainter extends CustomPainter {
  final List<KeyPoint> keyPoints;
  final int correctSquats;
  final int incorrectSquats;
  final String currentFeedback;
  final double currentKneeAngle;
  final bool isSquatting;
  final SquatPhase squatPhase;

  EnhancedPosePainter({
    required this.keyPoints,
    required this.correctSquats,
    required this.incorrectSquats,
    required this.currentFeedback,
    required this.currentKneeAngle,
    required this.isSquatting,
    required this.squatPhase,
  });

  // Enhanced pose connections for better skeletal visualization
  final List<List<int>> connections = [
    // Face connections
    [0, 1], [1, 3], [0, 2], [2, 4],
    // Torso connections  
    [5, 6], [5, 7], [7, 9], [6, 8], [8, 10],
    [5, 11], [6, 12], [11, 12],
    // Leg connections
    [11, 13], [13, 15], [12, 14], [14, 16]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawSkeleton(canvas, size);
    _drawKeyPoints(canvas, size);
    _drawSquatDepthIndicator(canvas, size);
    _drawKneeTrackingLines(canvas, size);
    _drawAngleDisplay(canvas, size);
  }

  void _drawSkeleton(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (var connection in connections) {
      if (connection[0] < keyPoints.length && connection[1] < keyPoints.length) {
        final p1 = keyPoints[connection[0]];
        final p2 = keyPoints[connection[1]];

        // Only draw if both points are detected with good confidence
        if (p1.score > 0.5 && p2.score > 0.5) {
          // Color-code based on current form
          if (_isLegConnection(connection)) {
            paint.color = _getLegConnectionColor();
          } else if (_isTorsoConnection(connection)) {
            paint.color = _getTorsoConnectionColor();
          } else {
            paint.color = Colors.white.withOpacity(0.8);
          }

          canvas.drawLine(
            Offset(p1.x * size.width, p1.y * size.height),
            Offset(p2.x * size.width, p2.y * size.height),
            paint,
          );
        }
      }
    }
  }

  void _drawKeyPoints(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i < keyPoints.length; i++) {
      final point = keyPoints[i];
      
      if (point.score > 0.5) {
        // Different colors for different body parts
        if (_isKeyJoint(i)) {
          paint.color = _getKeyJointColor(i);
        } else {
          paint.color = Colors.yellow.withOpacity(0.8);
        }

        final center = Offset(point.x * size.width, point.y * size.height);
        
        // Draw outer glow
        paint.color = paint.color.withOpacity(0.3);
        canvas.drawCircle(center, 8.0, paint);
        
        // Draw main point
        paint.color = _getKeyJointColor(i);
        canvas.drawCircle(center, 5.0, paint);
        
        // Draw inner highlight
        paint.color = Colors.white;
        canvas.drawCircle(center, 2.0, paint);
      }
    }
  }

  void _drawSquatDepthIndicator(Canvas canvas, Size size) {
    if (keyPoints.length < 17) return;
    
    final leftHip = keyPoints[11];
    final rightHip = keyPoints[12];
    final leftKnee = keyPoints[13];
    final rightKnee = keyPoints[14];
    
    if (leftHip.score > 0.5 && rightHip.score > 0.5 && 
        leftKnee.score > 0.5 && rightKnee.score > 0.5) {
      
      final hipY = ((leftHip.y + rightHip.y) / 2 * size.height);
      final kneeY = ((leftKnee.y + rightKnee.y) / 2 * size.height);
      
      // Draw depth zone indicator
      final paint = Paint()
        ..color = currentKneeAngle < 120 ? Colors.green : Colors.orange
        ..strokeWidth = 3.0;
      
      // Proper depth line
      final properDepthY = hipY + ((kneeY - hipY) * 0.8);
      canvas.drawLine(
        Offset(size.width * 0.1, properDepthY),
        Offset(size.width * 0.9, properDepthY),
        paint,
      );
      
      // Depth label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'PROPER DEPTH',
          style: TextStyle(
            color: paint.color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.1, properDepthY - 20));
    }
  }

  void _drawKneeTrackingLines(Canvas canvas, Size size) {
    if (keyPoints.length < 17) return;
    
    final leftKnee = keyPoints[13];
    final rightKnee = keyPoints[14];
    final leftAnkle = keyPoints[15];
    final rightAnkle = keyPoints[16];
    
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.blue.withOpacity(0.7);
    
    // Draw vertical reference lines from ankles
    if (leftKnee.score > 0.5 && leftAnkle.score > 0.5) {
      final ankleX = leftAnkle.x * size.width;
      final kneeX = leftKnee.x * size.width;
      
      // Reference line
      canvas.drawLine(
        Offset(ankleX, leftAnkle.y * size.height),
        Offset(ankleX, leftKnee.y * size.height),
        paint,
      );
      
      // Knee position indicator
      paint.color = kneeX > ankleX + 10 ? Colors.red : Colors.green;
      canvas.drawLine(
        Offset(kneeX, leftKnee.y * size.height),
        Offset(kneeX, leftKnee.y * size.height + 20),
        paint..strokeWidth = 4.0,
      );
    }
    
    if (rightKnee.score > 0.5 && rightAnkle.score > 0.5) {
      final ankleX = rightAnkle.x * size.width;
      final kneeX = rightKnee.x * size.width;
      
      paint.color = Colors.blue.withOpacity(0.7);
      paint.strokeWidth = 2.0;
      
      // Reference line
      canvas.drawLine(
        Offset(ankleX, rightAnkle.y * size.height),
        Offset(ankleX, rightKnee.y * size.height),
        paint,
      );
      
      // Knee position indicator
      paint.color = kneeX > ankleX + 10 ? Colors.red : Colors.green;
      canvas.drawLine(
        Offset(kneeX, rightKnee.y * size.height),
        Offset(kneeX, rightKnee.y * size.height + 20),
        paint..strokeWidth = 4.0,
      );
    }
  }

  void _drawAngleDisplay(Canvas canvas, Size size) {
    if (keyPoints.length < 17 || currentKneeAngle == 0) return;
    
    final rightKnee = keyPoints[14];
    if (rightKnee.score > 0.5) {
      final kneePos = Offset(rightKnee.x * size.width, rightKnee.y * size.height);
      
      // Angle display background
      final paint = Paint()
        ..color = Colors.black.withOpacity(0.6);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: kneePos.translate(30, -20), width: 60, height: 25),
          const Radius.circular(4),
        ),
        paint,
      );
      
      // Angle text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${currentKneeAngle.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, kneePos.translate(10, -30));
    }
  }

  bool _isLegConnection(List<int> connection) {
    final legJoints = [11, 12, 13, 14, 15, 16]; // Hips, knees, ankles
    return legJoints.contains(connection[0]) && legJoints.contains(connection[1]);
  }

  bool _isTorsoConnection(List<int> connection) {
    final torsoJoints = [5, 6, 11, 12]; // Shoulders and hips
    return torsoJoints.contains(connection[0]) && torsoJoints.contains(connection[1]);
  }

  bool _isKeyJoint(int index) {
    final keyJoints = [5, 6, 11, 12, 13, 14, 15, 16]; // Shoulders, hips, knees, ankles
    return keyJoints.contains(index);
  }

  Color _getLegConnectionColor() {
    if (currentFeedback.contains('Lower Your Hips')) return Colors.orange;
    if (currentFeedback.contains('Knees Falling Over Toe')) return Colors.red;
    if (isSquatting && currentKneeAngle < 120) return Colors.green;
    return Colors.cyan.withOpacity(0.8);
  }

  Color _getTorsoConnectionColor() {
    if (currentFeedback.contains('Bend Backwards')) return Colors.red;
    return Colors.blue.withOpacity(0.8);
  }

  Color _getKeyJointColor(int index) {
    // Color-code based on joint type and current form
    switch (index) {
      case 11: // Left hip
      case 12: // Right hip
        return currentFeedback.contains('Bend Backwards') ? Colors.red : Colors.blue;
      case 13: // Left knee
      case 14: // Right knee
        if (currentFeedback.contains('Knees Falling Over Toe')) return Colors.red;
        if (currentFeedback.contains('Lower Your Hips')) return Colors.orange;
        return isSquatting ? Colors.green : Colors.cyan;
      case 15: // Left ankle
      case 16: // Right ankle
        return Colors.purple;
      case 5: // Left shoulder
      case 6: // Right shoulder
        return currentFeedback.contains('Bend Backwards') ? Colors.red : Colors.blue;
      default:
        return Colors.yellow;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for real-time updates
  }
}
