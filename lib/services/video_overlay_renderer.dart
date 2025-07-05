import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';

class OverlayConfig {
  final bool showPoseLandmarks;
  final bool showSkeleton;
  final bool showRepCounter;
  final bool showFormFeedback;
  final bool showAngles;
  final bool showDepthZone;
  final bool showKneeTracking;
  final bool showBackPosture;
  final bool showRealtimeFeedback;
  final img.Color goodDetectionColor;
  final img.Color poorDetectionColor;
  final img.Color correctFormColor;
  final img.Color incorrectFormColor;
  final img.Color neutralColor;
  final img.Color backgroundOverlayColor;
  final int fontSize;
  final int largeFontSize;
  final int jointRadius;
  final int skeletonThickness;

  OverlayConfig({
    this.showPoseLandmarks = true,
    this.showSkeleton = true,
    this.showRepCounter = true,
    this.showFormFeedback = true,
    this.showAngles = true,
    this.showDepthZone = true,
    this.showKneeTracking = true,
    this.showBackPosture = true,
    this.showRealtimeFeedback = true,
    img.Color? goodDetectionColor,
    img.Color? poorDetectionColor,
    img.Color? correctFormColor,
    img.Color? incorrectFormColor,
    img.Color? neutralColor,
    img.Color? backgroundOverlayColor,
    this.fontSize = 20,
    this.largeFontSize = 28,
    this.jointRadius = 8,
    this.skeletonThickness = 4,
  }) : goodDetectionColor = goodDetectionColor ?? img.ColorRgb8(0, 255, 0), // Green
       poorDetectionColor = poorDetectionColor ?? img.ColorRgb8(255, 0, 0), // Red
       correctFormColor = correctFormColor ?? img.ColorRgb8(0, 255, 0), // Green
       incorrectFormColor = incorrectFormColor ?? img.ColorRgb8(255, 0, 0), // Red
       neutralColor = neutralColor ?? img.ColorRgb8(255, 255, 0), // Yellow
       backgroundOverlayColor = backgroundOverlayColor ?? img.ColorRgb8(0, 0, 0); // Black
}

class VideoOverlayRenderer {
  static final VideoOverlayRenderer _instance = VideoOverlayRenderer._internal();
  factory VideoOverlayRenderer() => _instance;
  VideoOverlayRenderer._internal();

  // Pose connections for drawing skeleton
  static const List<List<int>> poseConnections = [
    // Face
    [0, 1], [1, 3], [0, 2], [2, 4],
    // Body
    [5, 6], [5, 7], [7, 9], [6, 8], [8, 10],
    [5, 11], [6, 12], [11, 12],
    // Legs
    [11, 13], [13, 15], [12, 14], [14, 16]
  ];

  /// Render professional fitness analysis overlays on a single frame
  img.Image renderFrameOverlays(
    img.Image frame,
    List<KeyPoint>? keyPoints,
    SquatRepData? currentRep,
    int totalReps,
    int correctReps,
    double timestamp, {
    OverlayConfig? config,
  }) {
    config ??= OverlayConfig();

    // Create a copy of the frame to avoid modifying the original
    final overlayFrame = img.Image.from(frame);

    if (keyPoints != null && keyPoints.isNotEmpty) {
      // Draw squat depth zone overlay
      if (config.showDepthZone) {
        _drawSquatDepthZone(overlayFrame, keyPoints, currentRep, config);
      }

      // Draw knee tracking lines
      if (config.showKneeTracking) {
        _drawKneeTrackingLines(overlayFrame, keyPoints, config);
      }

      // Draw back posture indicators
      if (config.showBackPosture) {
        _drawBackPostureIndicators(overlayFrame, keyPoints, config);
      }

      // Draw professional skeleton overlay
      if (config.showSkeleton) {
        _drawProfessionalSkeleton(overlayFrame, keyPoints, config);
      }

      // Draw enhanced pose landmarks
      if (config.showPoseLandmarks) {
        _drawEnhancedPoseLandmarks(overlayFrame, keyPoints, config);
      }

      // Draw joint angle measurements
      if (config.showAngles) {
        _drawJointAngleMeasurements(overlayFrame, keyPoints, config);
      }
    }

    // Draw professional HUD elements
    _drawProfessionalHUD(overlayFrame, totalReps, correctReps, currentRep, timestamp, config);

    // Draw real-time feedback overlays
    if (config.showRealtimeFeedback && currentRep != null) {
      _drawRealtimeFeedbackOverlays(overlayFrame, currentRep, config);
    }

    return overlayFrame;
  }

