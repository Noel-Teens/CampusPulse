import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'add_faculty_screen.dart';
import 'admin_issue_list_screen.dart';
import '../../notices/screens/notices_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppColors.darkSlate,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard("Total Users", "42"), // Mock data
            const SizedBox(height: 16),
            _buildStatCard("Active Issues", "12"), // Mock data
            const SizedBox(height: 24),
            const Text(
              "User Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.person_add,
                  color: AppColors.deepBlue,
                ),
                title: const Text("Create Faculty Account"),
                subtitle: const Text("Add new faculty members to the system"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddFacultyScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.report_problem,
                  color: AppColors.issueAccent,
                ),
                title: const Text("Manage Issues"),
                subtitle: const Text("View and update reported issues"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminIssueListScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.campaign,
                  color: AppColors.noticeAccent,
                ),
                title: const Text("Manage Notices"),
                subtitle: const Text("Post and manage campus announcements"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NoticesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text("Manage Class Invites"),
                subtitle: const Text("View and edit student invite codes"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Todo
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: AppColors.softWhite,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: AppColors.mutedGray),
            ),
          ],
        ),
      ),
    );
  }
}
