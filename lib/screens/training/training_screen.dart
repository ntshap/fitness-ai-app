import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
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
  bool _isCameraInitialized = false;
  late PoseDetectorService _poseDetectorService;
  List<double?>? _keypoints;
  Size? _imageSize;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _poseDetectorService = PoseDetectorService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (!mounted) return;

        setState(() {
          _isCameraInitialized = true;
          _imageSize = Size(
            _cameraController!.value.previewSize!.height,
            _cameraController!.value.previewSize!.width,
          );
        });

        _cameraController!.startImageStream(_processCameraImage);
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isProcessing) return;
    _isProcessing = true;
    _poseDetectorService.processCameraImage(image).then((keypoints) {
      if (mounted) {
        setState(() {
          _keypoints = keypoints;
        });
      }
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseDetectorService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Mempersiapkan kamera...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          if (_keypoints != null && _imageSize != null)
            CustomPaint(
              painter: PosePainter(
                keypoints: _keypoints!,
                originalImageSize: _imageSize!,
                canvasSize: MediaQuery.of(context).size,
              ),
            ),
        ],
      ),
    );
  }
}
