import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  // Maximum dimensions for profile pictures
  static const int maxWidth = 400;
  static const int maxHeight = 400;
  static const int jpegQuality = 85;

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: jpegQuality,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: jpegQuality,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Compress and resize image
  Future<File?> compressImage(File imageFile) async {
    try {
      // Read the image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      // Resize image while maintaining aspect ratio
      img.Image resizedImage;
      if (image.width > image.height) {
        resizedImage = img.copyResize(image, width: maxWidth);
      } else {
        resizedImage = img.copyResize(image, height: maxHeight);
      }

      // Ensure the image doesn't exceed maximum dimensions
      if (resizedImage.width > maxWidth || resizedImage.height > maxHeight) {
        resizedImage = img.copyResize(
          resizedImage,
          width: resizedImage.width > maxWidth ? maxWidth : null,
          height: resizedImage.height > maxHeight ? maxHeight : null,
        );
      }

      // Encode as JPEG with quality compression
      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: jpegQuality);

      // Save compressed image to temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(path.join(tempDir.path, fileName));
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Save profile picture to app directory
  Future<String?> saveProfilePicture(File imageFile, int userId) async {
    try {
      // Get application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profilePicturesDir = Directory(path.join(appDir.path, 'profile_pictures'));
      
      // Create directory if it doesn't exist
      if (!await profilePicturesDir.exists()) {
        await profilePicturesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(profilePicturesDir.path, fileName);

      // Compress image first
      final File? compressedImage = await compressImage(imageFile);
      if (compressedImage == null) return null;

      // Copy compressed image to profile pictures directory
      final File savedFile = await compressedImage.copy(filePath);
      
      // Clean up temporary compressed file
      if (await compressedImage.exists()) {
        await compressedImage.delete();
      }

      return savedFile.path;
    } catch (e) {
      print('Error saving profile picture: $e');
      return null;
    }
  }

  /// Delete profile picture file
  Future<bool> deleteProfilePicture(String? filePath) async {
    try {
      if (filePath == null || filePath.isEmpty) return true;
      
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true; // File doesn't exist, consider it deleted
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }

  /// Check if profile picture file exists
  Future<bool> profilePictureExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;
    
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }



  /// Clean up old profile pictures (keep only the latest one per user)
  Future<void> cleanupOldProfilePictures(int userId, String? currentProfilePicture) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profilePicturesDir = Directory(path.join(appDir.path, 'profile_pictures'));
      
      if (!await profilePicturesDir.exists()) return;

      final List<FileSystemEntity> files = profilePicturesDir.listSync();
      final String userPrefix = 'profile_${userId}_';

      for (final FileSystemEntity file in files) {
        if (file is File && path.basename(file.path).startsWith(userPrefix)) {
          // Don't delete the current profile picture
          if (currentProfilePicture != null && file.path == currentProfilePicture) {
            continue;
          }
          
          // Delete old profile pictures for this user
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up old profile pictures: $e');
    }
  }
}
