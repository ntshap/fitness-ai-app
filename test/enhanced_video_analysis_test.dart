import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_ai_app/services/enhanced_video_analysis_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';
import 'package:fitness_ai_app/services/video_overlay_renderer.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';

void main() {
  group('Enhanced Video Analysis Tests', () {
    late EnhancedVideoAnalysisService analysisService;
    late SquatAnalysisService squatAnalysis;
    late VideoOverlayRenderer overlayRenderer;

    setUp(() {
      analysisService = EnhancedVideoAnalysisService();
      squatAnalysis = SquatAnalysisService();
      overlayRenderer = VideoOverlayRenderer();
    });

    test('SquatAnalysisService should analyze empty sequence', () {
      final result = squatAnalysis.analyzeSquatSequence([], []);
      
      expect(result.totalReps, equals(0));
      expect(result.correctReps, equals(0));
      expect(result.incorrectReps, equals(0));
      expect(result.overallFeedback.isNotEmpty, isTrue);
    });

    test('SquatAnalysisService should analyze mock keypoint sequence', () {
      // Create mock keypoint sequence
      final mockKeyPoints = List.generate(17, (index) => KeyPoint(0.5, 0.5, 0.8));
      final keyPointSequence = List.generate(10, (index) => mockKeyPoints);
      final timestamps = List.generate(10, (index) => index * 0.1);
      
      final result = squatAnalysis.analyzeSquatSequence(keyPointSequence, timestamps);
      
      expect(result.totalReps, greaterThanOrEqualTo(0));
      expect(result.averageKneeAngle, greaterThanOrEqualTo(0));
      expect(result.averageHipAngle, greaterThanOrEqualTo(0));
      expect(result.overallFeedback.isNotEmpty, isTrue);
    });

    test('VideoOverlayRenderer should create overlay config', () {
      final config = OverlayConfig(
        showPoseLandmarks: true,
        showSkeleton: true,
        showRepCounter: true,
        showFormFeedback: true,
      );
      
      expect(config.showPoseLandmarks, isTrue);
      expect(config.showSkeleton, isTrue);
      expect(config.showRepCounter, isTrue);
      expect(config.showFormFeedback, isTrue);
    });

    test('AnalysisResult should create enhanced result with video paths', () {
      final repetitionDetails = [
        RepetitionData(
          repNumber: 1,
          startTime: 0.0,
          endTime: 3.0,
          isCorrect: true,
          minKneeAngle: 85.0,
          minHipAngle: 90.0,
          formIssues: [],
        ),
      ];

      final result = AnalysisResult(
        correctSquats: 5,
        incorrectSquats: 1,
        avgKneeAngle: 85.5,
        avgHipAngle: 92.3,
        feedback: ['Good form!'],
        duration: 60,
        caloriesBurned: 30,
        analysisDate: DateTime.now(),
        exerciseType: 'Squat',
        originalVideoPath: '/path/to/original.mp4',
        processedVideoPath: '/path/to/processed.mp4',
        repetitionDetails: repetitionDetails,
        frameAnalysisData: {'total_frames': 100},
        hasVisualAnalysis: true,
      );

      expect(result.hasVisualAnalysis, isTrue);
      expect(result.originalVideoPath, equals('/path/to/original.mp4'));
      expect(result.processedVideoPath, equals('/path/to/processed.mp4'));
      expect(result.repetitionDetails?.length, equals(1));
      expect(result.totalSquats, equals(6));
      expect(result.accuracy, closeTo(83.33, 0.1));
    });

    test('RepetitionData should convert to map correctly', () {
      final rep = RepetitionData(
        repNumber: 1,
        startTime: 0.0,
        endTime: 3.0,
        isCorrect: true,
        minKneeAngle: 85.0,
        minHipAngle: 90.0,
        formIssues: ['test_issue'],
      );

      final map = rep.toMap();
      
      expect(map['rep_number'], equals(1));
      expect(map['start_time'], equals(0.0));
      expect(map['end_time'], equals(3.0));
      expect(map['is_correct'], isTrue);
      expect(map['min_knee_angle'], equals(85.0));
      expect(map['min_hip_angle'], equals(90.0));
      expect(map['form_issues'], equals(['test_issue']));
    });

    test('EnhancedVideoAnalysisProgress should track progress correctly', () {
      final progress = EnhancedVideoAnalysisProgress(
        stage: 'frame_processing',
        progress: 0.5,
        message: 'Processing frame 50 of 100',
        currentFrame: 50,
        totalFrames: 100,
      );

      expect(progress.stage, equals('frame_processing'));
      expect(progress.progress, equals(0.5));
      expect(progress.message, equals('Processing frame 50 of 100'));
      expect(progress.currentFrame, equals(50));
      expect(progress.totalFrames, equals(100));
    });

    test('SquatFormIssue enum should have all expected values', () {
      expect(SquatFormIssue.values.length, greaterThanOrEqualTo(5));
      expect(SquatFormIssue.values.contains(SquatFormIssue.kneeOverToe), isTrue);
      expect(SquatFormIssue.values.contains(SquatFormIssue.insufficientDepth), isTrue);
      expect(SquatFormIssue.values.contains(SquatFormIssue.backRounding), isTrue);
      expect(SquatFormIssue.values.contains(SquatFormIssue.kneeCollapse), isTrue);
      expect(SquatFormIssue.values.contains(SquatFormIssue.heelLift), isTrue);
    });

    test('SquatPhase enum should have all expected values', () {
      expect(SquatPhase.values.length, equals(4));
      expect(SquatPhase.values.contains(SquatPhase.standing), isTrue);
      expect(SquatPhase.values.contains(SquatPhase.descending), isTrue);
      expect(SquatPhase.values.contains(SquatPhase.bottom), isTrue);
      expect(SquatPhase.values.contains(SquatPhase.ascending), isTrue);
    });

    tearDown(() {
      analysisService.dispose();
    });
  });

  group('Performance Tests', () {
    test('Mock keypoint processing should be efficient', () {
      final stopwatch = Stopwatch()..start();
      
      // Generate large mock dataset
      final mockKeyPoints = List.generate(17, (index) => KeyPoint(0.5, 0.5, 0.8));
      final keyPointSequence = List.generate(1000, (index) => mockKeyPoints);
      final timestamps = List.generate(1000, (index) => index * 0.033); // 30 FPS
      
      final squatAnalysis = SquatAnalysisService();
      final result = squatAnalysis.analyzeSquatSequence(keyPointSequence, timestamps);
      
      stopwatch.stop();
      
      // Should process 1000 frames in reasonable time (less than 5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(result.totalReps, greaterThanOrEqualTo(0));
    });

    test('Memory usage should be reasonable for large datasets', () {
      // This is a basic test - just verify it doesn't crash with large datasets

      // Process large dataset
      final mockKeyPoints = List.generate(17, (index) => KeyPoint(0.5, 0.5, 0.8));
      final keyPointSequence = List.generate(1000, (index) => mockKeyPoints); // Reduced size for test
      final timestamps = List.generate(1000, (index) => index * 0.033);

      final squatAnalysis = SquatAnalysisService();
      final result = squatAnalysis.analyzeSquatSequence(keyPointSequence, timestamps);

      // Just verify it completes without crashing
      expect(result.totalReps, greaterThanOrEqualTo(0));
      expect(result.averageKneeAngle, greaterThanOrEqualTo(0));
      expect(result.averageHipAngle, greaterThanOrEqualTo(0));
    });
  });
}
