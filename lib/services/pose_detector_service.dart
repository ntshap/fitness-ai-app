import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer';

// Kelas sederhana untuk menampung data hasil deteksi
class KeyPoint {
  final double x;
  final double y;
  final double score;

  KeyPoint(this.x, this.y, this.score);
}

class PoseDetectorService {
  late Interpreter _interpreter;
  // Ukuran input yang diharapkan oleh model PoseNet
  static const int inputSize = 257;

  PoseDetectorService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Model didelegasikan ke GPU untuk performa lebih baik
      final options = InterpreterOptions()..addDelegate(GpuDelegateV2());
      _interpreter = await Interpreter.fromAsset('assets/models/posenet_model.tflite', options: options);
      log('Model loaded successfully');
    } catch (e) {
      log("Failed to load model: $e");
    }
  }

  // Fungsi utama untuk memproses frame dari kamera
  Future<List<KeyPoint>?> processCameraImage(CameraImage cameraImage) async {
    // Konversi gambar dari format YUV (kamera) ke format RGB
    final image = _convertCameraImage(cameraImage);
    if (image == null) return null;

    // Ubah ukuran gambar sesuai dengan input model
    final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // Konversi gambar menjadi List<double> dan normalisasi piksel ke [0, 1]
    final preprocessedImage = resizedImage.getBytes(order: img.ChannelOrder.rgb).map((e) => e / 255.0).toList();

    // Bentuk ulang list menjadi format input model [1, 257, 257, 3]
    final input = [
      [
        [
          [0.0, 0.0, 0.0]
        ]
      ]
    ];
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixelIndex = (y * inputSize + x) * 3;
        input[0][y][x][0] = preprocessedImage[pixelIndex];     // R
        input[0][y][x][1] = preprocessedImage[pixelIndex + 1]; // G
        input[0][y][x][2] = preprocessedImage[pixelIndex + 2]; // B
      }
    }

    // Siapkan tensor output
    // Shape: [1, 1, 17, 3] -> 1 gambar, 1 orang, 17 keypoint, 3 data (y, x, score)
    final output = List.filled(1 * 1 * 17 * 3, 0.0).reshape([1, 1, 17, 3]);

    // Jalankan inferensi
    _interpreter.run(input, output);

    // Proses output menjadi List<KeyPoint>
    final keypoints = <KeyPoint>[];
    for (int i = 0; i < 17; i++) {
      final y = output[0][0][i][0];
      final x = output[0][0][i][1];
      final score = output[0][0][i][2];
      keypoints.add(KeyPoint(x, y, score));
    }
    
    return keypoints;
  }

  // Helper untuk konversi format gambar
  img.Image? _convertCameraImage(CameraImage image) {
    // Posenet biasanya bekerja dengan baik pada format RGB
    // Fungsi ini mengkonversi dari format YUV420 yang umum pada Android
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra, // Format BGRA umum untuk plane pertama
    );
  }

  void close() {
    _interpreter.close();
  }
}
