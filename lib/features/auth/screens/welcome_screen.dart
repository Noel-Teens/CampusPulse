import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkSlate,
                  AppColors.indigoBlue,
                  AppColors.deepBlue,
                ],
              ),
            ),
          ),
          // Subtle background patterns/shapes
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: AppColors.tealAccent.withOpacity(0.05),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Branding Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: AppColors.tealAccent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'CampusPulse',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontFamily: 'Outfit', // Assuming it might be used
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Elevating Campus Life',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Feature highlights (Slogan)
                  Column(
                    children: [
                      _buildFeatureRow(
                        Icons.bolt_rounded,
                        "Instant Issue Reporting",
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        Icons.campaign_rounded,
                        "Unified Announcements",
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(
                        Icons.map_rounded,
                        "Smart Campus Navigation",
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Action Section
                  if (authController.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.tealAccent,
                      ),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: () => authController.signInAnonymously(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tealAccent,
                        foregroundColor: AppColors.darkSlate,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.tealAccent.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Get Started Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Prominent Sign In link
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.indigoBlue,
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text(
                          "Already part of the pulse?",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        subtitle: const Text(
                          "Sign In to Your Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.tealAccent.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