  /// Draw pose landmarks as circles
  void _drawPoseLandmarks(
    img.Image frame,
    List<KeyPoint> keyPoints,
    OverlayConfig config,
  ) {
    for (int i = 0; i < keyPoints.length; i++) {
      final point = keyPoints[i];
      
      if (point.score > 0.5) {
        final x = (point.x * frame.width).round();
        final y = (point.y * frame.height).round();
        
        // Draw circle for landmark
        _drawCircle(frame, x, y, 6, config.goodDetectionColor);
        
        // Draw smaller inner circle for better visibility
        _drawCircle(frame, x, y, 3, img.ColorRgb8(255, 255, 255));
      }
    }
  }

  /// Draw skeleton connections between landmarks
  void _drawSkeleton(
    img.Image frame,
    List<KeyPoint> keyPoints,
    OverlayConfig config,
  ) {
    for (final connection in poseConnections) {
      if (connection[0] < keyPoints.length && connection[1] < keyPoints.length) {
        final point1 = keyPoints[connection[0]];
        final point2 = keyPoints[connection[1]];
        
        if (point1.score > 0.5 && point2.score > 0.5) {
          final x1 = (point1.x * frame.width).round();
          final y1 = (point1.y * frame.height).round();
          final x2 = (point2.x * frame.width).round();
          final y2 = (point2.y * frame.height).round();
          
          _drawLine(frame, x1, y1, x2, y2, config.goodDetectionColor, 3);
        }
      }
    }
  }

  /// Draw angle indicators for knee and hip
  void _drawAngleIndicators(
    img.Image frame,
    List<KeyPoint> keyPoints,
    OverlayConfig config,
  ) {
    if (keyPoints.length < 17) return;

    // Draw knee angle
    final hip = keyPoints[12]; // Right hip
    final knee = keyPoints[14]; // Right knee
    final ankle = keyPoints[16]; // Right ankle

    if (hip.score > 0.5 && knee.score > 0.5 && ankle.score > 0.5) {
      final angle = _calculateAngle(hip, knee, ankle);
      final kneeX = (knee.x * frame.width).round();
      final kneeY = (knee.y * frame.height).round();
      
      _drawText(frame, '${angle.round()}°', kneeX + 10, kneeY - 10, config);
    }
  }

  /// Draw repetition counter
  void _drawRepCounter(
    img.Image frame,
    int totalReps,
    int correctReps,
    OverlayConfig config,
  ) {
    final text = 'Reps: $totalReps | Correct: $correctReps';
    _drawText(frame, text, 20, 40, config);
  }

  /// Draw form feedback for current repetition
  void _drawFormFeedback(
    img.Image frame,
    SquatRepData currentRep,
    OverlayConfig config,
  ) {
    final color = currentRep.isCorrect ? config.correctFormColor : config.incorrectFormColor;
    final status = currentRep.isCorrect ? 'GOOD FORM' : 'CHECK FORM';
    
    // Draw form status
    _drawText(frame, status, 20, frame.height - 80, config, color: color);
    
    // Draw specific form issues
    if (currentRep.formIssues.isNotEmpty) {
      int yOffset = frame.height - 50;
      for (final issue in currentRep.formIssues) {
        final issueText = _getFormIssueText(issue);
        _drawText(frame, issueText, 20, yOffset, config, color: config.incorrectFormColor);
        yOffset += 25;
      }
    }
  }

  /// Draw timestamp on frame
  void _drawTimestamp(
    img.Image frame,
    double timestamp,
    OverlayConfig config,
  ) {
    final minutes = (timestamp / 60).floor();
    final seconds = (timestamp % 60).floor();
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    _drawText(frame, timeText, frame.width - 100, 40, config);
  }

