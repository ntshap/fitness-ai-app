import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_colors.dart';
import 'package:fitness_ai_app/screens/home/home_screen.dart';
import 'package:fitness_ai_app/screens/training/training_screen.dart';
import 'package:fitness_ai_app/screens/history/history_screen.dart';
import 'package:fitness_ai_app/screens/profile/profile_screen.dart';
import 'package:fitness_ai_app/widgets/training/ai_options_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TrainingScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => showAiOptionsModal(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.smart_toy_outlined,
            size: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 12.0,
        color: AppColors.card,
        elevation: 8.0,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: <Widget>[
              // Left side - Beranda (takes 25% of space)
              Expanded(
                flex: 25,
                child: _buildNavItem(
                  icon: Icons.home_filled,
                  label: 'Beranda',
                  index: 0,
                ),
              ),
              // Second - Latihan (takes 25% of space)
              Expanded(
                flex: 25,
                child: _buildNavItem(
                  icon: Icons.fitness_center,
                  label: 'Latihan',
                  index: 1,
                ),
              ),
              // Center space for FAB (takes 25% of space to ensure no overlap)
              const Expanded(
                flex: 25,
                child: SizedBox(), // Empty space for the floating action button
              ),
              // Right side - Riwayat (takes 25% of space)
              Expanded(
                flex: 25,
                child: _buildNavItem(
                  icon: Icons.bar_chart,
                  label: 'Riwayat',
                  index: 2,
                ),
              ),
              // Far right - Profil (takes 25% of space)
              Expanded(
                flex: 25,
                child: _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  index: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : Colors.grey[400],
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}