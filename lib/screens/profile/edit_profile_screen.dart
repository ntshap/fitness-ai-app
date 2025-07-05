import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/services/image_service.dart';
import 'package:fitness_ai_app/widgets/auth/auth_button.dart';
import 'package:fitness_ai_app/widgets/auth/auth_text_field.dart';
import 'package:fitness_ai_app/widgets/onboarding/data_slider.dart';
import 'package:fitness_ai_app/widgets/onboarding/selection_card.dart';
import 'package:fitness_ai_app/widgets/profile/profile_picture_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SimpleAuthService _authService = SimpleAuthService();
  final ImageService _imageService = ImageService();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;
  double _age = 25;
  double _height = 170;
  double _weight = 65;
  String? _selectedGoal;
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentProfilePicture;

  final List<String> _goals = [
    'Turunkan Berat Badan',
    'Bentuk Otot',
    'Jaga Kebugaran',
    'Tingkatkan Kekuatan',
    'Latihan Kardio',
    'Fleksibilitas'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _selectedGender = user['gender'];
      _age = (user['age'] ?? 25).toDouble();
      _height = user['height'] ?? 170.0;
      _weight = user['weight'] ?? 65.0;
      _selectedGoal = user['fitness_goal'];
      _currentProfilePicture = user['profile_picture'];
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showMessage('Nama tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update profile picture if a new one was selected
      if (_selectedImage != null) {
        final pictureResult = await _authService.updateProfilePicture(_selectedImage!);
        if (!pictureResult['success']) {
          _showMessage(pictureResult['message']);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Update name if changed
      if (_nameController.text != _authService.currentUser?['name']) {
        await _authService.updateProfile(name: _nameController.text);
      }

      // Update profile data
      final profileData = {
        'gender': _selectedGender,
        'age': _age.round(),
        'height': _height,
        'weight': _weight,
        'fitness_goal': _selectedGoal,
      };

      final result = await _authService.updateUserProfile(profileData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        _showMessage('Profil berhasil diperbarui');
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate profile was updated
        }
      } else {
        _showMessage(result['message']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Terjadi kesalahan: $e');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _selectProfilePicture() async {
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
        File? selectedImage;
        if (result == 'gallery') {
          selectedImage = await _imageService.pickImageFromGallery();
        } else if (result == 'camera') {
          selectedImage = await _imageService.pickImageFromCamera();
        }

        if (selectedImage != null) {
          setState(() {
            _selectedImage = selectedImage;
          });
        }
      }
    } catch (e) {
      _showMessage('Error memilih gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil', style: AppTextStyles.headline1),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  ProfilePictureWidget(
                    profilePicturePath: _selectedImage?.path ?? _currentProfilePicture,
                    radius: 60,
                    showEditIcon: true,
                    onTap: _selectProfilePicture,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk mengubah foto profil',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            AuthTextField(
              controller: _nameController,
              hintText: 'Nama Lengkap',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            
            // Gender selection
            Text(
              'Jenis Kelamin',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SelectionCard(
                    title: 'Pria',
                    icon: Icons.male,
                    isSelected: _selectedGender == 'Pria',
                    onTap: () => setState(() => _selectedGender = 'Pria'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SelectionCard(
                    title: 'Wanita',
                    icon: Icons.female,
                    isSelected: _selectedGender == 'Wanita',
                    onTap: () => setState(() => _selectedGender = 'Wanita'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Physical data
            Text(
              'Data Fisik',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            DataSlider(
              label: 'Usia',
              value: _age,
              min: 15,
              max: 80,
              divisions: 65,
              unit: 'tahun',
              onChanged: (value) => setState(() => _age = value),
            ),
            const SizedBox(height: 16),
            DataSlider(
              label: 'Tinggi Badan',
              value: _height,
              min: 140,
              max: 220,
              divisions: 80,
              unit: 'cm',
              onChanged: (value) => setState(() => _height = value),
            ),
            const SizedBox(height: 16),
            DataSlider(
              label: 'Berat Badan',
              value: _weight,
              min: 40,
              max: 150,
              divisions: 110,
              unit: 'kg',
              onChanged: (value) => setState(() => _weight = value),
            ),
            const SizedBox(height: 32),
            
            // Fitness goal
            Text(
              'Tujuan Fitness',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _goals.map((goal) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 36,
                  child: SelectionCard(
                    title: goal,
                    isSelected: _selectedGoal == goal,
                    onTap: () => setState(() => _selectedGoal = goal),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            
            // Save button
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : AuthButton(
                    text: 'Simpan Perubahan',
                    onPressed: _saveProfile,
                  ),
          ],
        ),
      ),
    );
  }
}
