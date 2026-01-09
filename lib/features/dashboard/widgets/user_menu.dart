import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../screens/profile_screen.dart';
import '../../../core/constants/app_colors.dart';

class UserMenu extends StatelessWidget {
  final Color? color;
  const UserMenu({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userModel = authController.userModel;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.account_circle_outlined,
        color: color ?? AppColors.darkSlate,
        size: 28,
      ),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          authController.signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userModel?.name ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                userModel?.email ?? "",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.settings_outlined, size: 20),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, size: 20, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}
