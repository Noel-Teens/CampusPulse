import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<AuthController>(
      context,
      listen: false,
    ).userModel;
    _nameController.text = userModel?.name ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;
    final userModel = authController.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppColors.darkSlate,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.tealAccent,
              child: Icon(Icons.person, size: 50, color: AppColors.darkSlate),
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: "Full Name",
                suffixIcon: IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () async {
                    if (_isEditing) {
                      try {
                        await authController.updateProfileName(
                          _nameController.text.trim(),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile updated!")),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    }
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email (Read Only)
            TextField(
              controller: TextEditingController(text: user?.email),
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Role (Read Only)
            TextField(
              controller: TextEditingController(
                text: userModel?.role.name.toUpperCase(),
              ),
              enabled: false,
              decoration: const InputDecoration(
                labelText: "User Role",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 32),

            // Password Reset Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (user?.email != null) {
                    try {
                      await authController.sendPasswordResetEmail(user!.email!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password reset email sent!"),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  }
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text("Reset Password"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.deepBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
