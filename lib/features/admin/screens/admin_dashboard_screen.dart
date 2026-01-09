import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/admin_service.dart';
import 'manage_faculty_screen.dart';
import 'manage_students_screen.dart';
import 'admin_issue_list_screen.dart';
import '../../notices/screens/notices_screen.dart';
import '../../feedback/screens/feedback_screen.dart';
import '../../dashboard/widgets/user_menu.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      appBar: AppBar(
        title: const Text(
          "Admin Hub",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        backgroundColor: AppColors.darkSlate,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [const UserMenu(color: Colors.white)],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkSlate, AppColors.softWhite],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: adminService.getUserCount(),
                      builder: (context, snapshot) {
                        return _buildStatCard(
                          "Total Users",
                          snapshot.hasData ? snapshot.data.toString() : "...",
                          Icons.people_alt_rounded,
                          AppColors.deepBlue,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: adminService.getIssueCount(),
                      builder: (context, snapshot) {
                        return _buildStatCard(
                          "Active Issues",
                          snapshot.hasData ? snapshot.data.toString() : "...",
                          Icons.error_outline_rounded,
                          AppColors.issueAccent,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "Management Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkSlate,
                ),
              ),
              const SizedBox(height: 16),
              _buildActionGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkSlate,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          "Faculty Accounts",
          "View & Manage",
          Icons.person_add_alt_1_rounded,
          AppColors.tealAccent,
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ManageFacultyScreen()),
          ),
        ),
        _buildActionCard(
          context,
          "Campus Issues",
          "Resolve Reports",
          Icons.bug_report_rounded,
          AppColors.issueAccent,
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminIssueListScreen()),
          ),
        ),
        _buildActionCard(
          context,
          "Announcements",
          "Post Notices",
          Icons.campaign_rounded,
          AppColors.noticeAccent,
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NoticesScreen())),
        ),
        _buildActionCard(
          context,
          "Manage Feedback",
          "View & Respond", // Added subtitle based on common pattern
          Icons.feedback_outlined,
          AppColors.feedbackAccent,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackScreen()),
          ),
        ),
        _buildActionCard(
          context,
          "Student Portal",
          "Manage Access",
          Icons.school_rounded,
          Colors.blueGrey,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageStudentsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 24,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
            ),
          ],
        ),
      ),
    );
  }
}
