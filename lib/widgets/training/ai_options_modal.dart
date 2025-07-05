import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/screens/training/training_screen.dart';
import 'package:fitness_ai_app/screens/upload/upload_video_screen.dart'; // Import halaman baru

void showAiOptionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (kode lainnya tetap sama)
            const Divider(color: AppColors.background, height: 24),
            _buildModalOption(
              context,
              icon: Icons.upload_file_outlined,
              title: 'Unggah Video',
              subtitle: 'Analisis video latihan yang sudah direkam.',
              onTap: () {
                Navigator.pop(context); // Tutup modal
                // Aktifkan navigasi ini
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadVideoScreen()));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Widget _buildModalOption(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 30),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}