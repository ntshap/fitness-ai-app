import 'package:fitness_ai_app/services/database_helper.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SimpleAuthService _authService = SimpleAuthService();

  /// Save analysis result to database
  /// Returns a map with success status and message
  Future<Map<String, dynamic>> saveAnalysisResult(AnalysisResult result) async {
    try {
      // Check if user is logged in
      if (!_authService.isLoggedIn || _authService.currentUser == null) {
        return {
          'success': false,
          'message': 'User tidak login',
        };
      }

      final userId = _authService.currentUser!['id'];
      if (userId == null) {
        return {
          'success': false,
          'message': 'User ID tidak valid',
        };
      }

      print('Saving analysis result for user ID: $userId');

      // 1. Insert workout record
      final workoutData = result.toWorkoutMap(userId);
      print('Inserting workout: $workoutData');
      final workoutId = await _dbHelper.insertWorkout(workoutData);
      print('Workout inserted with ID: $workoutId');

      // 2. Insert exercise record
      final exerciseData = result.toExerciseMap(workoutId);
      print('Inserting exercise: $exerciseData');
      final exerciseId = await _dbHelper.insertExercise(exerciseData);
      print('Exercise inserted with ID: $exerciseId');

      // 3. Insert AI analysis record
      final analysisData = result.toAIAnalysisMap(userId, workoutId);
      print('Inserting AI analysis: $analysisData');
      final analysisId = await _dbHelper.insertAIAnalysis(analysisData);
      print('AI analysis inserted with ID: $analysisId');

      return {
        'success': true,
        'message': 'Hasil analisis berhasil disimpan',
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'analysisId': analysisId,
      };
    } catch (e) {
      print('Error saving analysis result: $e');
      return {
        'success': false,
        'message': 'Gagal menyimpan hasil analisis: $e',
      };
    }
  }

  /// Get workout history for current user
  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    try {
      if (!_authService.isLoggedIn || _authService.currentUser == null) {
        return [];
      }

      final userId = _authService.currentUser!['id'];
      if (userId == null) {
        return [];
      }

      // Get workouts with their exercises and AI analysis
      final workouts = await _dbHelper.getWorkouts(userId);
      
      // Enhance workout data with additional information
      final enhancedWorkouts = <Map<String, dynamic>>[];
      
      for (final workout in workouts) {
        final workoutId = workout['id'];
        
        // Get exercises for this workout
        final exercises = await _dbHelper.getExercises(workoutId);
        
        // Get AI analysis for this workout
        final analyses = await _dbHelper.getAIAnalysis(userId);
        final workoutAnalysis = analyses.where((analysis) => 
          analysis['workout_id'] == workoutId).toList();

        // Create enhanced workout data
        final enhancedWorkout = Map<String, dynamic>.from(workout);
        enhancedWorkout['exercises'] = exercises;
        enhancedWorkout['ai_analysis'] = workoutAnalysis;
        
        // Parse date for better formatting
        try {
          enhancedWorkout['parsed_date'] = DateTime.parse(workout['date']);
        } catch (e) {
          enhancedWorkout['parsed_date'] = DateTime.now();
        }

        enhancedWorkouts.add(enhancedWorkout);
      }

      return enhancedWorkouts;
    } catch (e) {
      print('Error getting workout history: $e');
      return [];
    }
  }

  /// Get workout statistics for current user
  Future<Map<String, dynamic>> getWorkoutStats() async {
    try {
      if (!_authService.isLoggedIn || _authService.currentUser == null) {
        return {
          'workoutCount': 0,
          'totalCalories': 0,
          'totalExercises': 0,
          'analysisCount': 0,
          'averageAccuracy': 0.0,
        };
      }

      final userId = _authService.currentUser!['id'];
      if (userId == null) {
        return {
          'workoutCount': 0,
          'totalCalories': 0,
          'totalExercises': 0,
          'analysisCount': 0,
          'averageAccuracy': 0.0,
        };
      }

      // Get all workouts
      final workouts = await _dbHelper.getWorkouts(userId);
      final workoutCount = workouts.length;
      final totalCalories = workouts.fold<int>(0, (sum, workout) =>
          sum + (workout['calories_burned'] as int? ?? 0));

      // Get all exercises
      int totalExercises = 0;
      for (final workout in workouts) {
        final exercises = await _dbHelper.getExercises(workout['id']);
        totalExercises += exercises.length;
      }

      // Get AI analyses
      final analyses = await _dbHelper.getAIAnalysis(userId);
      final analysisCount = analyses.length;
      
      // Calculate average accuracy from AI analyses
      double averageAccuracy = 0.0;
      if (analyses.isNotEmpty) {
        final totalScore = analyses.fold<double>(0.0, (sum, analysis) =>
            sum + (analysis['score'] as double? ?? 0.0));
        averageAccuracy = totalScore / analyses.length;
      }

      return {
        'workoutCount': workoutCount,
        'totalCalories': totalCalories,
        'totalExercises': totalExercises,
        'analysisCount': analysisCount,
        'averageAccuracy': averageAccuracy,
      };
    } catch (e) {
      print('Error getting workout stats: $e');
      return {
        'workoutCount': 0,
        'totalCalories': 0,
        'totalExercises': 0,
        'analysisCount': 0,
        'averageAccuracy': 0.0,
      };
    }
  }
}
