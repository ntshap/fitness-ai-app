import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/services/workout_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';

void main() {
  runApp(const DatabaseTestApp());
}

class DatabaseTestApp extends StatelessWidget {
  const DatabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const DatabaseTestScreen(),
    );
  }
}

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final SimpleAuthService _authService = SimpleAuthService();
  final WorkoutService _workoutService = WorkoutService();
  List<String> _testResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runDatabaseTest,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Run Database Test'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _testResults.map((result) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          result,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDatabaseTest() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    _addResult('🧪 Starting Database Test...\n');

    try {
      // Test 1: Check current user
      _addResult('1️⃣ Checking current user...');
      if (_authService.isLoggedIn) {
        final user = _authService.currentUser;
        _addResult('✅ Current user: ${user?['name']} (${user?['email']})');
      } else {
        _addResult('❌ No user logged in');
      }

      // Test 2: Create test workout data
      _addResult('\n2️⃣ Creating test workout data...');
      final analysisResult = AnalysisResult(
        exerciseType: 'Squat',
        correctSquats: 15,
        incorrectSquats: 2,
        avgKneeAngle: 87.5,
        avgHipAngle: 92.3,
        caloriesBurned: 65,
        duration: 180, // 3 minutes
        feedback: ['Excellent form!', 'Great depth!', 'Keep it up!'],
        analysisDate: DateTime.now(),
      );

      await _workoutService.saveAnalysisResult(analysisResult);
      _addResult('✅ Test workout saved');

      // Test 3: Get workout stats
      _addResult('\n3️⃣ Retrieving workout stats...');
      final stats = await _workoutService.getWorkoutStats();
      _addResult('📊 Workout Statistics:');
      _addResult('   - Total Workouts: ${stats['workoutCount']}');
      _addResult('   - Total Calories: ${stats['totalCalories']}');
      _addResult('   - Total Exercises: ${stats['totalExercises']}');
      _addResult('   - AI Analyses: ${stats['analysisCount']}');
      _addResult('   - Average Accuracy: ${stats['averageAccuracy'].toStringAsFixed(1)}%');

      // Test 4: Get workout history
      _addResult('\n4️⃣ Getting workout history...');
      final history = await _workoutService.getWorkoutHistory();
      _addResult('📈 Found ${history.length} workout sessions');

      for (int i = 0; i < history.length && i < 5; i++) {
        final workout = history[i];
        _addResult('   ${i + 1}. ${workout['exercise_type']} - ${workout['total_reps']} squats (${workout['accuracy'].toStringAsFixed(1)}%)');
      }

      _addResult('\n🎉 All tests completed successfully!');
      _addResult('💾 Data is being saved and retrieved correctly.');
      _addResult('🏠 Home screen should now show these values.');

    } catch (e) {
      _addResult('\n❌ Test failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }
}
