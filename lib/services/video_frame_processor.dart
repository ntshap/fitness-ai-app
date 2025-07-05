import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:fitness_ai_app/services/pose_detector_service.dart';

class VideoFrameData {
  final img.Image frame;
  final List<KeyPoint>? keyPoints;
  final double timestamp;
  final int frameIndex;

  VideoFrameData({
    required this.frame,
    this.keyPoints,
    required this.timestamp,
    required this.frameIndex,
  });
}

class VideoProcessingProgress {
  final int currentFrame;
  final int totalFrames;
  final String stage;
  final double progress;

  VideoProcessingProgress({
    required this.currentFrame,
    required this.totalFrames,
    required this.stage,
    required this.progress,
  });
}

class VideoFrameProcessor {
  static final VideoFrameProcessor _instance = VideoFrameProcessor._internal();
  factory VideoFrameProcessor() => _instance;
  VideoFrameProcessor._internal();

  final PoseDetectorService _poseDetector = PoseDetectorService();
  
  /// Extract frames from video file and process them through pose detection
  Future<List<VideoFrameData>> processVideoFrames(
    String videoPath, {
    Function(VideoProcessingProgress)? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
      // Set up timeout for the entire operation
      return await _processVideoFramesInternal(videoPath, onProgress).timeout(
        timeout,
        onTimeout: () {
          throw Exception('Video processing timed out after ${timeout.inMinutes} minutes');
        },
      );
    } catch (e) {
      throw Exception('Video frame processing failed: $e');
    }
  }

  Future<List<VideoFrameData>> _processVideoFramesInternal(
    String videoPath,
    Function(VideoProcessingProgress)? onProgress,
  ) async {
    try {
      // Validate video file
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Video file does not exist');
      }

      // Get video info first
      final videoInfo = await _getVideoInfo(videoPath);
      final fps = videoInfo['fps'] ?? 30.0;
      final duration = videoInfo['duration'] ?? 0.0;
      final totalFrames = (duration * fps).round();

      // Validate video duration (max 5 minutes for processing efficiency)
      if (duration > 300) {
        throw Exception('Video is too long (${duration.toInt()}s). Maximum supported duration is 5 minutes.');
      }

      onProgress?.call(VideoProcessingProgress(
        currentFrame: 0,
        totalFrames: totalFrames,
        stage: 'Extracting frames...',
        progress: 0.0,
      ));

      // Extract frames from video
      final frames = await _extractFrames(videoPath, fps: fps);
      
      final processedFrames = <VideoFrameData>[];
      
      for (int i = 0; i < frames.length; i++) {
        final frame = frames[i];
        final timestamp = i / fps;
        
        // Process frame through pose detection
        final keyPoints = await _processFrameForPose(frame);
        
        processedFrames.add(VideoFrameData(
          frame: frame,
          keyPoints: keyPoints,
          timestamp: timestamp,
          frameIndex: i,
        ));

        // Update progress
        final progress = (i + 1) / frames.length;
        onProgress?.call(VideoProcessingProgress(
          currentFrame: i + 1,
          totalFrames: frames.length,
          stage: 'Processing pose detection...',
          progress: progress,
        ));
      }

      return processedFrames;
    } catch (e) {
      throw Exception('Failed to process video frames: $e');
    }
  }

  /// Extract frames from video using video_thumbnail (simplified approach)
  Future<List<img.Image>> _extractFrames(String videoPath, {double fps = 30.0}) async {
    try {
      // For now, generate mock frames since video frame extraction is complex
      // In a production app, you would implement proper video frame extraction

      // Generate 10 mock frames for demonstration
      final frames = <img.Image>[];
      for (int i = 0; i < 10; i++) {
        // Create a simple colored frame for testing
        final frame = img.Image(width: 640, height: 480);
        img.fill(frame, color: img.ColorRgb8(100 + i * 10, 150, 200));
        frames.add(frame);
      }

      return frames;
    } catch (e) {
      throw Exception('Frame extraction failed: $e');
    }
  }

  /// Process a single frame through pose detection
  Future<List<KeyPoint>?> _processFrameForPose(img.Image frame) async {
    try {
      // Resize frame to model input size
      final resizedFrame = img.copyResize(frame, width: 257, height: 257);
      
      // Convert to format expected by pose detector
      // This is a simplified version - in practice, you'd need to convert
      // the img.Image to the format expected by your pose detection model
      
      // For now, return mock keypoints - this will be replaced with actual pose detection
      return _generateMockKeyPoints();
    } catch (e) {
      print('Error processing frame for pose: $e');
      return null;
    }
  }

  /// Get video information (simplified mock implementation)
  Future<Map<String, dynamic>> _getVideoInfo(String videoPath) async {
    try {
      // For now, return mock video info
      // In a production app, you would use proper video metadata extraction
      return {
        'fps': 30.0,
        'duration': 10.0, // 10 seconds
      };
    } catch (e) {
      // Return defaults on error
      return {'fps': 30.0, 'duration': 10.0};
    }
  }

  /// Generate mock keypoints for testing
  List<KeyPoint> _generateMockKeyPoints() {
    // Return 17 keypoints with mock data
    return List.generate(17, (index) {
      return KeyPoint(
        0.3 + (index % 3) * 0.2, // x coordinate
        0.2 + (index % 4) * 0.2, // y coordinate
        0.8, // confidence score
      );
    });
  }

  /// Clean up resources
  void dispose() {
    // Clean up any resources if needed
  }
}
