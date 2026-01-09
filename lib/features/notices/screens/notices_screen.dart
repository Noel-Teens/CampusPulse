import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'add_notice_screen.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userRole = authController.userModel?.role ?? UserRole.guest;
    final noticeService = NoticeService();

    return Scaffold(
      appBar: AppBar(title: const Text("Notices & Events")),
      body: StreamBuilder<List<NoticeModel>>(
        stream: noticeService.getNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final notices = snapshot.data ?? [];

          if (notices.isEmpty) {
            return const Center(child: Text("No notices posted yet."));
          }

          return ListView.builder(
            itemCount: notices.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final notice = notices[index];
              return _buildNoticeCard(context, notice);
            },
          );
        },
      ),
      floatingActionButton:
          (userRole == UserRole.admin || userRole == UserRole.faculty)
          ? FloatingActionButton(
              backgroundColor: AppColors.noticeAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNoticeScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildNoticeCard(BuildContext context, NoticeModel notice) {
    Color priorityColor;
    switch (notice.priority) {
      case NoticePriority.urgent:
        priorityColor = Colors.red;
        break;
      case NoticePriority.high:
        priorityColor = Colors.orange;
        break;
      case NoticePriority.normal:
        priorityColor = AppColors.noticeAccent;
        break;
      case NoticePriority.low:
        priorityColor = Colors.grey;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (notice.isEvent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tealAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "EVENT",
                          style: TextStyle(
                            color: AppColors.tealAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "By ${notice.authorName} • ${DateFormat('MMM d, yyyy').format(notice.createdAt)}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedGray,
                  ),
                ),
                if (notice.isEvent && notice.eventDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.noticeAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Scheduled: ${DateFormat('MMM d, h:mm a').format(notice.eventDate!)}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.noticeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  notice.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
