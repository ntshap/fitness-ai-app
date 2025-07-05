import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/models/analysis_result.dart';
import 'package:fitness_ai_app/widgets/upload/result_metric_widget.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/services/workout_service.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final AnalysisResult result;
  const AnalysisResultsScreen({super.key, required this.result});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  final WorkoutService _workoutService = WorkoutService();
  bool _isSaving = false;
  bool _isSaved = false;
  String _saveMessage = '';

  // Video player controllers
  VideoPlayerController? _originalVideoController;
  VideoPlayerController? _processedVideoController;
  bool _isOriginalVideoInitialized = false;
  bool _isProcessedVideoInitialized = false;
  bool _showProcessedVideo = false;

  @override
  void initState() {
    super.initState();
    // Automatically save the results when screen loads
    _saveResults();
    // Initialize video players if video paths are available
    _initializeVideoPlayers();
  }

  Future<void> _initializeVideoPlayers() async {
    // Initialize original video player
    if (widget.result.originalVideoPath != null) {
      _originalVideoController = VideoPlayerController.file(
        File(widget.result.originalVideoPath!),
      );
      try {
        await _originalVideoController!.initialize();
        setState(() {
          _isOriginalVideoInitialized = true;
        });
      } catch (e) {
        print('Error initializing original video: $e');
      }
    }

    // Initialize processed video player
    if (widget.result.processedVideoPath != null) {
      _processedVideoController = VideoPlayerController.file(
        File(widget.result.processedVideoPath!),
      );
      try {
        await _processedVideoController!.initialize();
        setState(() {
          _isProcessedVideoInitialized = true;
          _showProcessedVideo = true; // Show processed video by default if available
        });
      } catch (e) {
        print('Error initializing processed video: $e');
      }
    }
  }

  Future<void> _saveResults() async {
    print('=== ANALYSIS RESULTS SAVE START ===');
    print('Analysis data: ${widget.result.totalSquats} squats, ${widget.result.caloriesBurned} calories');

    setState(() {
      _isSaving = true;
    });

    final result = await _workoutService.saveAnalysisResult(widget.result);

    print('Save result: ${result['success']}');
    print('Save message: ${result['message']}');
    if (result['success']) {
      print('Workout ID: ${result['workoutId']}');
      print('Exercise ID: ${result['exerciseId']}');
      print('Analysis ID: ${result['analysisId']}');
    }

    setState(() {
      _isSaving = false;
      _isSaved = result['success'];
      _saveMessage = result['message'];
    });

    if (result['success']) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_saveMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('=== ANALYSIS RESULTS SAVED SUCCESSFULLY ===');
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_saveMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('=== ANALYSIS RESULTS SAVE FAILED ===');
    }
  }

  @override
  void dispose() {
    _originalVideoController?.dispose();
    _processedVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Analisis', style: AppTextStyles.headline1),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analisis Selesai!',
                          style: AppTextStyles.headline2.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berikut adalah ringkasan dari sesi latihan Anda.',
                          style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Video Analysis Section
            if (widget.result.hasVisualAnalysis) _buildVideoAnalysisSection(),
            if (widget.result.hasVisualAnalysis) const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Squat Benar',
                    value: widget.result.correctSquats.toString(),
                    icon: Icons.check,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Squat Salah',
                    value: widget.result.incorrectSquats.toString(),
                    icon: Icons.close,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
             Row(
              children: [
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Rata-rata Sudut Lutut',
                    value: '${widget.result.avgKneeAngle.toStringAsFixed(1)}°',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Rata-rata Sudut Pinggul',
                    value: '${widget.result.avgHipAngle.toStringAsFixed(1)}°',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Saran & Umpan Balik',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            ...widget.result.feedback.map((item) => _buildFeedbackItem(item)),
            const SizedBox(height: 32),
            // Add additional metrics
            Row(
              children: [
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Total Squat',
                    value: widget.result.totalSquats.toString(),
                    icon: Icons.fitness_center,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Kalori Terbakar',
                    value: '${widget.result.caloriesBurned}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Durasi',
                    value: '${(widget.result.duration / 60).toStringAsFixed(1)}m',
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResultMetricWidget(
                    label: 'Akurasi',
                    value: '${widget.result.accuracy.toStringAsFixed(1)}%',
                    icon: Icons.analytics,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Save status indicator
            if (_isSaving)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(width: 16),
                  Text('Menyimpan hasil analisis...', style: TextStyle(color: Colors.white70)),
                ],
              )
            else if (_isSaved)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Text('Hasil analisis tersimpan!', style: TextStyle(color: Colors.green)),
                ],
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text('Gagal menyimpan hasil', style: TextStyle(color: Colors.red)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyRegular.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Analysis',
          style: AppTextStyles.headline2,
        ),
        const SizedBox(height: 16),

        // Video toggle buttons
        if (_isOriginalVideoInitialized && _isProcessedVideoInitialized)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showProcessedVideo = false;
                    });
                    _processedVideoController?.pause();
                    _originalVideoController?.play();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showProcessedVideo ? AppColors.primary : Colors.grey,
                  ),
                  child: const Text('Original Video'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showProcessedVideo = true;
                    });
                    _originalVideoController?.pause();
                    _processedVideoController?.play();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showProcessedVideo ? AppColors.primary : Colors.grey,
                  ),
                  child: const Text('Analyzed Video'),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Video player
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildVideoPlayer(),
          ),
        ),

        const SizedBox(height: 16),

        // Video controls
        _buildVideoControls(),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_showProcessedVideo && _isProcessedVideoInitialized) {
      return AspectRatio(
        aspectRatio: _processedVideoController!.value.aspectRatio,
        child: VideoPlayer(_processedVideoController!),
      );
    } else if (!_showProcessedVideo && _isOriginalVideoInitialized) {
      return AspectRatio(
        aspectRatio: _originalVideoController!.value.aspectRatio,
        child: VideoPlayer(_originalVideoController!),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildVideoControls() {
    final controller = _showProcessedVideo ? _processedVideoController : _originalVideoController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Progress bar
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: AppColors.primary,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black26,
          ),
        ),

        const SizedBox(height: 8),

        // Play/pause button and time display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.primary,
                size: 32,
              ),
            ),

            Text(
              '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
              style: AppTextStyles.bodyRegular.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
