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
      backgroundColor: AppColors.deepBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo or Icon
              const Icon(Icons.school_rounded, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              // Title
              const Text(
                'CampusPulse',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              const Text(
                'One Campus. One App.\nEvery Problem Solved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const Spacer(),
              // Get Started Button
              if (authController.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    authController.signInAnonymously();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealAccent,
                    foregroundColor: AppColors.darkSlate,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('Get Started'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Already have an account? Sign In",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
