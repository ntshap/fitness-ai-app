class RepetitionData {
  final int repNumber;
  final double startTime;
  final double endTime;
  final bool isCorrect;
  final double minKneeAngle;
  final double minHipAngle;
  final List<String> formIssues;

  RepetitionData({
    required this.repNumber,
    required this.startTime,
    required this.endTime,
    required this.isCorrect,
    required this.minKneeAngle,
    required this.minHipAngle,
    required this.formIssues,
  });

  Map<String, dynamic> toMap() {
    return {
      'rep_number': repNumber,
      'start_time': startTime,
      'end_time': endTime,
      'is_correct': isCorrect,
      'min_knee_angle': minKneeAngle,
      'min_hip_angle': minHipAngle,
      'form_issues': formIssues,
    };
  }
}

class AnalysisResult {
  final int correctSquats;
  final int incorrectSquats;
  final double avgKneeAngle;
  final double avgHipAngle;
  final List<String> feedback;
  final int duration; // Duration in seconds
  final int caloriesBurned; // Calculated calories
  final DateTime analysisDate;
  final String exerciseType; // Type of exercise (e.g., "Squat")

  // Enhanced video analysis properties
  final String? originalVideoPath;
  final String? processedVideoPath;
  final List<RepetitionData>? repetitionDetails;
  final Map<String, dynamic>? frameAnalysisData;
  final bool hasVisualAnalysis;

  AnalysisResult({
    required this.correctSquats,
    required this.incorrectSquats,
    required this.avgKneeAngle,
    required this.avgHipAngle,
    required this.feedback,
    required this.duration,
    required this.caloriesBurned,
    required this.analysisDate,
    this.exerciseType = "Squat",
    this.originalVideoPath,
    this.processedVideoPath,
    this.repetitionDetails,
    this.frameAnalysisData,
    this.hasVisualAnalysis = false,
  });

  // Calculate total squats
  int get totalSquats => correctSquats + incorrectSquats;

  // Calculate accuracy percentage
  double get accuracy => totalSquats > 0 ? (correctSquats / totalSquats) * 100 : 0;

  // Convert to database format for workouts table
  Map<String, dynamic> toWorkoutMap(int userId) {
    return {
      'user_id': userId,
      'name': '$exerciseType Analysis',
      'type': exerciseType,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'date': analysisDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert to database format for ai_analysis table
  Map<String, dynamic> toAIAnalysisMap(int userId, int? workoutId) {
    final poseDataMap = {
      'correct_reps': correctSquats,
      'incorrect_reps': incorrectSquats,
      'avg_knee_angle': avgKneeAngle,
      'avg_hip_angle': avgHipAngle,
      'has_visual_analysis': hasVisualAnalysis,
      'original_video_path': originalVideoPath,
      'processed_video_path': processedVideoPath,
      'repetition_details': repetitionDetails?.map((rep) => rep.toMap()).toList(),
      'frame_analysis_data': frameAnalysisData,
    };

    return {
      'user_id': userId,
      'workout_id': workoutId,
      'analysis_type': exerciseType,
      'pose_data': poseDataMap.toString(),
      'feedback': feedback.join('|'), // Join feedback with separator
      'score': accuracy,
      'created_at': analysisDate.toIso8601String(),
    };
  }

  // Convert to database format for exercises table
  Map<String, dynamic> toExerciseMap(int workoutId) {
    return {
      'workout_id': workoutId,
      'name': exerciseType,
      'sets': 1,
      'reps': totalSquats,
      'duration': duration,
      'notes': 'AI Analysis - Correct: $correctSquats, Incorrect: $incorrectSquats, Accuracy: ${accuracy.toStringAsFixed(1)}%',
    };
  }
}
