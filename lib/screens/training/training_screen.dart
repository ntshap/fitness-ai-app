import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'package:fitness_ai_app/widgets/training/pose_painter.dart';
import 'package:permission_handler/permission_handler.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  CameraController? _cameraController;
  late PoseDetectorService _poseDetectorService;
  List<KeyPoint>? _keyPoints; // Tipe data diubah menjadi List<KeyPoint>
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _poseDetectorService = PoseDetectorService();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetectorService.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
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
      );

      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processCameraImage);
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } else {
      // Handle permission denied
    }
  }

  void _processCameraImage(CameraImage image) async {
    final keyPoints = await _poseDetectorService.processCameraImage(image);
    if (mounted) {
      setState(() {
        _keyPoints = keyPoints; // Ini akan menyelesaikan error 'invalid_assignment'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_keyPoints != null)
            CustomPaint(
              painter: PosePainter(keyPoints: _keyPoints!),
            ),
        ],
      ),
    );
  }
}
