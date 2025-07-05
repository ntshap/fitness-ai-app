import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:fitness_ai_app/services/video_frame_processor.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';
import 'package:fitness_ai_app/services/video_overlay_renderer.dart';
import 'package:fitness_ai_app/services/video_output_generator.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';

class EnhancedVideoAnalysisProgress {
  final String stage;
  final double progress;
  final String message;
  final int? currentFrame;
  final int? totalFrames;

  EnhancedVideoAnalysisProgress({
    required this.stage,
    required this.progress,
    required this.message,
    this.currentFrame,
    this.totalFrames,
  });
}

class EnhancedVideoAnalysisService {
  static final EnhancedVideoAnalysisService _instance = EnhancedVideoAnalysisService._internal();
  factory EnhancedVideoAnalysisService() => _instance;
  EnhancedVideoAnalysisService._internal();

  final VideoFrameProcessor _frameProcessor = VideoFrameProcessor();
  final SquatAnalysisService _squatAnalysis = SquatAnalysisService();
  final VideoOverlayRenderer _overlayRenderer = VideoOverlayRenderer();
  final VideoOutputGenerator _outputGenerator = VideoOutputGenerator();

  /// Perform complete enhanced video analysis with visual overlays
  Future<AnalysisResult> analyzeVideoWithVisualOverlays(
    String videoPath, {
    Function(EnhancedVideoAnalysisProgress)? onProgress,
  }) async {
    try {
      // Validate input file
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Video file not found: $videoPath');
      }

      final fileSize = await videoFile.length();
      if (fileSize == 0) {
        throw Exception('Video file is empty');
      }

      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'initialization',
        progress: 0.0,
        message: 'Starting video analysis...',
      ));

      // Step 1: Extract and process video frames
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'frame_extraction',
        progress: 0.1,
        message: 'Extracting frames from video...',
      ));

      List<VideoFrameData> frameData;
      try {
        frameData = await _frameProcessor.processVideoFrames(
          videoPath,
          onProgress: (frameProgress) {
            onProgress?.call(EnhancedVideoAnalysisProgress(
              stage: 'frame_processing',
              progress: 0.1 + (frameProgress.progress * 0.3),
              message: 'Processing frame ${frameProgress.currentFrame} of ${frameProgress.totalFrames}...',
              currentFrame: frameProgress.currentFrame,
              totalFrames: frameProgress.totalFrames,
            ));
          },
        );
      } catch (e) {
        throw Exception('Frame extraction failed: $e');
      }

      if (frameData.isEmpty) {
        throw Exception('No frames could be extracted from the video. Please check if the video format is supported.');
      }

      // Validate frame data quality
      final validFrames = frameData.where((frame) => frame.keyPoints != null && frame.keyPoints!.isNotEmpty).length;
      if (validFrames < frameData.length * 0.5) {
        throw Exception('Poor pose detection quality. Only $validFrames out of ${frameData.length} frames have valid pose data.');
      }

      // Step 2: Analyze squat form from keypoints
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'squat_analysis',
        progress: 0.4,
        message: 'Analyzing squat form and counting repetitions...',
      ));

      final keyPointSequence = frameData.map((frame) => frame.keyPoints ?? <KeyPoint>[]).toList();
      final timestamps = frameData.map((frame) => frame.timestamp).toList();
      
      final squatAnalysis = _squatAnalysis.analyzeSquatSequence(keyPointSequence, timestamps);

      // Step 3: Render overlays on frames
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'overlay_rendering',
        progress: 0.5,
        message: 'Rendering visual overlays on frames...',
      ));

      final overlayConfig = OverlayConfig(
        showPoseLandmarks: true,
        showSkeleton: true,
        showRepCounter: true,
        showFormFeedback: true,
        showAngles: true,
      );

      final overlayFrames = <img.Image>[];
      for (int i = 0; i < frameData.length; i++) {
        final frame = frameData[i];
        
        // Find current repetition data for this timestamp
        final currentRep = _findCurrentRepetition(squatAnalysis.repetitions, frame.timestamp);
        
        // Render overlays on frame
        final overlayFrame = _overlayRenderer.renderFrameOverlays(
          frame.frame,
          frame.keyPoints,
          currentRep,
          squatAnalysis.totalReps,
          squatAnalysis.correctReps,
          frame.timestamp,
          config: overlayConfig,
        );
        
        overlayFrames.add(overlayFrame);

        // Update progress
        final progress = 0.5 + ((i + 1) / frameData.length * 0.3);
        onProgress?.call(EnhancedVideoAnalysisProgress(
          stage: 'overlay_rendering',
          progress: progress,
          message: 'Rendering overlay ${i + 1} of ${frameData.length}...',
          currentFrame: i + 1,
          totalFrames: frameData.length,
        ));
      }

      // Step 4: Generate output video
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'video_generation',
        progress: 0.8,
        message: 'Generating analyzed video...',
      ));

      String processedVideoPath;
      try {
        processedVideoPath = await _outputGenerator.generateVideoFromFrames(
          overlayFrames,
          videoPath,
          onProgress: (genProgress) {
            onProgress?.call(EnhancedVideoAnalysisProgress(
              stage: 'video_generation',
              progress: 0.8 + (genProgress.progress * 0.15),
              message: genProgress.stage,
              currentFrame: genProgress.currentFrame,
              totalFrames: genProgress.totalFrames,
            ));
          },
        );
      } catch (e) {
        throw Exception('Video generation failed: $e');
      }

      // Verify the generated video file
      if (!await File(processedVideoPath).exists()) {
        throw Exception('Generated video file not found');
      }

      // Step 5: Add audio from original video (optional)
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'audio_processing',
        progress: 0.95,
        message: 'Adding audio to analyzed video...',
      ));

      String finalVideoPath;
      try {
        finalVideoPath = await _outputGenerator.generateVideoWithAudio(
          processedVideoPath,
          videoPath,
        );
      } catch (e) {
        // If audio processing fails, use the video without audio
        print('Audio processing failed, using video without audio: $e');
        finalVideoPath = processedVideoPath;
      }

      // Step 6: Create enhanced analysis result
      onProgress?.call(EnhancedVideoAnalysisProgress(
        stage: 'completion',
        progress: 1.0,
        message: 'Analysis complete!',
      ));

      final enhancedResult = _createEnhancedAnalysisResult(
        squatAnalysis,
        videoPath,
        finalVideoPath,
        frameData,
      );

      return enhancedResult;
    } catch (e) {
      // Clean up any temporary files on error
      try {
        await _outputGenerator.cleanupTempFiles();
      } catch (cleanupError) {
        // Ignore cleanup errors
      }

      // Provide more specific error messages
      String errorMessage = 'Enhanced video analysis failed';
      if (e.toString().contains('Frame extraction failed')) {
        errorMessage = 'Could not extract frames from video. Please check if the video format is supported.';
      } else if (e.toString().contains('Poor pose detection quality')) {
        errorMessage = 'Unable to detect person in video. Please ensure the person is clearly visible throughout the video.';
      } else if (e.toString().contains('Video generation failed')) {
        errorMessage = 'Could not generate analyzed video. Please try again or check available storage space.';
      } else if (e.toString().contains('Video file not found')) {
        errorMessage = 'Video file could not be found. Please select a valid video file.';
      }

      throw Exception('$errorMessage: ${e.toString()}');
    }
  }

  /// Find the current repetition data for a given timestamp
  SquatRepData? _findCurrentRepetition(List<SquatRepData> repetitions, double timestamp) {
    for (final rep in repetitions) {
      if (timestamp >= rep.startTime && timestamp <= rep.endTime) {
        return rep;
      }
    }
    return null;
  }

  /// Create enhanced analysis result with visual analysis data
  AnalysisResult _createEnhancedAnalysisResult(
    SquatAnalysisResult squatAnalysis,
    String originalVideoPath,
    String processedVideoPath,
    List<VideoFrameData> frameData,
  ) {
    // Convert SquatRepData to RepetitionData
    final repetitionDetails = squatAnalysis.repetitions.map((rep) {
      return RepetitionData(
        repNumber: rep.repNumber,
        startTime: rep.startTime,
        endTime: rep.endTime,
        isCorrect: rep.isCorrect,
        minKneeAngle: rep.minKneeAngle,
        minHipAngle: rep.minHipAngle,
        formIssues: rep.formIssues.map((issue) => issue.toString()).toList(),
      );
    }).toList();

    // Create frame analysis data
    final frameAnalysisData = {
      'total_frames': frameData.length,
      'fps': frameData.length > 1 ? frameData.length / (frameData.last.timestamp - frameData.first.timestamp) : 30.0,
      'analysis_timestamp': DateTime.now().toIso8601String(),
      'pose_detection_confidence': frameData
          .where((frame) => frame.keyPoints != null)
          .map((frame) => frame.keyPoints!.map((kp) => kp.score).reduce((a, b) => a + b) / frame.keyPoints!.length)
          .toList(),
    };

    // Calculate duration and calories
    final duration = frameData.isNotEmpty 
        ? (frameData.last.timestamp - frameData.first.timestamp).round()
        : 60;
    final caloriesBurned = (squatAnalysis.totalReps * 0.5).round();

    return AnalysisResult(
      correctSquats: squatAnalysis.correctReps,
      incorrectSquats: squatAnalysis.incorrectReps,
      avgKneeAngle: squatAnalysis.averageKneeAngle,
      avgHipAngle: squatAnalysis.averageHipAngle,
      feedback: squatAnalysis.overallFeedback,
      duration: duration,
      caloriesBurned: caloriesBurned,
      analysisDate: DateTime.now(),
      exerciseType: 'Squat',
      originalVideoPath: originalVideoPath,
      processedVideoPath: processedVideoPath,
      repetitionDetails: repetitionDetails,
      frameAnalysisData: frameAnalysisData,
      hasVisualAnalysis: true,
    );
  }

  /// Clean up resources
  void dispose() {
    _frameProcessor.dispose();
    _outputGenerator.cleanupTempFiles();
  }
}