  /// Helper method to draw a circle
  void _drawCircle(img.Image frame, int centerX, int centerY, int radius, img.Color color) {
    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) {
          final pixelX = centerX + x;
          final pixelY = centerY + y;
          
          if (pixelX >= 0 && pixelX < frame.width && pixelY >= 0 && pixelY < frame.height) {
            frame.setPixel(pixelX, pixelY, color);
          }
        }
      }
    }
  }

  /// Helper method to draw a line
  void _drawLine(img.Image frame, int x1, int y1, int x2, int y2, img.Color color, int thickness) {
    final dx = (x2 - x1).abs();
    final dy = (y2 - y1).abs();
    final sx = x1 < x2 ? 1 : -1;
    final sy = y1 < y2 ? 1 : -1;
    int err = dx - dy;

    int x = x1;
    int y = y1;

    while (true) {
      // Draw thick line by drawing multiple pixels
      for (int i = -thickness ~/ 2; i <= thickness ~/ 2; i++) {
        for (int j = -thickness ~/ 2; j <= thickness ~/ 2; j++) {
          final pixelX = x + i;
          final pixelY = y + j;
          
          if (pixelX >= 0 && pixelX < frame.width && pixelY >= 0 && pixelY < frame.height) {
            frame.setPixel(pixelX, pixelY, color);
          }
        }
      }

      if (x == x2 && y == y2) break;
      
      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x += sx;
      }
      if (e2 < dx) {
        err += dx;
        y += sy;
      }
    }
  }

  /// Helper method to draw text (simplified implementation)
  void _drawText(
    img.Image frame,
    String text,
    int x,
    int y,
    OverlayConfig config, {
    img.Color? color,
  }) {
    color ??= img.ColorRgb8(255, 255, 255);
    
    // This is a very basic text rendering - in production, you'd want to use
    // a proper font rendering library or pre-rendered text images
    img.drawString(frame, text, font: img.arial24, x: x, y: y, color: color);
  }

  /// Calculate angle between three points
  double _calculateAngle(KeyPoint p1, KeyPoint p2, KeyPoint p3) {
    final v1x = p1.x - p2.x;
    final v1y = p1.y - p2.y;
    final v2x = p3.x - p2.x;
    final v2y = p3.y - p2.y;

    final dot = v1x * v2x + v1y * v2y;
    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);

    if (mag1 == 0 || mag2 == 0) return 0.0;

    final cosAngle = dot / (mag1 * mag2);
    final angle = acos(cosAngle.clamp(-1.0, 1.0)) * 180 / pi;

    return angle;
  }

  /// Get human-readable text for form issues
  String _getFormIssueText(SquatFormIssue issue) {
    switch (issue) {
      case SquatFormIssue.kneeOverToe:
        return 'Knee over toe';
      case SquatFormIssue.insufficientDepth:
        return 'Go deeper';
      case SquatFormIssue.backRounding:
        return 'Keep back straight';
      case SquatFormIssue.kneeCollapse:
        return 'Keep knees out';
      case SquatFormIssue.heelLift:
        return 'Keep heels down';
    }
  }

  // ===== PROFESSIONAL OVERLAY METHODS =====

  /// Draw enhanced pose landmarks with professional quality indicators
  void _drawEnhancedPoseLandmarks(img.Image frame, List<KeyPoint> keyPoints, OverlayConfig config) {
    for (int i = 0; i < keyPoints.length; i++) {
      final point = keyPoints[i];
      final x = (point.x * frame.width).round();
      final y = (point.y * frame.height).round();

      // Determine color based on detection confidence
      img.Color landmarkColor;
      if (point.score > 0.8) {
        landmarkColor = config.goodDetectionColor; // Green for excellent detection
      } else if (point.score > 0.5) {
        landmarkColor = config.neutralColor; // Yellow for good detection
      } else {
        landmarkColor = config.poorDetectionColor; // Red for poor detection
      }

      // Draw outer glow effect for better visibility
      _drawCircle(frame, x, y, config.jointRadius + 2,
          img.ColorRgb8((landmarkColor.r * 0.7).round(), (landmarkColor.g * 0.7).round(), (landmarkColor.b * 0.7).round()));

      // Draw main landmark circle
      _drawCircle(frame, x, y, config.jointRadius, landmarkColor);

      // Draw inner highlight for 3D effect
      _drawCircle(frame, x, y, config.jointRadius - 3, img.ColorRgb8(255, 255, 255));

      // Draw confidence indicator for key joints
      if (_isKeyJoint(point, i) && point.score > 0.5) {
        _drawConfidenceIndicator(frame, x, y, point.score, config);
      }
    }
  }

  /// Check if a keypoint is a key joint for squat analysis (by index)
  bool _isKeyJoint(KeyPoint point, int index) {
    // Key joint indices for squat analysis: shoulders, hips, knees, ankles
    final keyJointIndices = [5, 6, 11, 12, 13, 14, 15, 16];
    return keyJointIndices.contains(index);
  }

  /// Draw confidence indicator near key joints
  void _drawConfidenceIndicator(img.Image frame, int x, int y, double confidence, OverlayConfig config) {
    final confidenceText = '${(confidence * 100).round()}%';
    final textX = x + config.jointRadius + 5;
    final textY = y - config.fontSize ~/ 2;

    // Draw confidence percentage with proper color
    _drawText(frame, confidenceText, textX, textY, config);
  }

  /// Draw professional skeleton with enhanced visual quality
  void _drawProfessionalSkeleton(img.Image frame, List<KeyPoint> keyPoints, OverlayConfig config) {
    for (final connection in poseConnections) {
      if (connection[0] < keyPoints.length && connection[1] < keyPoints.length) {
        final point1 = keyPoints[connection[0]];
        final point2 = keyPoints[connection[1]];

        // Only draw if both points are confident
        if (point1.score > 0.5 && point2.score > 0.5) {
          final x1 = (point1.x * frame.width).round();
          final y1 = (point1.y * frame.height).round();
          final x2 = (point2.x * frame.width).round();
          final y2 = (point2.y * frame.height).round();

          // Determine line color based on average confidence
          final avgConfidence = (point1.score + point2.score) / 2;
          img.Color lineColor;
          if (avgConfidence > 0.8) {
            lineColor = config.goodDetectionColor;
          } else if (avgConfidence > 0.6) {
            lineColor = config.neutralColor;
          } else {
            lineColor = config.poorDetectionColor;
          }

          // Draw shadow line for depth effect
          _drawLine(frame, x1 + 2, y1 + 2, x2 + 2, y2 + 2,
                   img.ColorRgba8(0, 0, 0, 100), config.skeletonThickness);

          // Draw main skeleton line
          _drawLine(frame, x1, y1, x2, y2, lineColor, config.skeletonThickness);
        }
      }
    }
  }

  /// Draw squat depth zone overlay
  void _drawSquatDepthZone(img.Image frame, List<KeyPoint> keyPoints, SquatRepData? currentRep, OverlayConfig config) {
    // Find hip and knee positions
    final leftHip = _findKeyPoint(keyPoints, 'left_hip');
    final rightHip = _findKeyPoint(keyPoints, 'right_hip');
    final leftKnee = _findKeyPoint(keyPoints, 'left_knee');
    final rightKnee = _findKeyPoint(keyPoints, 'right_knee');

    if (leftHip != null && rightHip != null && leftKnee != null && rightKnee != null) {
      final hipY = ((leftHip.y + rightHip.y) / 2 * frame.height).round();
      final kneeY = ((leftKnee.y + rightKnee.y) / 2 * frame.height).round();

      // Draw depth zone indicator
      final hasShallowDepth = currentRep?.formIssues.contains(SquatFormIssue.insufficientDepth) ?? false;
      final zoneColor = hasShallowDepth ? config.incorrectFormColor : config.correctFormColor;

      // Draw horizontal line at proper depth
      final properDepthY = hipY + ((kneeY - hipY) * 0.8).round();
      _drawLine(frame, 50, properDepthY, frame.width - 50, properDepthY, zoneColor, 3);

      // Draw zone label
      _drawText(frame, 'PROPER DEPTH', 60, properDepthY - 25, config);
    }
  }

  /// Draw knee tracking lines
  void _drawKneeTrackingLines(img.Image frame, List<KeyPoint> keyPoints, OverlayConfig config) {
    final leftKnee = _findKeyPoint(keyPoints, 'left_knee');
    final rightKnee = _findKeyPoint(keyPoints, 'right_knee');
    final leftAnkle = _findKeyPoint(keyPoints, 'left_ankle');
    final rightAnkle = _findKeyPoint(keyPoints, 'right_ankle');

    if (leftKnee != null && leftAnkle != null) {
      _drawKneeTrackingLine(frame, leftKnee, leftAnkle, config);
    }

    if (rightKnee != null && rightAnkle != null) {
      _drawKneeTrackingLine(frame, rightKnee, rightAnkle, config);
    }
  }

  /// Draw individual knee tracking line
  void _drawKneeTrackingLine(img.Image frame, KeyPoint knee, KeyPoint ankle, OverlayConfig config) {
    final kneeX = (knee.x * frame.width).round();
    final kneeY = (knee.y * frame.height).round();
    final ankleX = (ankle.x * frame.width).round();

    // Check if knee is past toe (simplified check)
    final kneeOverToe = kneeX > ankleX + 20; // 20 pixel threshold
    final lineColor = kneeOverToe ? config.incorrectFormColor : config.correctFormColor;

    // Draw vertical tracking line
    _drawLine(frame, ankleX, kneeY, ankleX, frame.height - 50, lineColor, 2);

    // Draw knee position indicator
    _drawLine(frame, kneeX, kneeY, kneeX, kneeY + 30, lineColor, 3);

    if (kneeOverToe) {
      _drawText(frame, 'KNEE FORWARD', kneeX + 10, kneeY, config);
    }
  }

  /// Draw back posture indicators
  void _drawBackPostureIndicators(img.Image frame, List<KeyPoint> keyPoints, OverlayConfig config) {
    final leftShoulder = _findKeyPoint(keyPoints, 'left_shoulder');
    final rightShoulder = _findKeyPoint(keyPoints, 'right_shoulder');
    final leftHip = _findKeyPoint(keyPoints, 'left_hip');
    final rightHip = _findKeyPoint(keyPoints, 'right_hip');

    if (leftShoulder != null && rightShoulder != null && leftHip != null && rightHip != null) {
      // Calculate torso angle
      final shoulderX = ((leftShoulder.x + rightShoulder.x) / 2 * frame.width).round();
      final shoulderY = ((leftShoulder.y + rightShoulder.y) / 2 * frame.height).round();
      final hipX = ((leftHip.x + rightHip.x) / 2 * frame.width).round();
      final hipY = ((leftHip.y + rightHip.y) / 2 * frame.height).round();

      // Draw torso line
      final forwardLean = (shoulderX - hipX).abs() > 30; // Simple lean detection
      final postureColor = forwardLean ? config.incorrectFormColor : config.correctFormColor;

      _drawLine(frame, shoulderX, shoulderY, hipX, hipY, postureColor, 4);

      // Draw posture feedback
      if (forwardLean) {
        _drawText(frame, 'KEEP CHEST UP', shoulderX + 20, shoulderY, config);
      }
    }
  }

  /// Draw joint angle measurements
  void _drawJointAngleMeasurements(img.Image frame, List<KeyPoint> keyPoints, OverlayConfig config) {
    // Draw knee angles
    _drawKneeAngle(frame, keyPoints, 'left', config);
    _drawKneeAngle(frame, keyPoints, 'right', config);

    // Draw hip angles
    _drawHipAngle(frame, keyPoints, 'left', config);
    _drawHipAngle(frame, keyPoints, 'right', config);
  }

  /// Draw knee angle measurement
  void _drawKneeAngle(img.Image frame, List<KeyPoint> keyPoints, String side, OverlayConfig config) {
    final hip = _findKeyPoint(keyPoints, '${side}_hip');
    final knee = _findKeyPoint(keyPoints, '${side}_knee');
    final ankle = _findKeyPoint(keyPoints, '${side}_ankle');

    if (hip != null && knee != null && ankle != null) {
      final angle = _calculateAngle(hip, knee, ankle);
      final kneeX = (knee.x * frame.width).round();
      final kneeY = (knee.y * frame.height).round();

      final angleText = '${angle.round()}°';
      final angleColor = (angle < 90) ? config.correctFormColor : config.neutralColor;

      _drawText(frame, angleText, kneeX + 15, kneeY, config);
    }
  }

  /// Draw hip angle measurement
  void _drawHipAngle(img.Image frame, List<KeyPoint> keyPoints, String side, OverlayConfig config) {
    final shoulder = _findKeyPoint(keyPoints, '${side}_shoulder');
    final hip = _findKeyPoint(keyPoints, '${side}_hip');
    final knee = _findKeyPoint(keyPoints, '${side}_knee');

    if (shoulder != null && hip != null && knee != null) {
      final angle = _calculateAngle(shoulder, hip, knee);
      final hipX = (hip.x * frame.width).round();
      final hipY = (hip.y * frame.height).round();

      final angleText = '${angle.round()}°';
      _drawText(frame, angleText, hipX - 30, hipY, config);
    }
  }

  /// Find a specific keypoint by name (simplified approach using index)
  KeyPoint? _findKeyPoint(List<KeyPoint> keyPoints, String name) {
    // This is a simplified approach - in a real implementation,
    // you'd have a proper mapping of joint names to indices
    final jointIndices = {
      'left_hip': 11,
      'right_hip': 12,
      'left_knee': 13,
      'right_knee': 14,
      'left_ankle': 15,
      'right_ankle': 16,
      'left_shoulder': 5,
      'right_shoulder': 6,
    };

    final index = jointIndices[name];
    if (index != null && index < keyPoints.length && keyPoints[index].score > 0.5) {
      return keyPoints[index];
    }
    return null;
  }

  /// Draw professional HUD with all metrics and indicators
  void _drawProfessionalHUD(img.Image frame, int totalReps, int correctReps,
                           SquatRepData? currentRep, double timestamp, OverlayConfig config) {
    // Draw rep counter with professional styling
    _drawProfessionalRepCounter(frame, totalReps, correctReps, config);

    // Draw form status indicator
    _drawFormStatusIndicator(frame, currentRep, config);

    // Draw timestamp and progress
    _drawTimestampAndProgress(frame, timestamp, config);
  }

  /// Draw professional rep counter
  void _drawProfessionalRepCounter(img.Image frame, int totalReps, int correctReps, OverlayConfig config) {
    final repText = 'REPS: $correctReps/$totalReps';
    final x = frame.width - 200;
    final y = 50;

    // Draw background panel
    _drawRoundedRect(frame, x - 20, y - 15, 180, 50, config.backgroundOverlayColor);

    // Draw rep counter text
    _drawText(frame, repText, x, y, config);

    // Draw accuracy indicator
    final accuracy = totalReps > 0 ? (correctReps / totalReps * 100).round() : 100;
    final accuracyText = 'ACCURACY: $accuracy%';
    final accuracyColor = accuracy >= 80 ? config.correctFormColor : config.incorrectFormColor;

    _drawText(frame, accuracyText, x, y + 25, config);
  }

  /// Draw form status indicator
  void _drawFormStatusIndicator(img.Image frame, SquatRepData? currentRep, OverlayConfig config) {
    final x = 50;
    final y = 50;

    String statusText;
    img.Color statusColor;

    if (currentRep == null) {
      statusText = 'READY';
      statusColor = config.neutralColor;
    } else if (currentRep.formIssues.isEmpty) {
      statusText = 'GOOD FORM';
      statusColor = config.correctFormColor;
    } else {
      statusText = 'CHECK FORM';
      statusColor = config.incorrectFormColor;
    }

    // Draw status background
    _drawRoundedRect(frame, x - 20, y - 15, 150, 40, statusColor);

    // Draw status text
    _drawText(frame, statusText, x, y, config);
  }

  /// Draw timestamp and progress indicators
  void _drawTimestampAndProgress(img.Image frame, double timestamp, OverlayConfig config) {
    final minutes = (timestamp / 60).floor();
    final seconds = (timestamp % 60).floor();
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final x = frame.width ~/ 2 - 30;
    final y = frame.height - 50;

    _drawText(frame, timeText, x, y, config);
  }

  /// Draw real-time feedback overlays
  void _drawRealtimeFeedbackOverlays(img.Image frame, SquatRepData currentRep, OverlayConfig config) {
    if (currentRep.formIssues.isNotEmpty) {
      final centerX = frame.width ~/ 2;
      final centerY = frame.height ~/ 2;

      // Draw main feedback message
      final mainIssue = currentRep.formIssues.first;
      final feedbackText = _getFormIssueText(mainIssue);

      // Draw semi-transparent background
      _drawRoundedRect(frame, centerX - 100, centerY - 30, 200, 60,
                      img.ColorRgba8(0, 0, 0, 150));

      // Draw feedback text
      _drawText(frame, feedbackText, centerX - 80, centerY, config);

      // Draw additional form issues
      for (int i = 1; i < currentRep.formIssues.length && i < 3; i++) {
        final issueText = _getFormIssueText(currentRep.formIssues[i]);
        _drawText(frame, issueText, centerX - 80, centerY + (i * 25), config);
      }
    }
  }

  /// Draw rounded rectangle (simplified implementation)
  void _drawRoundedRect(img.Image frame, int x, int y, int width, int height, img.Color color) {
    // Simple rectangle implementation - could be enhanced with actual rounded corners
    for (int dy = 0; dy < height; dy++) {
      for (int dx = 0; dx < width; dx++) {
        final px = x + dx;
        final py = y + dy;
        if (px >= 0 && px < frame.width && py >= 0 && py < frame.height) {
          frame.setPixel(px, py, color);
        }
      }
    }
  }
}
