import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePicturePath;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const ProfilePictureWidget({
    super.key,
    this.profilePicturePath,
    this.radius = 60,
    this.onTap,
    this.showEditIcon = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? AppColors.primary,
            backgroundImage: _getBackgroundImage(),
            child: _getBackgroundImage() == null
                ? Icon(
                    Icons.person,
                    size: radius,
                    color: iconColor ?? Colors.black,
                  )
                : null,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.3,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (profilePicturePath == null || profilePicturePath!.isEmpty) {
      return null;
    }

    try {
      final File imageFile = File(profilePicturePath!);
      if (imageFile.existsSync()) {
        return FileImage(imageFile);
      }
    } catch (e) {
      // If there's an error loading the image, return null to show default avatar
      return null;
    }

    return null;
  }
}

class ProfilePicturePreview extends StatelessWidget {
  final String? imagePath;
  final double size;
  final String? currentProfilePicture;

  const ProfilePicturePreview({
    super.key,
    this.imagePath,
    this.size = 120,
    this.currentProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // Show new selected image if available
    if (imagePath != null && imagePath!.isNotEmpty) {
      try {
        final File imageFile = File(imagePath!);
        if (imageFile.existsSync()) {
          return Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: size,
            height: size,
          );
        }
      } catch (e) {
        // Fall through to show current or default
      }
    }

    // Show current profile picture if available
    if (currentProfilePicture != null && currentProfilePicture!.isNotEmpty) {
      try {
        final File imageFile = File(currentProfilePicture!);
        if (imageFile.existsSync()) {
          return Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: size,
            height: size,
          );
        }
      } catch (e) {
        // Fall through to show default
      }
    }

    // Show default avatar
    return Container(
      color: AppColors.primary,
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.black,
      ),
    );
  }
}

class EditableProfilePicture extends StatefulWidget {
  final String? profilePicturePath;
  final double radius;
  final Function(String?)? onImageSelected;
  final bool enabled;

  const EditableProfilePicture({
    super.key,
    this.profilePicturePath,
    this.radius = 60,
    this.onImageSelected,
    this.enabled = true,
  });

  @override
  State<EditableProfilePicture> createState() => _EditableProfilePictureState();
}

class _EditableProfilePictureState extends State<EditableProfilePicture> {
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      profilePicturePath: _selectedImagePath ?? widget.profilePicturePath,
      radius: widget.radius,
      showEditIcon: widget.enabled,
      onTap: widget.enabled ? _selectImage : null,
    );
  }

  Future<void> _selectImage() async {
    if (!widget.enabled) return;

    try {
      final result = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pilih Sumber Gambar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        // This will be handled by the parent widget
        // The actual image picking logic will be in the edit profile screen
        if (widget.onImageSelected != null) {
          widget.onImageSelected!(result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void updateSelectedImage(String? imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
    });
  }
}
