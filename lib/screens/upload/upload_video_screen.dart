import 'dart:io';
// Import 'analysis_result.dart' tidak lagi digunakan di sini dan telah dihapus.
import 'package:fitness_ai_app/screens/upload/analysis_results_screen.dart';
import 'package:fitness_ai_app/services/enhanced_video_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  bool _isAnalyzing = false;
  String _analysisMessage = '';
  double _analysisProgress = 0.0;

  // Fungsi untuk memilih video dari galeri
  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoFile = File(pickedFile.path);
      // Inisialisasi video player setelah video dipilih
      _videoPlayerController = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController?.play();
          _videoPlayerController?.setLooping(true);
        });
    }
  }

  // Fungsi untuk memulai proses analisis video
  void _analyzeVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisMessage = 'Starting analysis...';
      _analysisProgress = 0.0;
    });

    try {
      final analysisService = EnhancedVideoAnalysisService();
      final result = await analysisService.analyzeVideoWithVisualOverlays(
        _videoFile!.path,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _analysisMessage = progress.message;
              _analysisProgress = progress.progress;
            });
          }
        },
      );

      // Navigasi ke layar hasil analisis jika proses berhasil
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(result: result),
          ),
        );
      }
    } catch (e) {
      // Menampilkan pesan error yang lebih spesifik
      String errorMessage = 'Error saat menganalisis video';
      
      if (e.toString().contains('No frames could be extracted')) {
        errorMessage = 'Tidak dapat mengekstrak frame dari video. Pastikan format video didukung.';
      } else if (e.toString().contains('No valid pose data detected')) {
        errorMessage = 'Tidak dapat mendeteksi pose dalam video. Pastikan orang terlihat jelas di video.';
      } else if (e.toString().contains('Video is too long')) {
        errorMessage = 'Video terlalu panjang. Maksimal 5 menit.';
      } else if (e.toString().contains('Video file not found')) {
        errorMessage = 'File video tidak ditemukan.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Analisis video memakan waktu terlalu lama. Coba video yang lebih pendek.';
      }
      
      print('Video analysis error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Memastikan status 'isAnalyzing' kembali ke false setelah selesai
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
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
        title: const Text('Unggah Video'),
        backgroundColor: AppColors.primary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight,
                ),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_videoFile == null)
                          GestureDetector(
                            onTap: _pickVideo,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_library, size: 50, color: AppColors.primary),
                                  SizedBox(height: 8),
                                  Text('Ketuk untuk memilih video', style: TextStyle(color: AppColors.primary)),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                                  AspectRatio(
                                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                                    child: VideoPlayer(_videoPlayerController!),
                                  )
                                else
                                  const SizedBox(
                                    height: 200,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                const SizedBox(height: 20),
                                if (_isAnalyzing)
                                  Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: _analysisProgress,
                                        backgroundColor: Colors.grey[300],
                                        color: AppColors.primary,
                                        minHeight: 10,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        _analysisMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  )
                                else
                                  AuthButton(
                                    onPressed: _isAnalyzing ? null : _analyzeVideo,
                                    text: 'Analisis Video',
                                  ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _isAnalyzing ? null : _pickVideo,
                                  child: const Text('Pilih video lain', style: TextStyle(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
