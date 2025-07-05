import 'dart:math';
import 'package:fitness_ai_app/services/pose_detector_service.dart';

enum SquatPhase {
  standing,
  descending,
  bottom,
  ascending,
}

enum SquatFormIssue {
  kneeOverToe,
  insufficientDepth,
  backRounding,
  kneeCollapse,
  heelLift,
}

class SquatRepData {
  final int repNumber;
  final double startTime;
  final double endTime;
  final bool isCorrect;
  final double minKneeAngle;
  final double minHipAngle;
  final List<SquatFormIssue> formIssues;
  final SquatPhase phase;

  SquatRepData({
    required this.repNumber,
    required this.startTime,
    required this.endTime,
    required this.isCorrect,
    required this.minKneeAngle,
    required this.minHipAngle,
    required this.formIssues,
    required this.phase,
  });
}

class SquatAnalysisResult {
  final List<SquatRepData> repetitions;
  final int totalReps;
  final int correctReps;
  final int incorrectReps;
  final double averageKneeAngle;
  final double averageHipAngle;
  final List<String> overallFeedback;
  final Map<SquatFormIssue, int> commonIssues;

  SquatAnalysisResult({
    required this.repetitions,
    required this.totalReps,
    required this.correctReps,
    required this.incorrectReps,
    required this.averageKneeAngle,
    required this.averageHipAngle,
    required this.overallFeedback,
    required this.commonIssues,
  });
}

class SquatAnalysisService {
  static final SquatAnalysisService _instance = SquatAnalysisService._internal();
  factory SquatAnalysisService() => _instance;
  SquatAnalysisService._internal();

  // Keypoint indices for pose estimation (COCO format)
  static const int leftHip = 11;
  static const int rightHip = 12;
  static const int leftKnee = 13;
  static const int rightKnee = 14;
  static const int leftAnkle = 15;
  static const int rightAnkle = 16;
  static const int leftShoulder = 5;
  static const int rightShoulder = 6;

  // Thresholds for squat analysis
  static const double minSquatDepth = 90.0; // degrees
  static const double maxKneeForwardRatio = 0.1; // knee shouldn't go too far forward
  static const double minConfidenceThreshold = 0.5;

  /// Analyze squat form from a sequence of pose keypoints
  SquatAnalysisResult analyzeSquatSequence(
    List<List<KeyPoint>> keyPointSequence,
    List<double> timestamps,
  ) {
    if (keyPointSequence.isEmpty || timestamps.isEmpty) {
      return _createEmptyResult();
    }

    final repetitions = <SquatRepData>[];
    final phases = <SquatPhase>[];
    final kneeAngles = <double>[];
    final hipAngles = <double>[];

    // Analyze each frame
    for (int i = 0; i < keyPointSequence.length; i++) {
      final keyPoints = keyPointSequence[i];
      final timestamp = timestamps[i];

      // Calculate angles and detect phase
      final kneeAngle = _calculateKneeAngle(keyPoints);
      final hipAngle = _calculateHipAngle(keyPoints);
      final phase = _detectSquatPhase(keyPoints, kneeAngle);

      kneeAngles.add(kneeAngle);
      hipAngles.add(hipAngle);
      phases.add(phase);
    }

    // Detect repetitions from phase transitions
    final reps = _detectRepetitions(phases, timestamps, keyPointSequence);
    repetitions.addAll(reps);

    // Calculate overall statistics
    final totalReps = repetitions.length;
    final correctReps = repetitions.where((rep) => rep.isCorrect).length;
    final incorrectReps = totalReps - correctReps;

    final avgKneeAngle = kneeAngles.isNotEmpty 
        ? kneeAngles.reduce((a, b) => a + b) / kneeAngles.length 
        : 0.0;
    final avgHipAngle = hipAngles.isNotEmpty 
        ? hipAngles.reduce((a, b) => a + b) / hipAngles.length 
        : 0.0;

    // Generate feedback
    final feedback = _generateFeedback(repetitions);
    final commonIssues = _analyzeCommonIssues(repetitions);

    return SquatAnalysisResult(
      repetitions: repetitions,
      totalReps: totalReps,
      correctReps: correctReps,
      incorrectReps: incorrectReps,
      averageKneeAngle: avgKneeAngle,
      averageHipAngle: avgHipAngle,
      overallFeedback: feedback,
      commonIssues: commonIssues,
    );
  }

  /// Calculate knee angle from keypoints
  double _calculateKneeAngle(List<KeyPoint> keyPoints) {
    if (keyPoints.length < 17) return 0.0;

    // Use right leg for analysis (can be extended to use both)
    final hip = keyPoints[rightHip];
    final knee = keyPoints[rightKnee];
    final ankle = keyPoints[rightAnkle];

    if (hip.score < minConfidenceThreshold ||
        knee.score < minConfidenceThreshold ||
        ankle.score < minConfidenceThreshold) {
      return 0.0;
    }

    return _calculateAngle(hip, knee, ankle);
  }

