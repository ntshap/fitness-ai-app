import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/squat_analysis_service.dart';
import 'package:fitness_ai_app/services/workout_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/widgets/training/enhanced_pose_painter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_ai_app/config/app_colors.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  final WorkoutService _workoutService = WorkoutService();
  List<KeyPoint> _keyPoints = [];
  bool _isCameraInitialized = false;
  Timer? _analysisTimer;

  // Workout session tracking
  DateTime? _sessionStartTime;
  Duration _sessionDuration = Duration.zero;
  Timer? _sessionTimer;

  // Enhanced state management
  List<List<KeyPoint>> _recentKeyPoints = [];
  List<double> _recentTimestamps = [];
  
  // Analysis results
  int _correctSquats = 0;
  int _incorrectSquats = 0;
  String _currentFeedback = '';
  
  // Camera switching
  bool _isUsingFrontCamera = true;
  List<CameraDescription> _availableCameras = [];

  // Session management
  bool _isSavingSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStartTime = DateTime.now();
    _startSessionTimer();
    _initializeCamera();
    _startRealTimeAnalysis();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveSessionData(); // Auto-save before disposing
    _sessionTimer?.cancel();
    _analysisTimer?.cancel();
    _cameraController?.dispose();
    _poseDetectorService.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-save when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveSessionData();
    }
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionStartTime != null && mounted) {
        setState(() {
          _sessionDuration = DateTime.now().difference(_sessionStartTime!);
        });
      }
    });
  }

  Future<void> _saveSessionData() async {
    if (_isSavingSession || _sessionStartTime == null) return;
    
    try {
      setState(() {
        _isSavingSession = true;
      });

      final totalSquats = _correctSquats + _incorrectSquats;
      if (totalSquats == 0) {
        // No workout data to save
        return;
      }

      // Calculate estimated calories (rough estimate: 0.3 calories per squat)
      final estimatedCalories = (totalSquats * 0.3).round();
      
      // Create analysis result
      final analysisResult = AnalysisResult(
        totalSquats: totalSquats,
        correctSquats: _correctSquats,
        incorrectSquats: _incorrectSquats,
        caloriesBurned: estimatedCalories,
        accuracy: totalSquats > 0 ? (_correctSquats / totalSquats * 100) : 0.0,
        duration: _sessionDuration,
        feedback: _currentFeedback.isNotEmpty ? [_currentFeedback] : ['Session completed'],
        analysisTimestamp: DateTime.now(),
      );

      // Save to database
      final result = await _workoutService.saveAnalysisResult(analysisResult);
      
      if (result['success'] && mounted) {
        print('Training session auto-saved: ${result['message']}');
      }
    } catch (e) {
      print('Error saving training session: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSession = false;
        });
      }
    }
  }

  Future<void> _finishWorkout() async {
    await _saveSessionData();
    if (mounted) {
      Navigator.pop(context);
    }
  }
    _analysisTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    var cameraPermission = await Permission.camera.request();
    if (cameraPermission.isGranted) {
      _availableCameras = await availableCameras();
      _setCamera(_isUsingFrontCamera);
    } else {
      // Handle permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required for pose detection'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setCamera(bool useFrontCamera) async {
    // Dispose of the previous camera controller properly
    if (_cameraController != null) {
      setState(() {
        _isCameraInitialized = false;
      });
      
      try {
        await _cameraController!.stopImageStream();
        await _cameraController!.dispose();
      } catch (e) {
        print('Error disposing camera: $e');
      }
    }

    // Find the appropriate camera
    CameraDescription? targetCamera;
    for (final camera in _availableCameras) {
      if (useFrontCamera && camera.lensDirection == CameraLensDirection.front) {
        targetCamera = camera;
        break;
      } else if (!useFrontCamera && camera.lensDirection == CameraLensDirection.back) {
        targetCamera = camera;
        break;
      }
    }
    
    // Fall back to first available camera if target not found
    targetCamera ??= _availableCameras.isNotEmpty ? _availableCameras.first : null;
    
    if (targetCamera == null) {
      print('No camera available');
      return;
    }

    try {
      _cameraController = CameraController(
        targetCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processCameraImage);
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isUsingFrontCamera = useFrontCamera;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    final keyPoints = await _poseDetectorService.processCameraImage(image);
    if (mounted && keyPoints != null) {
      // Check if keypoints are real (high confidence) or mock (low confidence)
      final highConfidencePoints = keyPoints.where((kp) => kp.score > 0.5).length;
      final isRealDetection = highConfidencePoints >= 8; // Need at least 8 high-confidence points
      
      setState(() {
        _keyPoints = keyPoints;
      });
      
      // Only add to analysis history if we have real detection (not mock data)
      if (isRealDetection) {
        _addToAnalysisHistory(keyPoints);
        _analyzeCurrentPose(keyPoints);
      }
    }
  }

  void _addToAnalysisHistory(List<KeyPoint> keyPoints) {
    final timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    _recentKeyPoints.add(keyPoints);
    _recentTimestamps.add(timestamp);
    
    // Keep only recent data (last 10 seconds)
    while (_recentTimestamps.isNotEmpty && 
           timestamp - _recentTimestamps.first > 10.0) {
      _recentKeyPoints.removeAt(0);
      _recentTimestamps.removeAt(0);
    }
  }

  void _analyzeCurrentPose(List<KeyPoint> keyPoints) {
    if (keyPoints.length < 17) return;
    
    // Calculate current knee angle
    final kneeAngle = _calculateKneeAngle(keyPoints);
    
    // Generate real-time feedback
    final feedback = _generateRealTimeFeedback(keyPoints, kneeAngle);
    
    setState(() {
      _currentFeedback = feedback;
    });
  }

  void _startRealTimeAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_recentKeyPoints.length > 15) { // Analyze if we have enough data
        _performSquatAnalysis();
      }
    });
  }

  void _performSquatAnalysis() {
    if (_recentKeyPoints.isEmpty) return;
    
    final result = SquatAnalysisService().analyzeSquatSequence(
      _recentKeyPoints, 
      _recentTimestamps
    );
    
    // Update squat counts based on new detections
    final newTotal = result.totalReps;
    final newCorrect = result.correctReps;
    final newIncorrect = result.incorrectReps;
    
    if (newTotal > _correctSquats + _incorrectSquats) {
      setState(() {
        _correctSquats = newCorrect;
        _incorrectSquats = newIncorrect;
      });
    }
  }

  double _calculateKneeAngle(List<KeyPoint> keyPoints) {
    if (keyPoints.length < 17) return 0.0;
    
    final hip = keyPoints[12]; // Right hip
    final knee = keyPoints[14]; // Right knee  
    final ankle = keyPoints[16]; // Right ankle
    
    if (hip.score < 0.5 || knee.score < 0.5 || ankle.score < 0.5) {
      return 0.0;
    }
    
    return _calculateAngle(hip, knee, ankle);
  }

  double _calculateAngle(KeyPoint p1, KeyPoint p2, KeyPoint p3) {
    final v1x = p1.x - p2.x;
    final v1y = p1.y - p2.y;
    final v2x = p3.x - p2.x;
    final v2y = p3.y - p2.y;

    final dot = v1x * v2x + v1y * v2y;
    final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    final mag2 = math.sqrt(v2x * v2x + v2y * v2y);

    if (mag1 == 0 || mag2 == 0) return 0.0;

    final cosAngle = dot / (mag1 * mag2);
    final angle = math.acos(cosAngle.clamp(-1.0, 1.0)) * 180 / math.pi;

    return angle;
  }

  SquatPhase _detectSquatPhase(double kneeAngle) {
    if (kneeAngle > 160) return SquatPhase.standing;
    if (kneeAngle > 120) return SquatPhase.descending;
    if (kneeAngle > 100) return SquatPhase.bottom;
    return SquatPhase.ascending;
  }

  String _generateRealTimeFeedback(List<KeyPoint> keyPoints, double kneeAngle) {
    if (keyPoints.length < 17) return '';
    
    final issues = <String>[];
    
    // Check squat depth
    if (kneeAngle > 120) {
      issues.add('Lower Your Hips');
    }
    
    // Check knee alignment
    final leftKnee = keyPoints[13];
    final leftAnkle = keyPoints[15];
    
    if (leftKnee.score > 0.5 && leftAnkle.score > 0.5) {
      if (leftKnee.x < leftAnkle.x - 0.05) { // Knee significantly past toe
        issues.add('Knees Falling Over Toe');
      }
    }
    
    // Check back posture
    final leftShoulder = keyPoints[5];
    final rightShoulder = keyPoints[6];
    final leftHip = keyPoints[11];
    final rightHip = keyPoints[12];
    
    if (leftShoulder.score > 0.5 && rightShoulder.score > 0.5 && 
        leftHip.score > 0.5 && rightHip.score > 0.5) {
      final shoulderCenter = (leftShoulder.x + rightShoulder.x) / 2;
      final hipCenter = (leftHip.x + rightHip.x) / 2;
      
      if ((shoulderCenter - hipCenter).abs() > 0.1) {
        issues.add('Bend Backwards');
      }
    }
    
    // Return first issue or positive feedback
    if (issues.isNotEmpty) {
      return issues.first;
    } else {
      return 'Good Form!';
    }
  }

  void _toggleCamera() async {
    if (_availableCameras.length < 2) {
      // Show message that only one camera is available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only one camera available on this device'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    final newValue = !_isUsingFrontCamera;
    _setCamera(newValue);
  }

  bool _isRealDetection() {
    if (_keyPoints.isEmpty) return false;
    
    // Check if keypoints are real (high confidence) or mock (low confidence)
    final highConfidencePoints = _keyPoints.where((kp) => kp.score > 0.5).length;
    return highConfidencePoints >= 8; // Need at least 8 high-confidence points
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          
          // Enhanced pose overlay with real-time feedback
          if (_keyPoints.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: EnhancedPosePainter(
                  keyPoints: _keyPoints,
                  correctSquats: _correctSquats,
                  incorrectSquats: _incorrectSquats,
                  currentFeedback: _currentFeedback,
                  currentKneeAngle: _calculateKneeAngle(_keyPoints),
                  isSquatting: _detectSquatPhase(_calculateKneeAngle(_keyPoints)) != SquatPhase.standing,
                  squatPhase: _detectSquatPhase(_calculateKneeAngle(_keyPoints)),
                ),
              ),
            ),
          
          // Top overlay with counts (like in your image)
          Positioned(
            top: 50,
            left: 70, // Move right to make room for camera switch button
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Detection Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isRealDetection() ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isRealDetection() ? '🤖 AI ACTIVE' : '⚠️ POINT AT BODY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CORRECT: $_correctSquats',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INCORRECT: $_incorrectSquats',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Feedback overlay (like "Bend Backwards", "Lower Your Hips")
          if (_currentFeedback.isNotEmpty)
            Positioned(
              top: 120,
              left: 70, // Align with the counter overlay
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _currentFeedback.contains('Good') 
                      ? Colors.green.withOpacity(0.8)
                      : Colors.yellow.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentFeedback,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          
          // Camera toggle button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: _toggleCamera,
                icon: Icon(
                  _isUsingFrontCamera ? Icons.camera_rear : Icons.camera_front,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: _isUsingFrontCamera ? 'Switch to Back Camera' : 'Switch to Front Camera',
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
