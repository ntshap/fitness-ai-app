import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/screens/upload/analysis_results_screen.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/services/enhanced_video_analysis_service.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  bool _isProcessing = false;

  // Enhanced analysis service and progress tracking
  final EnhancedVideoAnalysisService _analysisService = EnhancedVideoAnalysisService();
  String _analysisStage = '';
  double _analysisProgress = 0.0;
  String _analysisMessage = '';
  int? _currentFrame;
  int? _totalFrames;

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = pickedFile;
      });
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    if (_videoFile == null) return;
    _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.setLooping(true);
        _videoPlayerController!.play();
      });
  }

  Future<void> _analyzeVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isProcessing = true;
      _analysisStage = 'initialization';
      _analysisProgress = 0.0;
      _analysisMessage = 'Starting analysis...';
    });

    try {
      // Perform enhanced video analysis with visual overlays
      final result = await _analysisService.analyzeVideoWithVisualOverlays(
        _videoFile!.path,
        onProgress: (progress) {
          setState(() {
            _analysisStage = progress.stage;
            _analysisProgress = progress.progress;
            _analysisMessage = progress.message;
            _currentFrame = progress.currentFrame;
            _totalFrames = progress.totalFrames;
          });
        },
      );

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(result: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _analysisMessage = 'Analysis failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unggah Video', style: AppTextStyles.headline1),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isProcessing)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 20),
                      Text(
                        _analysisMessage.isNotEmpty ? _analysisMessage : 'Analyzing video...',
                        style: AppTextStyles.bodyRegular,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _analysisProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_analysisProgress * 100).toInt()}%',
                        style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70, fontSize: 12),
                      ),
                      if (_currentFrame != null && _totalFrames != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Frame $_currentFrame of $_totalFrames',
                            style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: _videoFile == null
                      ? _buildUploadPlaceholder()
                      : _buildVideoPreview(),
                ),
              if (!_isProcessing) const SizedBox(height: 24),
              if (!_isProcessing)
                AuthButton(
                  text: _videoFile == null ? 'Pilih Video' : 'Mulai Analisis',
                  onPressed: _videoFile == null ? _pickVideo : _analyzeVideo,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryText, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, size: 80, color: AppColors.secondaryText),
              const SizedBox(height: 16),
              Text(
                'Ketuk untuk memilih video',
                style: AppTextStyles.bodyRegular,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: VideoPlayer(_videoPlayerController!),
      ),
    );
  }
}
