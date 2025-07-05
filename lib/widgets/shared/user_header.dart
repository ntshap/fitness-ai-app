import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/profile/profile_screen.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({super.key});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  final SimpleAuthService _authService = SimpleAuthService();
  String _userName = 'Pengguna';
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user['name']?.toString().toUpperCase() ?? 'PENGGUNA';
        _profilePicture = user['profile_picture'];
      });
    }
  }

  ImageProvider? _getProfileImage() {
    if (_profilePicture == null || _profilePicture!.isEmpty) {
      return null;
    }

    try {
      final File imageFile = File(_profilePicture!);
      if (imageFile.existsSync()) {
        return FileImage(imageFile);
      }
    } catch (e) {
      // If there's an error loading the image, return null to show default avatar
      print('Error loading profile image: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              backgroundImage: _getProfileImage(),
              child: _getProfileImage() == null
                  ? const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.black,
                    )
                  : null,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELCOME BACK,', style: AppTextStyles.bodyRegular),
                Text(_userName, style: AppTextStyles.headline1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
