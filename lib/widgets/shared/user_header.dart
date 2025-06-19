import 'package:flutter/material.dart';
import 'package:fitness_ai_app/config/app_text_styles.dart';
import 'package:fitness_ai_app/screens/profile/profile_screen.dart';

class UserHeader extends StatelessWidget {
  final String userName;
  final String profileImagePath;

  const UserHeader({
    super.key,
    required this.userName,
    required this.profileImagePath,
  });

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
              backgroundImage: AssetImage(profileImagePath),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELLCOME BACK,', style: AppTextStyles.bodyRegular),
                Text(userName, style: AppTextStyles.headline1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
