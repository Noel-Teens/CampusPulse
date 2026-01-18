import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/user_menu.dart';
import '../../campus_map/screens/campus_map_screen.dart';
import '../../notices/screens/notices_screen.dart';
import '../../ai_assistant/screens/ai_chat_screen.dart';
import '../../feedback/screens/feedback_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userRole = authController.currentRole;

    return Scaffold(
      backgroundColor: AppColors.softWhite,
      appBar: AppBar(
        title: const Text("CampusPulse"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkSlate,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const UserMenu(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${userRole.name.toUpperCase()}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedGray,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "What would you like do today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkSlate,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  DashboardTile(
                    title: "Campus Map",
                    icon: Icons.map_rounded,
                    color: AppColors.mapAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CampusMapScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardTile(
                    title: "Issues",
                    icon: Icons.info_outline_rounded,
                    color: AppColors.issueAccent,
                    onTap: () {
                      Navigator.of(context).pushNamed('/issues');
                    },
                  ),
                  DashboardTile(
                    title: "Notices & Events",
                    icon: Icons.campaign_rounded,
                    color: AppColors.noticeAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NoticesScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardTile(
                    title: "AI Assistant",
                    icon: Icons.chat_bubble_rounded,
                    color: AppColors.aiAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AIChatScreen()),
                      );
                    },
                  ),
                  DashboardTile(
                    title: "Feedback",
                    icon: Icons.thumbs_up_down_rounded,
                    color: AppColors.feedbackAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
