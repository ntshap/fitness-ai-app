import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/auth/landing_screen.dart';
import 'package:fitness_ai_app/screens/profile/edit_profile_screen.dart';
import 'package:fitness_ai_app/screens/profile/settings_screen.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';
import 'package:fitness_ai_app/widgets/profile/profile_menu_item.dart';
import 'package:fitness_ai_app/widgets/profile/stats_widget.dart';
import 'package:fitness_ai_app/widgets/profile/profile_picture_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SimpleAuthService _authService = SimpleAuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_authService.isLoggedIn) {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        setState(() {
          _userProfile = currentUser;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: AppTextStyles.headline1),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ProfilePictureWidget(
                      profilePicturePath: _userProfile?['profile_picture'],
                      radius: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userProfile?['name'] ?? 'Pengguna',
                      style: AppTextStyles.headline1.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile?['email'] ?? '',
                      style: AppTextStyles.bodyRegular,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatsWidget(
                          value: _userProfile?['height'] != null
                              ? '${(_userProfile!['height'] is double ? _userProfile!['height'] : double.tryParse(_userProfile!['height'].toString()) ?? 0.0).toStringAsFixed(0)}cm'
                              : '-',
                          label: 'Tinggi',
                        ),
                        StatsWidget(
                          value: _userProfile?['weight'] != null
                              ? '${(_userProfile!['weight'] is double ? _userProfile!['weight'] : double.tryParse(_userProfile!['weight'].toString()) ?? 0.0).toStringAsFixed(0)}kg'
                              : '-',
                          label: 'Berat',
                        ),
                        StatsWidget(
                          value: _userProfile?['age'] != null
                              ? '${(_userProfile!['age'] is int ? _userProfile!['age'] : int.tryParse(_userProfile!['age'].toString()) ?? 0)}thn'
                              : '-',
                          label: 'Usia',
                        ),
                      ],
                    ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.card),
              const SizedBox(height: 16),
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Ubah Profil',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                  // Reload profile if it was updated
                  if (result == true) {
                    _loadUserProfile();
                  }
                },
              ),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.card),
              const SizedBox(height: 16),
              ProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                textColor: Colors.redAccent,
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}