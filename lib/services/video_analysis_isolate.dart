import 'dart:isolate';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';
import 'package:fitness_ai_app/services/video_frame_processor.dart';
import 'package:fitness_ai_app/services/video_overlay_renderer.dart';
import 'package:fitness_ai_app/services/video_output_generator.dart';

/// Data class to pass initial data to the video analysis isolate.
class VideoAnalysisIsolateData {
  final String videoPath;
  final String exerciseType;
  final SendPort sendPort;

  VideoAnalysisIsolateData({
    required this.videoPath,
    required this.exerciseType,
    required this.sendPort,
  });
}

/// The entry point for the isolate. This function will run on a separate thread.
/// It handles frame extraction, pose detection, and analysis, sending progress
/// and results back to the main thread.
void videoAnalysisIsolateEntry(VideoAnalysisIsolateData data) async {
  void sendLog(String msg) {
    print(msg);
    data.sendPort.send({'type': 'log', 'message': msg});
  }
  try {
    sendLog('[Isolate] Mulai analisis video: ${data.videoPath}');
    data.sendPort.send({
      'type': 'progress', 
      'value': 0.0
    });

    final frameProcessor = VideoFrameProcessor();
    final poseDetector = PoseDetectorService();
    final squatAnalysis = SquatAnalysisService();

    // Step 1: Extract and process video frames
    sendLog('[Isolate] Ekstraksi frame...');
    data.sendPort.send({
      'type': 'progress', 
      'value': 0.1
    });

    List<VideoFrameData> frameData = [];
    try {
      frameData = await frameProcessor.processVideoFrames(
        data.videoPath,
        onProgress: (progress) {
          data.sendPort.send({
            'type': 'progress',
            'value': 0.1 + (progress.progress * 0.7),
          });
        },
      );
      sendLog('[Isolate] Jumlah frame berhasil diekstrak: \\${frameData.length}');
    } catch (e) {
      sendLog('[Isolate] Gagal ekstrak frame: $e');
      frameData = [];
    }

    // Step 2: Analyze squat form
    sendLog('[Isolate] Analisis squat...');
    data.sendPort.send({
      'type': 'progress', 
      'value': 0.85
    });

    SquatAnalysisResult squatAnalysisResult;
    if (frameData.isNotEmpty) {
      final keyPointSequence = frameData.map((frame) => frame.keyPoints ?? <KeyPoint>[]).toList();
      final timestamps = frameData.map((frame) => frame.timestamp).toList();
      squatAnalysisResult = squatAnalysis.analyzeSquatSequence(keyPointSequence, timestamps);
      sendLog('[Isolate] Selesai analisis squat. Total reps: \\${squatAnalysisResult.totalReps}');
    } else {
      squatAnalysisResult = SquatAnalysisResult(
        totalReps: 0,
        correctReps: 0,
        incorrectReps: 0,
        averageKneeAngle: 0,
        averageHipAngle: 0,
        overallFeedback: ['Tidak ada squat terdeteksi.'],
        repetitions: [],
      );
      sendLog('[Isolate] Tidak ada frame valid, hasil default.');
    }

    // Step 3: Create analysis result (NO video overlay)
    data.sendPort.send({
      'type': 'progress', 
      'value': 0.95
    });

    final result = _createAnalysisResult(
      squatAnalysisResult,
      data.videoPath,
      null, // processedVideoPath: tidak ada video hasil
      frameData,
    );

    sendLog('[Isolate] Analisis selesai, kirim hasil ke main thread.');
    data.sendPort.send({'type': 'result', 'value': result});

  } catch (e, stackTrace) {
    sendLog('[Isolate] ERROR FATAL: $e');
    // Fallback: tetap kirim AnalysisResult default
    final fallbackResult = _createAnalysisResult(
      SquatAnalysisResult(
        totalReps: 0,
        correctReps: 0,
        incorrectReps: 0,
        averageKneeAngle: 0,
        averageHipAngle: 0,
        overallFeedback: ['Analisis gagal. Tidak ada data.'],
        repetitions: [],
      ),
      data.videoPath,
      null,
      [],
    );
    data.sendPort.send({'type': 'result', 'value': fallbackResult});
    data.sendPort.send({
      'type': 'error',
      'error': e.toString(),
      'stackTrace': stackTrace.toString()
    });
  } finally {
    data.sendPort.send({'type': 'done'});
  }
}

/// Helper function to find current repetition
SquatRepData? _findCurrentRepetition(List<SquatRepData> repetitions, double timestamp) {
  for (final rep in repetitions) {
    if (timestamp >= rep.startTime && timestamp <= rep.endTime) {
      return rep;
    }
  }
  return null;
}

/// Helper function to create analysis result
AnalysisResult _createAnalysisResult(
  SquatAnalysisResult squatAnalysis,
  String originalVideoPath,
  String? processedVideoPath,
  List<VideoFrameData> frameData,
) {
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

  final frameAnalysisData = {
    'total_frames': frameData.length,
    'fps': frameData.length > 1 ? frameData.length / (frameData.last.timestamp - frameData.first.timestamp) : 30.0,
    'analysis_timestamp': DateTime.now().toIso8601String(),
  };

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
    processedVideoPath: processedVideoPath, // null
    repetitionDetails: repetitionDetails,
    frameAnalysisData: frameAnalysisData,
    hasVisualAnalysis: false, // tidak ada video overlay
  );
}
