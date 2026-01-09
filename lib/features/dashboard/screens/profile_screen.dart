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
  final _nameFocusNode = FocusNode();
  bool _isEditing = false;
  String _originalName = "";

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<AuthController>(
      context,
      listen: false,
    ).userModel;
    _originalName = userModel?.name ?? "";
    _nameController.text = _originalName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;
    final userModel = authController.userModel;

    // Sync controller if model changes from external source
    if (!_isEditing && _nameController.text != (userModel?.name ?? "")) {
      _nameController.text = userModel?.name ?? "";
      _originalName = _nameController.text;
    }

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
              focusNode: _nameFocusNode,
              readOnly: !_isEditing,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _originalName;
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        color: _isEditing ? Colors.green : AppColors.deepBlue,
                      ),
                      onPressed: () async {
                        if (_isEditing) {
                          if (_nameController.text.trim().isEmpty) return;
                          try {
                            await authController.updateProfileName(
                              _nameController.text.trim(),
                            );
                            _originalName = _nameController.text.trim();
                            setState(() => _isEditing = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile updated!"),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        } else {
                          setState(() => _isEditing = true);
                          // Delay focus to ensure widget is ready
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _nameFocusNode.requestFocus();
                          });
                        }
                      },
                    ),
                  ],
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (_isEditing) {
                  // Handle submission if needed
                }
              },
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
