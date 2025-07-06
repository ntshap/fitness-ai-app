import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';  // Temporarily disabled due to compatibility issues

class VideoGenerationProgress {
  final int currentFrame;
  final int totalFrames;
  final String stage;
  final double progress;

  VideoGenerationProgress({
    required this.currentFrame,
    required this.totalFrames,
    required this.stage,
    required this.progress,
  });
}

class VideoOutputConfig {
  final int fps;
  final int width;
  final int height;
  final int bitrate;
  final String codec;
  final String format;

  VideoOutputConfig({
    this.fps = 30,
    this.width = 720,
    this.height = 1280,
    this.bitrate = 2000000, // 2 Mbps
    this.codec = 'libx264',
    this.format = 'mp4',
  });
}

class VideoOutputGenerator {
  static final VideoOutputGenerator _instance = VideoOutputGenerator._internal();
  factory VideoOutputGenerator() => _instance;
  VideoOutputGenerator._internal();

  /// Generate video from processed frames with overlays (mock implementation)
  Future<String> generateVideoFromFrames(
    List<img.Image> frames,
    String originalVideoPath, {
    VideoOutputConfig? config,
    Function(VideoGenerationProgress)? onProgress,
  }) async {
    config ??= VideoOutputConfig();

    if (frames.isEmpty) {
      throw Exception('No frames provided for video generation');
    }

    final outputDir = await _getOutputDirectory();
    final tempFramesDir = Directory(path.join(outputDir.path, 'temp_frames_${DateTime.now().millisecondsSinceEpoch}'));
    if (!await tempFramesDir.exists()) {
      await tempFramesDir.create(recursive: true);
    }

    // 1. Simpan semua frame ke file gambar
    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final framePath = path.join(tempFramesDir.path, 'frame_${i.toString().padLeft(5, '0')}.jpg');
      final jpgBytes = img.encodeJpg(frame, quality: 90);
      await File(framePath).writeAsBytes(jpgBytes);
      onProgress?.call(VideoGenerationProgress(
        currentFrame: i + 1,
        totalFrames: frames.length,
        stage: 'Saving frames...',
        progress: (i + 1) / frames.length * 0.5,
      ));
    }

    // 2. Gabungkan gambar jadi video dengan ffmpeg
    final outputFileName = 'analyzed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final outputPath = path.join(outputDir.path, outputFileName);
    final fps = config.fps;
    final width = config.width;
    final height = config.height;

    // Buat file list input untuk ffmpeg
    final framePattern = path.join(tempFramesDir.path, 'frame_%05d.jpg');
    final ffmpegCmd =
        "-y -framerate $fps -i '$framePattern' -vf scale=$width:$height -c:v libx264 -pix_fmt yuv420p '$outputPath'";

    onProgress?.call(VideoGenerationProgress(
      currentFrame: 0,
      totalFrames: frames.length,
      stage: 'Encoding video...',
      progress: 0.6,
    ));

    // Temporarily disabled FFmpeg functionality due to compatibility issues
    // final session = await FFmpegKit.execute(ffmpegCmd);
    // final returnCode = await session.getReturnCode();
    // if (returnCode == null || !returnCode.isValueSuccess()) {
    //   throw Exception('FFmpeg failed to encode video.');
    // }
    
    // For now, create a placeholder file instead of actual video
    await File(outputPath).writeAsString('Mock video file - FFmpeg temporarily disabled');

    onProgress?.call(VideoGenerationProgress(
      currentFrame: frames.length,
      totalFrames: frames.length,
      stage: 'Complete',
      progress: 1.0,
    ));

    // Bersihkan frame gambar sementara
    try {
      await tempFramesDir.delete(recursive: true);
    } catch (_) {}

    return outputPath;
  }

  /// Create video from frame images (mock implementation)
  Future<void> _createVideoFromFrames(
    String framesDir,
    String outputPath,
    VideoOutputConfig config,
    Function(VideoGenerationProgress)? onProgress,
  ) async {
    try {
      // Mock implementation - just create a placeholder file
      await File(outputPath).writeAsString('Mock video file created from frames');
    } catch (e) {
      throw Exception('Failed to create video from frames: $e');
    }
  }

  /// Generate video with audio from original video (mock implementation)
  Future<String> generateVideoWithAudio(
    String processedVideoPath,
    String originalVideoPath, {
    Function(VideoGenerationProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(VideoGenerationProgress(
        currentFrame: 0,
        totalFrames: 1,
        stage: 'Adding audio...',
        progress: 0.0,
      ));

      // For now, just return the processed video path
      // In a production app, you would combine audio from original video

      onProgress?.call(VideoGenerationProgress(
        currentFrame: 1,
        totalFrames: 1,
        stage: 'Complete',
        progress: 1.0,
      ));

      return processedVideoPath;
    } catch (e) {
      // Return processed video without audio if audio combination fails
      return processedVideoPath;
    }
  }

  /// Compress video to reduce file size (mock implementation)
  Future<String> compressVideo(
    String inputPath, {
    int targetBitrate = 1000000, // 1 Mbps
    Function(VideoGenerationProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(VideoGenerationProgress(
        currentFrame: 0,
        totalFrames: 1,
        stage: 'Compressing video...',
        progress: 0.0,
      ));

      // For now, just return the original path
      // In a production app, you would implement video compression

      onProgress?.call(VideoGenerationProgress(
        currentFrame: 1,
        totalFrames: 1,
        stage: 'Complete',
        progress: 1.0,
      ));

      return inputPath;
    } catch (e) {
      throw Exception('Failed to compress video: $e');
    }
  }

  /// Get or create output directory for processed videos
  Future<Directory> _getOutputDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(path.join(appDir.path, 'fitness_ai_videos'));
    
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    
    return outputDir;
  }

  /// Get video information (mock implementation)
  Future<Map<String, dynamic>> getVideoInfo(String videoPath) async {
    try {
      // Return mock video information
      return {
        'duration': 10,
        'width': 720,
        'height': 1280,
        'fps': 30.0,
      };
    } catch (e) {
      return {};
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir.listSync()
          .where((entity) => entity.path.contains('video_frames_') || 
                           entity.path.contains('output_frames_'))
          .toList();
      
      for (final file in tempFiles) {
        if (file is Directory) {
          await file.delete(recursive: true);
        } else {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
