import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
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

  Future<List<VideoFrameData>> processVideoFrames(
    String videoPath, {
    Function(VideoProcessingProgress)? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
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
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Video file does not exist');
      }

      final videoInfo = await _getVideoInfo(videoPath);
      final fps = videoInfo['fps'] ?? 30.0;
      final duration = videoInfo['duration'] ?? 0.0;
      final totalFrames = (duration * fps).round();

      if (duration > 300) {
        throw Exception('Video is too long (${duration.toInt()}s). Maximum supported duration is 5 minutes.');
      }

      onProgress?.call(VideoProcessingProgress(
        currentFrame: 0,
        totalFrames: totalFrames,
        stage: 'Extracting frames...',
        progress: 0.0,
      ));

      final frames = await _extractFrames(
        videoPath,
        fps: fps,
        onProgress: (current, total) {
          onProgress?.call(VideoProcessingProgress(
            currentFrame: current,
            totalFrames: total,
            stage: 'Extracting frames...',
            progress: current / total,
          ));
        },
      );
      
      final processedFrames = <VideoFrameData>[];
      
      for (int i = 0; i < frames.length; i++) {
        final frame = frames[i];
        final timestamp = i / fps;
        
        final keyPoints = await _processFrameForPose(frame);
        
        processedFrames.add(VideoFrameData(
          frame: frame,
          keyPoints: keyPoints,
          timestamp: timestamp,
          frameIndex: i,
        ));

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

  Future<List<img.Image>> _extractFrames(String videoPath, {double fps = 30.0, int maxFrames = 300, Function(int current, int total)? onProgress}) async {
    try {
      final videoInfo = await _getVideoInfo(videoPath);
      final duration = videoInfo['duration'] ?? 0.0;
      
      if (duration <= 0) {
        throw Exception('Invalid video duration: $duration seconds');
      }

      // Ensure we have at least 1 frame
      final framesToExtract = (duration * fps).round();
      if (framesToExtract <= 0) {
        throw Exception('Invalid video duration or frame rate');
      }

      // Limit frames to prevent memory issues
      final actualFramesToExtract = framesToExtract > maxFrames ? maxFrames : framesToExtract;
      final interval = duration / actualFramesToExtract;

      final frames = <img.Image>[];
      final tempDir = await getTemporaryDirectory();
      
      print('Extracting $actualFramesToExtract frames from video (duration: ${duration}s, fps: $fps)');
      
      // Extract frames at regular intervals (sampling)
      for (int i = 0; i < actualFramesToExtract; i++) {
        final timestamp = i * interval;
        
        try {
          // Generate thumbnail at specific timestamp
          final thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: videoPath,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.JPEG,
            timeMs: (timestamp * 1000).round(),
            quality: 80,
          );
          
          if (thumbnailPath != null) {
            final bytes = await File(thumbnailPath).readAsBytes();
            final image = img.decodeImage(bytes);
            if (image != null) {
              frames.add(image);
              print('Successfully extracted frame ${i + 1}/$actualFramesToExtract');
            } else {
              print('Failed to decode frame ${i + 1}');
            }
            // Clean up the temporary thumbnail file
            try {
              await File(thumbnailPath).delete();
            } catch (e) {
              print('Failed to delete thumbnail: $e');
            }
          } else {
            print('Failed to generate thumbnail for frame ${i + 1}');
          }
        } catch (e) {
          print('Error extracting frame ${i + 1}: $e');
          // Continue with next frame instead of failing completely
        }
        
        // Update progress
        onProgress?.call(i + 1, actualFramesToExtract);
      }
      
      if (frames.isEmpty) {
        throw Exception('No frames could be extracted from the video');
      }
      
      print('Successfully extracted ${frames.length} frames');
      return frames;
    } catch (e) {
      print('Error in _extractFrames: $e');
      throw Exception('Failed to extract frames: $e');
    }
  }

  Future<List<KeyPoint>?> _processFrameForPose(img.Image frame) async {
    try {
      final keyPoints = await _poseDetector.processImage(frame);
      if (keyPoints != null && keyPoints.isNotEmpty) {
        // Validate keypoints - ensure we have at least some key joints
        final validKeypoints = keyPoints.where((kp) => kp.score > 0.3).length;
        if (validKeypoints >= 5) { // At least 5 keypoints with decent confidence
          return keyPoints;
        } else {
          print('Frame has insufficient valid keypoints: $validKeypoints');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error processing frame for pose: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _getVideoInfo(String videoPath) async {
    try {
      final controller = VideoPlayerController.file(File(videoPath));
      await controller.initialize();
      
      final duration = controller.value.duration.inMilliseconds / 1000.0;
      final fps = controller.value.frameRate ?? 30.0;
      
      await controller.dispose();
      
      print('Video info - Duration: ${duration}s, FPS: $fps');
      
      return {
        'fps': fps,
        'duration': duration,
        'width': controller.value.size.width,
        'height': controller.value.size.height,
      };
    } catch (e) {
      print('Error getting video info: $e');
      // Return default values if video info extraction fails
      return {'fps': 30.0, 'duration': 10.0};
    }
  }

  void dispose() {
    // Clean up any resources if needed
  }
}
