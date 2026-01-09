import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoticeService _noticeService = NoticeService();

  NoticePriority _selectedPriority = NoticePriority.normal;
  bool _isEvent = false;
  DateTime? _eventDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _eventDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitNotice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isEvent && _eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an event date")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.user;

    try {
      final newNotice = NoticeModel(
        id: _noticeService.generateId(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: user?.uid ?? 'unknown',
        authorName:
            authController.userModel?.role.name.toUpperCase() ?? 'ADMIN',
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        isEvent: _isEvent,
        eventDate: _eventDate,
      );

      await _noticeService.createNotice(newNotice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notice posted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Notice")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<NoticePriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: NoticePriority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedPriority = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Is this an event?"),
                subtitle: const Text("Scheduled date and time"),
                value: _isEvent,
                onChanged: (v) => setState(() => _isEvent = v),
              ),
              if (_isEvent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: OutlinedButton.icon(
                    onPressed: _pickEventDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _eventDate == null
                          ? "Pick Event Date & Time"
                          : "Date: ${DateFormat('MMM d, h:mm a').format(_eventDate!)}",
                    ),
                  ),
                ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  hintText: "Enter the announcement details...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (v) => v!.isEmpty ? "Content is required" : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitNotice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.noticeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post Announcement"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
