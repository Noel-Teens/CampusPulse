import 'package:flutter/material.dart';
import '../../issue_reporting/models/issue_model.dart';
import '../../issue_reporting/services/issue_service.dart';

import 'package:intl/intl.dart';

class AdminIssueListScreen extends StatelessWidget {
  const AdminIssueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final issueService = IssueService();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Issues")),
      body: StreamBuilder<List<IssueModel>>(
        stream: issueService.getIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final issues = snapshot.data ?? [];

          if (issues.isEmpty) {
            return const Center(child: Text("No reported issues found."));
          }

          return ListView.builder(
            itemCount: issues.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    issue.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Category: ${issue.category.name.toUpperCase()}"),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'MMM d, yyyy - h:mm a',
                        ).format(issue.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  trailing: _buildStatusChip(context, issue, issueService),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    IssueModel issue,
    IssueService service,
  ) {
    Color color;
    switch (issue.status) {
      case IssueStatus.open:
        color = Colors.orange;
        break;
      case IssueStatus.inProgress:
        color = Colors.blue;
        break;
      case IssueStatus.resolved:
        color = Colors.green;
        break;
      case IssueStatus.closed:
        color = Colors.grey;
        break;
    }

    return ActionChip(
      label: Text(
        issue.status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      onPressed: () {
        _showStatusDialog(context, issue, service);
      },
    );
  }

  void _showStatusDialog(
    BuildContext context,
    IssueModel issue,
    IssueService service,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: IssueStatus.values.map((status) {
              return ListTile(
                title: Text(status.name.toUpperCase()),
                leading: Radio<IssueStatus>(
                  value: status,
                  groupValue: issue.status,
                  onChanged: (val) {
                    service.updateStatus(issue.id, val!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  service.updateStatus(issue.id, status);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
