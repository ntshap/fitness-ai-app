import 'dart:io';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/screens/upload/analysis_results_screen.dart';
import 'package:fitness_ai_app/services/enhanced_video_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  File? _videoFile;
  VideoPlayerController? _videoPlayerController;
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  double _progress = 0.0;
  final String _selectedExercise = 'squat';
  String _debugLog = '';

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController?.play();
            _videoPlayerController?.setLooping(true);
          });
      }
    } catch (e) {
      print("Error picking video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih video.')),
      );
    }
  }

  /// Starts the video analysis process.
  /// This now calls the service that runs the analysis in the background,
  /// keeping the UI responsive.
  void _analyzeVideo() async {
    if (_videoFile == null) return;

    // Stop the video player before analysis
    _videoPlayerController?.pause();

    setState(() {
      _isAnalyzing = true;
      _progress = 0.0;
      _debugLog = '';
    });

    try {
      final analysisResult = await EnhancedVideoAnalysisService.analyze(
        videoPath: _videoFile!.path,
        exerciseType: _selectedExercise,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }
        },
        onLog: (log) {
          if (mounted) {
            setState(() {
              _debugLog += log + '\n';
            });
          }
        },
      );

      if (mounted) {
        // Use pushReplacement to avoid returning to the analysis screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(
              result: analysisResult,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error during analysis: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false; // Stop analyzing on error
          _debugLog += '\nERROR: $e\n';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analisis video gagal:\n$e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unggah & Analisis Video',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isAnalyzing ? _buildAnalysisProgress() : _buildVideoUploader(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey[300],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Menganalisis Video...',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Proses ini mungkin memakan waktu beberapa saat. Mohon jangan tutup aplikasi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildVideoUploader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_videoFile != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
          AspectRatio(
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: const Center(
              child: Text(
                'Pratinjau video akan muncul di sini',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _pickVideo,
          icon: const Icon(Icons.video_library),
          label: const Text('Pilih Video dari Galeri'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryText,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _videoFile != null ? _analyzeVideo : null,
          icon: const Icon(Icons.analytics),
          label: const Text('Analisis Video'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (_debugLog.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.black12,
            child: Text(
              _debugLog,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }
}
