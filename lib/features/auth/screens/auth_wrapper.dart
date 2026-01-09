import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import 'welcome_screen.dart';
import 'email_verification_screen.dart';
import '../../dashboard/screens/home_dashboard.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../../models/user_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to Auth State
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;
    final userModel = authController.userModel;

    // 1. Unauthenticated -> Welcome
    if (user == null) {
      return const WelcomeScreen();
    }

    // 2. Privileged Roles (Admin/Faculty) - Bypass Verification Check
    if (userModel != null) {
      if (userModel.role == UserRole.admin) {
        return const AdminDashboard();
      }
      if (userModel.role == UserRole.faculty) {
        return const HomeDashboard();
      }
    }

    // 3. Authenticated but Unverified -> Email Verification
    // We check BOTH Firebase Auth's emailVerified AND our Firestore isVerified flag.
    // This allows manual verification by Admin to work.
    final firebaseVerified = user.emailVerified;
    final firestoreVerified = userModel?.isVerified ?? false;

    if (!user.isAnonymous && !firebaseVerified && !firestoreVerified) {
      return const EmailVerificationScreen();
    }

    // 4. Authenticated & Verified -> Dashboard
    return const HomeDashboard();
  }
}
