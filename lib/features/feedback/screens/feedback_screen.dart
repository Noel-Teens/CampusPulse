import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../models/feedback_model.dart';
import '../services/feedback_service.dart';
import '../../../core/constants/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  String? _selectedFacultyId;
  String? _selectedFacultyName;
  bool _isAnonymous = true;
  List<Map<String, dynamic>> _facultyList = [];
  bool _isLoadingFaculty = true;

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  Future<void> _loadFaculty() async {
    try {
      final list = await _feedbackService.getFacultyList();
      setState(() {
        _facultyList = list;
        _isLoadingFaculty = false;
      });
    } catch (e) {
      debugPrint("Error loading faculty: $e");
      setState(() => _isLoadingFaculty = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userRole = authController.userModel?.role ?? UserRole.guest;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Campus Feedback",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.softWhite,
        foregroundColor: AppColors.darkSlate,
        elevation: 0,
      ),
      body: _buildBody(userRole, authController),
    );
  }

  Widget _buildBody(UserRole role, AuthController auth) {
    switch (role) {
      case UserRole.student:
        return _buildStudentView(auth);
      case UserRole.faculty:
        return _buildFacultyView(auth);
      case UserRole.admin:
        return _buildAdminView();
      default:
        return const Center(child: Text("Access Denied"));
    }
  }

  // --- Student View: Submit Feedback ---
  Widget _buildStudentView(AuthController auth) {
    if (_isLoadingFaculty)
      return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Help Us Improve",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Share your thoughts about campus facilities or faculty experience.",
              style: TextStyle(color: AppColors.mutedGray),
            ),
            const SizedBox(height: 32),

            // Faculty Selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Faculty/Department",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              items: _facultyList.map((f) {
                return DropdownMenuItem(
                  value: f['uid'] as String,
                  child: Text(f['name'] as String),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFacultyId = val;
                  _selectedFacultyName = _facultyList.firstWhere(
                    (element) => element['uid'] == val,
                  )['name'];
                });
              },
              validator: (val) => val == null ? "Required" : null,
            ),
            const SizedBox(height: 20),

            // Content
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Your Feedback",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Please enter feedback" : null,
            ),
            const SizedBox(height: 20),

            // Anonymous Toggle
            SwitchListTile(
              title: const Text("Submit Anonymously"),
              subtitle: Text(
                _isAnonymous
                    ? "Your name will not be shared with the faculty."
                    : "Your name will be visible to the faculty.",
              ),
              value: _isAnonymous,
              onChanged: (val) => setState(() => _isAnonymous = val),
              activeColor: AppColors.tealAccent,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => _submitFeedback(auth),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppColors.deepBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Submit Feedback",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(AuthController auth) async {
    if (!_formKey.currentState!.validate()) return;

    final feedback = FeedbackModel(
      id: _feedbackService.generateId(),
      content: _contentController.text.trim(),
      studentId: auth.user!.uid,
      studentName:
          auth.userModel?.name ??
          'Guest Student', // Assuming name field exists or fallback
      isAnonymous: _isAnonymous,
      facultyId: _selectedFacultyId!,
      facultyName: _selectedFacultyName!,
      createdAt: DateTime.now(),
    );

    try {
      await _feedbackService.submitFeedback(feedback);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Feedback submitted successfully!")),
        );
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- Faculty View: View Feedback ---
  Widget _buildFacultyView(AuthController auth) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getFeedbackForFaculty(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("No feedback received yet."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final f = snapshot.data![index];
            return _buildFeedbackCard(f, isFaculty: true);
          },
        );
      },
    );
  }

  // --- Admin View: Manage All Feedback ---
  Widget _buildAdminView() {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getAllFeedback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(child: Text("No feedback found."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final f = snapshot.data![index];
            return _buildFeedbackCard(f, isAdmin: true);
          },
        );
      },
    );
  }

  Widget _buildFeedbackCard(
    FeedbackModel f, {
    bool isFaculty = false,
    bool isAdmin = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  f.isAnonymous
                      ? "Anonymous Student"
                      : (f.studentName ?? "Student"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedGray,
                  ),
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(f.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isAdmin)
              Text(
                "Target: ${f.facultyName}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
            const SizedBox(height: 8),
            Text(f.content, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            if (f.isReported)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Reported: ${f.reportReason}",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isFaculty && !f.isReported)
                  TextButton.icon(
                    onPressed: () => _showReportDialog(f),
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text("Report Spam"),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                if (isAdmin)
                  IconButton(
                    onPressed: () => _feedbackService.deleteFeedback(f.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(FeedbackModel f) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Feedback"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Reason (e.g. False accusation, Spam)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isNotEmpty) {
                await _feedbackService.reportFeedback(
                  f.id,
                  reasonController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Submit Report"),
          ),
        ],
      ),
    );
  }
}
