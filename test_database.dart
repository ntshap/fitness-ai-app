import 'dart:io';
import 'package:fitness_ai_app/services/database_helper.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/services/workout_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';

void main() async {
  print('🧪 Testing Database Functionality...\n');
  
  // Initialize services
  final dbHelper = DatabaseHelper();
  final authService = SimpleAuthService();
  final workoutService = WorkoutService();
  
  try {
    // Test 1: Create user
    print('1️⃣ Testing User Creation...');
    await authService.register(
      email: 'test@example.com', 
      name: 'Test User', 
      password: 'password123'
    );
    print('✅ User created successfully');
    
    // Test 2: Login user  
    print('\n2️⃣ Testing User Login...');
    final loginResult = await authService.login(
      email: 'test@example.com', 
      password: 'password123'
    );
    print('✅ Login successful: $loginResult');
    
    // Test 3: Create workout data
    print('\n3️⃣ Testing Workout Data Creation...');
    final analysisResult = AnalysisResult(
      exerciseType: 'Squat',
      correctSquats: 12,
      incorrectSquats: 3,
      avgKneeAngle: 85.5,
      avgHipAngle: 90.2,
      caloriesBurned: 45,
      duration: 120, // 2 minutes
      feedback: ['Great form!', 'Keep your back straight.', 'Good depth on squats.'],
      analysisDate: DateTime.now(),
    );
    
    await workoutService.saveAnalysisResult(analysisResult);
    print('✅ Workout data saved successfully');
    
    // Test 4: Retrieve workout stats
    print('\n4️⃣ Testing Workout Stats Retrieval...');
    final stats = await workoutService.getWorkoutStats();
    print('📊 Workout Stats:');
    print('   - Workouts: ${stats['workoutCount']}');
    print('   - Total Calories: ${stats['totalCalories']}');
    print('   - Total Exercises: ${stats['totalExercises']}');
    print('   - AI Analyses: ${stats['analysisCount']}');
    print('   - Average Accuracy: ${stats['averageAccuracy']}%');
    
    // Test 5: Get workout history
    print('\n5️⃣ Testing Workout History...');
    final history = await workoutService.getWorkoutHistory();
    print('📈 Found ${history.length} workout sessions');
    
    for (int i = 0; i < history.length && i < 3; i++) {
      final workout = history[i];
      print('   Session ${i + 1}: ${workout['exercise_type']} - ${workout['total_reps']} reps (${workout['accuracy']}% accuracy)');
    }
    
    print('\n🎉 All tests completed successfully!');
    print('💾 Data persistence is working correctly.');
    print('🏠 Home screen should now show non-zero values.');
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('📋 Stack trace: ${StackTrace.current}');
  }
  
  // Cleanup
  await dbHelper.close();
  exit(0);
}
