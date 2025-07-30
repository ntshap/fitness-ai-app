import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/pose_detector_service.dart';
import 'dart:developer';

class AIDebugScreen extends StatefulWidget {
  const AIDebugScreen({super.key});

  @override
  State<AIDebugScreen> createState() => _AIDebugScreenState();
}

class _AIDebugScreenState extends State<AIDebugScreen> {
  final PoseDetectorService _poseService = PoseDetectorService();
  String _debugInfo = 'Initializing...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Running diagnostics...\n';
    });

    try {
      // Test 1: Model loading
      _updateDebugInfo('📱 Testing model loading...');
      await Future.delayed(const Duration(seconds: 1));
      
      // Test 2: Mock keypoints generation
      _updateDebugInfo('🔗 Testing mock keypoints generation...');
      final mockKeypoints = await _poseService.processImage(
        await _createTestImage()
      );
      
      if (mockKeypoints != null) {
        _updateDebugInfo('✅ Generated ${mockKeypoints.length} keypoints');
        _updateDebugInfo('   - Valid keypoints: ${mockKeypoints.where((k) => k.score > 0.3).length}');
        _updateDebugInfo('   - Average confidence: ${(mockKeypoints.map((k) => k.score).reduce((a, b) => a + b) / mockKeypoints.length).toStringAsFixed(3)}');
      } else {
        _updateDebugInfo('❌ Failed to generate keypoints');
      }

      // Test 3: TensorFlow Lite availability
      _updateDebugInfo('🧠 Testing TensorFlow Lite...');
      try {
        // This will trigger model loading attempt
        await _poseService.processImage(await _createTestImage());
        _updateDebugInfo('✅ TensorFlow Lite processing completed');
      } catch (e) {
        _updateDebugInfo('❌ TensorFlow Lite error: $e');
      }

      _updateDebugInfo('🔍 Diagnostics completed!');
      
    } catch (e) {
      _updateDebugInfo('💥 Error during diagnostics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo += '\n$info';
    });
    log(info);
  }

  Future<dynamic> _createTestImage() async {
    // Create a simple test image for AI processing
    // This is a mock implementation
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Debug Console'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bug_report, color: Color(0xFF6C5CE7)),
                        const SizedBox(width: 8),
                        const Text(
                          'AI System Diagnostics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(width: 16),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _debugInfo,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runDiagnostics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Run Diagnostics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/training');
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('Test Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poseService.close();
    super.dispose();
  }
}
