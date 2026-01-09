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
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;
    final userRole = authController.currentRole;

    // 1. Unauthenticated -> Welcome
    if (user == null) {
      return const WelcomeScreen();
    }

    // 2. Privileged Roles (Admin/Faculty) - Bypass Verification
    if (userRole == UserRole.admin) {
      return const AdminDashboard();
    }
    if (userRole == UserRole.faculty) {
      return const HomeDashboard();
    }

    // 3. Authenticated but Unverified -> Email Verification
    // Use authController.userModel directly for the firestore check
    final userModel = authController.userModel;
    final firebaseVerified = user.emailVerified;
    final firestoreVerified = userModel?.isVerified ?? false;

    if (!user.isAnonymous && !firebaseVerified && !firestoreVerified) {
      return const EmailVerificationScreen();
    }

    // 4. Authenticated & Verified -> Student Dashboard
    return const HomeDashboard();
  }
}
