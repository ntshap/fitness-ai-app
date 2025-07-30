import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/services/workout_service.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/widgets/training/pose_painter.dart';
import 'package:permission_handler/permission_handler.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  late PoseDetectorService _poseDetectorService;
  late WorkoutService _workoutService;
  List<KeyPoint>? _keyPoints;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;
  Timer? _frameTimer;
  
  // Workout tracking
  int _squatCount = 0;
  DateTime? _workoutStartTime;
  String _feedback = 'Ready to start!';
  bool _isSquatPosition = false;
  
  // Pose detection state
  bool _showLandmarks = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poseDetectorService = PoseDetectorService();
    _workoutService = WorkoutService();
    _workoutStartTime = DateTime.now();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameTimer?.cancel();
    _saveWorkoutData();
    _cameraController?.dispose();
    _poseDetectorService.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _saveWorkoutData() async {
    if (_squatCount > 0 && _workoutStartTime != null) {
      try {
        final duration = DateTime.now().difference(_workoutStartTime!);
        final analysisResult = AnalysisResult(
          correctSquats: _squatCount,
          incorrectSquats: 0,
          avgKneeAngle: 90.0,
          avgHipAngle: 90.0,
          feedback: ['Training session completed', _feedback],
          duration: duration.inSeconds,
          caloriesBurned: (_squatCount * 0.3).round(),
          analysisDate: DateTime.now(),
          exerciseType: 'Squat',
        );

        await _workoutService.saveAnalysisResult(analysisResult);
        print('Workout auto-saved: $_squatCount squats');
      } catch (e) {
        print('Error saving workout data: $e');
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      var cameraPermission = await Permission.camera.request();
      if (cameraPermission.isGranted) {
        final cameras = await availableCameras();
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        await _cameraController!.initialize();
        _startFrameProcessing();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        print('Camera permission denied');
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startFrameProcessing() {
    _frameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_cameraController != null && 
          _cameraController!.value.isInitialized && 
          !_isProcessingFrame) {
        _cameraController!.startImageStream(_processCameraImage);
        timer.cancel();
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame) return;
    
    _isProcessingFrame = true;
    
    try {
      final keyPoints = await _poseDetectorService.processCameraImage(image);
      
      if (keyPoints != null && keyPoints.isNotEmpty && mounted) {
        final squatAnalysis = _detectSquatFromKeyPoints(keyPoints);
        
        setState(() {
          _keyPoints = keyPoints;
          if (squatAnalysis['newSquat'] == true) {
            _squatCount++;
            _feedback = 'Great squat! Total: $_squatCount';
            HapticFeedback.lightImpact(); // Haptic feedback
          }
          _isSquatPosition = squatAnalysis['isInPosition'] ?? false;
        });
      }
    } catch (e) {
      print('Error processing camera image: $e');
    } finally {
      // Add delay to prevent overprocessing
      await Future.delayed(const Duration(milliseconds: 100));
      _isProcessingFrame = false;
    }
  }

  Map<String, dynamic> _detectSquatFromKeyPoints(List<KeyPoint> keyPoints) {
    try {
      if (keyPoints.length >= 17) {
        final leftKnee = keyPoints[13];
        final rightKnee = keyPoints[14];
        final leftHip = keyPoints[11];
        final rightHip = keyPoints[12];
        
        if (leftKnee.score > 0.5 && rightKnee.score > 0.5 && 
            leftHip.score > 0.5 && rightHip.score > 0.5) {
          
          final avgKneeY = (leftKnee.y + rightKnee.y) / 2;
          final avgHipY = (leftHip.y + rightHip.y) / 2;
          final kneeHipDiff = avgKneeY - avgHipY;
          
          bool isInSquatPosition = kneeHipDiff > 0.1;
          bool newSquat = false;
          
          // Simple squat detection logic
          if (isInSquatPosition && !_isSquatPosition) {
            newSquat = true;
          }
          
          return {
            'isInPosition': isInSquatPosition,
            'newSquat': newSquat,
          };
        }
      }
    } catch (e) {
      print('Error in squat detection: $e');
    }
    
    return {
      'isInPosition': false,
      'newSquat': false,
    };
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
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Initializing SquatSense AI Camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          
          // Pose landmarks overlay
          if (_keyPoints != null && _showLandmarks)
            Positioned.fill(
              child: CustomPaint(
                painter: PosePainter(keyPoints: _keyPoints!),
              ),
            ),
          
          // Top overlay with squat counter
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SQUATS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_squatCount',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Landmarks toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showLandmarks = !_showLandmarks;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.withOpacity(0.5)),
                    ),
                    child: Icon(
                      _showLandmarks ? Icons.visibility : Icons.visibility_off,
                      color: _showLandmarks ? Colors.purple : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Positioned(
            top: 130,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isSquatPosition 
                    ? Colors.green.withOpacity(0.8)
                    : Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isSquatPosition ? 'SQUAT POSITION DETECTED' : 'STAND READY',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Feedback overlay
          Positioned(
            bottom: 200,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Text(
                _feedback,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Close button
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await _saveWorkoutData();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: const Text(
                'FINISH WORKOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
