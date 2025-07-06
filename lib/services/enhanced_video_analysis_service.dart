import 'dart:async';
import 'dart:isolate';
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/services/video_analysis_isolate.dart';

/// This service is responsible for orchestrating the video analysis.
/// It now offloads the heavy processing work to a separate isolate to prevent
/// blocking the main UI thread.
class EnhancedVideoAnalysisService {
  /// Analyzes a video file in a background isolate.
  ///
  /// [videoPath]: The path to the video file.
  /// [exerciseType]: The type of exercise to analyze (e.g., 'squat').
  /// [onProgress]: A callback function that receives progress updates (from 0.0 to 1.0).
  ///
  /// Returns a [Future] that completes with the [AnalysisResult].
  static Future<AnalysisResult> analyze({
    required String videoPath,
    required String exerciseType,
    required Function(double) onProgress,
  }) async {
    final receivePort = ReceivePort();
    final completer = Completer<AnalysisResult>();

    // Prepare data to be sent to the isolate.
    final isolateData = VideoAnalysisIsolateData(
      videoPath: videoPath,
      exerciseType: exerciseType,
      sendPort: receivePort.sendPort,
    );

    // Spawn the isolate.
    final isolate = await Isolate.spawn(videoAnalysisIsolateEntry, isolateData);

    // Listen for messages from the isolate.
    receivePort.listen((message) {
      if (message is Map) {
        switch (message['type']) {
          case 'progress':
            final progress = message['value'] as double;
            onProgress(progress);
            break;
          case 'result':
            final result = message['value'] as AnalysisResult;
            if (!completer.isCompleted) {
              completer.complete(result);
            }
            break;
          case 'error':
            final error = message['error'];
            final stackTrace = message['stackTrace'];
            print('Error in analysis isolate: $error\n$stackTrace');
            if (!completer.isCompleted) {
              completer.completeError(Exception('Analysis failed in isolate: $error'));
            }
            break;
          case 'done':
            // Clean up resources once the isolate is finished.
            receivePort.close();
            isolate.kill(priority: Isolate.immediate);
            break;
        }
      }
    });

    return completer.future;
  }
}
