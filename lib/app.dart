import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/issue_reporting/screens/issue_list_screen.dart' as features;

class CampusPulseApp extends StatelessWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {'/issues': (context) => const features.IssueListScreen()},
      home: const AuthWrapper(),
    );
  }
}
