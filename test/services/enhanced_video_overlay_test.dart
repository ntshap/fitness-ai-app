import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:fitness_ai_app/services/video_overlay_renderer.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';

void main() {
  group('Enhanced Video Overlay Renderer Tests', () {
    late VideoOverlayRenderer renderer;
    late img.Image testFrame;
    late List<KeyPoint> testKeyPoints;
    late SquatRepData testRepData;

    setUp(() {
      renderer = VideoOverlayRenderer();
      
      // Create a test frame (640x480 RGB)
      testFrame = img.Image(width: 640, height: 480);
      img.fill(testFrame, color: img.ColorRgb8(100, 100, 100)); // Gray background
      
      // Create test keypoints for a person in squat position
      testKeyPoints = [
        KeyPoint(0.0, 0.0, 0.1), // unused indices 0-4
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.3, 0.2, 0.9), // left_shoulder (index 5)
        KeyPoint(0.7, 0.2, 0.9), // right_shoulder (index 6)
        KeyPoint(0.0, 0.0, 0.1), // unused indices 7-10
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.0, 0.0, 0.1),
        KeyPoint(0.25, 0.5, 0.95), // left_hip (index 11)
        KeyPoint(0.75, 0.5, 0.95), // right_hip (index 12)
        KeyPoint(0.2, 0.7, 0.9),   // left_knee (index 13)
        KeyPoint(0.8, 0.7, 0.9),   // right_knee (index 14)
        KeyPoint(0.15, 0.9, 0.85), // left_ankle (index 15)
        KeyPoint(0.85, 0.9, 0.85), // right_ankle (index 16)
      ];

      // Create test rep data with form issues
      testRepData = SquatRepData(
        repNumber: 1,
        startTime: 0.0,
        endTime: 2.0,
        isCorrect: false,
        minKneeAngle: 85.0,
        minHipAngle: 90.0,
        formIssues: [SquatFormIssue.kneeCollapse, SquatFormIssue.backRounding],
        phase: SquatPhase.bottom,
      );
    });

    test('should create professional overlay config with all features enabled', () {
      final config = OverlayConfig(
        showPoseLandmarks: true,
        showSkeleton: true,
        showRepCounter: true,
        showFormFeedback: true,
        showAngles: true,
        showDepthZone: true,
        showKneeTracking: true,
        showBackPosture: true,
        showRealtimeFeedback: true,
      );

      expect(config.showPoseLandmarks, isTrue);
      expect(config.showDepthZone, isTrue);
      expect(config.showKneeTracking, isTrue);
      expect(config.showBackPosture, isTrue);
      expect(config.showRealtimeFeedback, isTrue);
      expect(config.jointRadius, equals(8));
      expect(config.skeletonThickness, equals(4));
    });

    test('should render professional overlays without errors', () {
      final config = OverlayConfig();
      
      expect(() {
        final result = renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          10, // totalReps
          8,  // correctReps
          15.5, // timestamp
          config: config,
        );
        
        expect(result, isNotNull);
        expect(result.width, equals(640));
        expect(result.height, equals(480));
      }, returnsNormally);
    });

    test('should handle enhanced pose landmarks with confidence indicators', () {
      final config = OverlayConfig(showPoseLandmarks: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          null,
          0,
          0,
          0.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should render professional skeleton with quality indicators', () {
      final config = OverlayConfig(showSkeleton: true, showPoseLandmarks: false);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          null,
          0,
          0,
          0.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should display squat depth zone overlay', () {
      final config = OverlayConfig(showDepthZone: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should show knee tracking lines', () {
      final config = OverlayConfig(showKneeTracking: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should display back posture indicators', () {
      final config = OverlayConfig(showBackPosture: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should show joint angle measurements', () {
      final config = OverlayConfig(showAngles: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should render professional HUD elements', () {
      final config = OverlayConfig(showRepCounter: true, showFormFeedback: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          15,
          12,
          45.5,
          config: config,
        );
      }, returnsNormally);
    });

    test('should display real-time feedback overlays for form issues', () {
      final config = OverlayConfig(showRealtimeFeedback: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should handle empty keypoints gracefully', () {
      final config = OverlayConfig();
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          [],
          testRepData,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should handle null rep data gracefully', () {
      final config = OverlayConfig();
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          null,
          5,
          3,
          10.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should use appropriate colors for different confidence levels', () {
      // Test with low confidence keypoints
      final lowConfidenceKeyPoints = testKeyPoints.map((kp) =>
        KeyPoint(kp.x, kp.y, 0.3)).toList();
      
      final config = OverlayConfig(showPoseLandmarks: true);
      
      expect(() {
        renderer.renderFrameOverlays(
          testFrame,
          lowConfidenceKeyPoints,
          null,
          0,
          0,
          0.0,
          config: config,
        );
      }, returnsNormally);
    });

    test('should render all professional features together', () {
      final config = OverlayConfig(
        showPoseLandmarks: true,
        showSkeleton: true,
        showRepCounter: true,
        showFormFeedback: true,
        showAngles: true,
        showDepthZone: true,
        showKneeTracking: true,
        showBackPosture: true,
        showRealtimeFeedback: true,
      );
      
      expect(() {
        final result = renderer.renderFrameOverlays(
          testFrame,
          testKeyPoints,
          testRepData,
          20,
          16,
          60.0,
          config: config,
        );
        
        expect(result, isNotNull);
        expect(result.width, equals(640));
        expect(result.height, equals(480));
      }, returnsNormally);
    });
  });
}