  /// Calculate hip angle from keypoints
  double _calculateHipAngle(List<KeyPoint> keyPoints) {
    if (keyPoints.length < 17) return 0.0;

    final shoulder = keyPoints[rightShoulder];
    final hip = keyPoints[rightHip];
    final knee = keyPoints[rightKnee];

    if (shoulder.score < minConfidenceThreshold ||
        hip.score < minConfidenceThreshold ||
        knee.score < minConfidenceThreshold) {
      return 0.0;
    }

    return _calculateAngle(shoulder, hip, knee);
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

  /// Detect current squat phase based on keypoints and knee angle
  SquatPhase _detectSquatPhase(List<KeyPoint> keyPoints, double kneeAngle) {
    if (kneeAngle > 160) return SquatPhase.standing;
    if (kneeAngle > 120) return SquatPhase.descending;
    if (kneeAngle > 100) return SquatPhase.bottom;
    return SquatPhase.ascending;
  }

  /// Detect repetitions from phase sequence
  List<SquatRepData> _detectRepetitions(
    List<SquatPhase> phases,
    List<double> timestamps,
    List<List<KeyPoint>> keyPointSequence,
  ) {
    final repetitions = <SquatRepData>[];
    int repCount = 0;
    int? repStartIndex;
    double? minKneeAngle;
    double? minHipAngle;

    for (int i = 0; i < phases.length; i++) {
      final phase = phases[i];
      
      // Start of new repetition (standing to descending)
      if (phase == SquatPhase.descending && repStartIndex == null) {
        repStartIndex = i;
        minKneeAngle = null;
        minHipAngle = null;
      }
      
      // Track minimum angles during rep
      if (repStartIndex != null) {
        final kneeAngle = _calculateKneeAngle(keyPointSequence[i]);
        final hipAngle = _calculateHipAngle(keyPointSequence[i]);
        
        minKneeAngle = minKneeAngle == null ? kneeAngle : min(minKneeAngle, kneeAngle);
        minHipAngle = minHipAngle == null ? hipAngle : min(minHipAngle, hipAngle);
      }
      
      // End of repetition (back to standing)
      if (phase == SquatPhase.standing && repStartIndex != null) {
        repCount++;
        
        final formIssues = _analyzeFormIssues(
          keyPointSequence.sublist(repStartIndex, i + 1),
          minKneeAngle ?? 0,
        );
        
        repetitions.add(SquatRepData(
          repNumber: repCount,
          startTime: timestamps[repStartIndex],
          endTime: timestamps[i],
          isCorrect: formIssues.isEmpty,
          minKneeAngle: minKneeAngle ?? 0,
          minHipAngle: minHipAngle ?? 0,
          formIssues: formIssues,
          phase: phase,
        ));
        
        repStartIndex = null;
      }
    }

    return repetitions;
  }

  /// Analyze form issues for a single repetition
  List<SquatFormIssue> _analyzeFormIssues(
    List<List<KeyPoint>> repKeyPoints,
    double minKneeAngle,
  ) {
    final issues = <SquatFormIssue>[];

    // Check squat depth
    if (minKneeAngle > minSquatDepth) {
      issues.add(SquatFormIssue.insufficientDepth);
    }

    // Additional form checks can be added here
    // For now, we'll use simplified logic

    return issues;
  }

  /// Generate feedback based on analysis results
  List<String> _generateFeedback(List<SquatRepData> repetitions) {
    final feedback = <String>[];

    if (repetitions.isEmpty) {
      feedback.add('No squats detected. Make sure you perform full squats in the video.');
      return feedback;
    }

    final correctReps = repetitions.where((rep) => rep.isCorrect).length;
    final totalReps = repetitions.length;
    final accuracy = (correctReps / totalReps * 100).round();

    feedback.add('Detected $totalReps squats with $accuracy% accuracy.');

    if (accuracy >= 80) {
      feedback.add('Excellent form! Keep up the good work.');
    } else if (accuracy >= 60) {
      feedback.add('Good effort! Focus on maintaining proper form.');
    } else {
      feedback.add('Form needs improvement. Focus on the feedback below.');
    }

    return feedback;
  }

  /// Analyze common form issues across all repetitions
  Map<SquatFormIssue, int> _analyzeCommonIssues(List<SquatRepData> repetitions) {
    final issueCount = <SquatFormIssue, int>{};

    for (final rep in repetitions) {
      for (final issue in rep.formIssues) {
        issueCount[issue] = (issueCount[issue] ?? 0) + 1;
      }
    }

    return issueCount;
  }

  /// Create empty result for error cases
  SquatAnalysisResult _createEmptyResult() {
    return SquatAnalysisResult(
      repetitions: [],
      totalReps: 0,
      correctReps: 0,
      incorrectReps: 0,
      averageKneeAngle: 0.0,
      averageHipAngle: 0.0,
      overallFeedback: ['Unable to analyze video. Please try again.'],
      commonIssues: {},
    );
  }
}
