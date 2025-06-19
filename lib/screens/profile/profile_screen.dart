import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/auth/login_screen.dart';
import 'package:fitness_ai_app/widgets/profile/profile_menu_item.dart';
import 'package:fitness_ai_app/widgets/profile/stats_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: AppTextStyles.headline1),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/user_profile.png'),
              ),
              const SizedBox(height: 16),
              Text(
                'Carolina Reaper',
                style: AppTextStyles.headline1.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 4),
              Text(
                'carolina.reaper@email.com',
                style: AppTextStyles.bodyRegular,
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatsWidget(value: '175cm', label: 'Tinggi'),
                  StatsWidget(value: '68kg', label: 'Berat'),
                  StatsWidget(value: '28thn', label: 'Usia'),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.card),
              const SizedBox(height: 16),
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Ubah Profil',
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () {},
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
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}