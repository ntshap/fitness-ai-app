import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

class PoseDetectorService {
  Interpreter? _interpreter;
  final _inputShape = [1, 192, 192, 3];
  // Output: [1, 1, 17, 3] -> 1 batch, 1 person, 17 keypoints, 3 values (y, x, score)
  final _outputShape = [1, 1, 17, 3];

  PoseDetectorService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('movenet.tflite');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<List<double?>?> processCameraImage(CameraImage cameraImage) async {
    if (_interpreter == null) return null;

    try {
      final image = _convertCameraImage(cameraImage);
      if (image == null) return null;

      final inputImage = img.copyResize(
        image,
        width: _inputShape[1],
        height: _inputShape[2],
      );

      final inputBytes = _imageToByteListFloat32(inputImage);
      final inputs = [inputBytes];
      
      // PERBAIKAN: Buat buffer output dengan bentuk yang benar
      final outputBuffer = List.generate(
        _outputShape[0],
        (_) => List.generate(
          _outputShape[1],
          (_) => List.generate(
            _outputShape[2],
            (_) => List.filled(_outputShape[3], 0.0),
          ),
        ),
      );

      final outputs = {0: outputBuffer};

      _interpreter!.runForMultipleInputs(inputs, outputs);
      
      final keypoints = (outputs[0] as List<List<List<List<double>>>>)[0][0];
      
      List<double?> result = [];
      for (var keypoint in keypoints) {
        result.add(keypoint[1]); // x
        result.add(keypoint[0]); // y
        result.add(keypoint[2]); // score
      }
      return result;

    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    return null;
  }

  img.Image _convertYUV420(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final convertedImage = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        
        final int yValue = yPlane[yIndex];
        final int uValue = uPlane[uvIndex];
        final int vValue = vPlane[uvIndex];

        final r = yValue + (1.402 * (vValue - 128)).toInt();
        final g = yValue - (0.344136 * (uValue - 128)) - (0.714136 * (vValue - 128)).toInt();
        final b = yValue + (1.772 * (uValue - 128)).toInt();

        convertedImage.setPixelRgba(x, y, 
          r.clamp(0, 255), 
          g.clamp(0, 255), 
          b.clamp(0, 255), 
          255
        );
      }
    }
    return convertedImage;
  }

   img.Image _convertBGRA8888(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  Uint8List _imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * _inputShape[1] * _inputShape[2] * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < _inputShape[1]; i++) {
      for (var j = 0; j < _inputShape[2]; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  void close() {
    _interpreter?.close();
  }
}
