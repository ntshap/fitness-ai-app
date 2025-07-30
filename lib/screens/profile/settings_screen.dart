import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/widgets/profile/profile_menu_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Bahasa Indonesia';

  final List<String> _languages = [
    'Bahasa Indonesia',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: AppTextStyles.headline1,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            Text(
              'NOTIFIKASI',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Notifikasi Push',
              'Terima notifikasi untuk pengingat latihan',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Suara',
              'Aktifkan suara untuk notifikasi',
              _soundEnabled,
              (value) => setState(() => _soundEnabled = value),
            ),
            _buildSwitchTile(
              'Getaran',
              'Aktifkan getaran untuk notifikasi',
              _vibrationEnabled,
              (value) => setState(() => _vibrationEnabled = value),
            ),
            
            const SizedBox(height: 32),
            
            // Appearance Section
            Text(
              'TAMPILAN',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Mode Gelap',
              'Gunakan tema gelap untuk aplikasi',
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            
            const SizedBox(height: 16),
            
            // Language Selection
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: Text(
                  'Bahasa',
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _selectedLanguage,
                  style: AppTextStyles.bodyRegular.copyWith(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: AppColors.secondaryText, size: 16),
                onTap: _showLanguageDialog,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Data & Privacy Section
            Text(
              'DATA & PRIVASI',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ProfileMenuItem(
              icon: Icons.backup_outlined,
              title: 'Backup Data',
              subtitle: 'Cadangkan data latihan Anda',
              onTap: _showBackupDialog,
            ),
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.restore_outlined,
              title: 'Restore Data',
              subtitle: 'Pulihkan data dari backup',
              onTap: _showRestoreDialog,
            ),
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.delete_outline,
              title: 'Hapus Semua Data',
              subtitle: 'Hapus semua data latihan',
              textColor: Colors.redAccent,
              onTap: _showDeleteDataDialog,
            ),
            
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.shield_outlined,
              title: 'Kebijakan Privasi',
              subtitle: 'Lihat kebijakan privasi aplikasi',
              onTap: _showPrivacyPolicy,
            ),
            
            const SizedBox(height: 32),
            
            // About Section
            Text(
              'TENTANG',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'Versi Aplikasi',
              subtitle: '1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan & FAQ',
              onTap: _showHelpDialog,
            ),
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.rate_review_outlined,
              title: 'Beri Rating',
              onTap: _showRatingDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyRegular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyRegular.copyWith(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Pilih Bahasa', style: AppTextStyles.headline2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) => RadioListTile<String>(
            title: Text(language, style: AppTextStyles.bodyRegular),
            value: language,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() => _selectedLanguage = value!);
              Navigator.pop(context);
            },
            activeColor: AppColors.primary,
          )).toList(),
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Backup Data', style: AppTextStyles.headline2),
        content: Text(
          'Fitur backup akan segera tersedia. Data Anda akan dicadangkan ke cloud storage.',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Restore Data', style: AppTextStyles.headline2),
        content: Text(
          'Fitur restore akan segera tersedia. Anda dapat memulihkan data dari backup sebelumnya.',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Hapus Semua Data', style: AppTextStyles.headline2),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua data latihan? Tindakan ini tidak dapat dibatalkan.',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete all data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur hapus data akan segera tersedia'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Bantuan & FAQ', style: AppTextStyles.headline2),
        content: Text(
          'Untuk bantuan lebih lanjut, silakan hubungi tim support kami melalui email: support@fitnessai.com',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Beri Rating', style: AppTextStyles.headline2),
        content: Text(
          'Terima kasih telah menggunakan Fitness AI App! Rating Anda sangat berarti bagi kami.',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Nanti', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement rating functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terima kasih atas rating Anda!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text('Beri Rating', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Kebijakan Privasi', style: AppTextStyles.headline2),
        content: SingleChildScrollView(
          child: Text(
            'KEBIJAKAN PRIVASI FITNESS AI APP\n\n'
            '1. PENGUMPULAN DATA\n'
            'Kami mengumpulkan data yang Anda berikan secara langsung, seperti:\n'
            '• Informasi profil (nama, email, usia, tinggi, berat badan)\n'
            '• Data latihan dan aktivitas fisik\n'
            '• Video latihan untuk analisis AI\n\n'
            '2. PENGGUNAAN DATA\n'
            'Data Anda digunakan untuk:\n'
            '• Memberikan analisis latihan yang akurat\n'
            '• Melacak kemajuan fitness Anda\n'
            '• Meningkatkan layanan aplikasi\n\n'
            '3. PENYIMPANAN DATA\n'
            '• Data disimpan secara lokal di perangkat Anda\n'
            '• Video latihan dihapus otomatis setelah analisis\n'
            '• Kami tidak menyimpan data di server eksternal\n\n'
            '4. KEAMANAN\n'
            'Kami berkomitmen melindungi privasi Anda dengan:\n'
            '• Enkripsi data sensitif\n'
            '• Akses terbatas pada data personal\n'
            '• Tidak membagikan data dengan pihak ketiga\n\n'
            '5. HAK PENGGUNA\n'
            'Anda memiliki hak untuk:\n'
            '• Mengakses data personal Anda\n'
            '• Menghapus akun dan semua data\n'
            '• Meminta penjelasan tentang penggunaan data\n\n'
            'Untuk pertanyaan lebih lanjut, hubungi: privacy@fitnessai.com\n\n'
            'Terakhir diperbarui: 7 Juli 2025',
            style: AppTextStyles.bodyRegular.copyWith(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
