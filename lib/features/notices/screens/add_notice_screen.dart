import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class AddNoticeScreen extends StatefulWidget {
  final NoticeModel? notice;
  const AddNoticeScreen({super.key, this.notice});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final NoticeService _noticeService = NoticeService();

  late NoticePriority _selectedPriority;
  late bool _isEvent;
  DateTime? _eventDate;
  bool _isLoading = false;

  bool get isEditing => widget.notice != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notice?.title ?? '');
    _contentController = TextEditingController(
      text: widget.notice?.content ?? '',
    );
    _selectedPriority = widget.notice?.priority ?? NoticePriority.normal;
    _isEvent = widget.notice?.isEvent ?? false;
    _eventDate = widget.notice?.eventDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickEventDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _eventDate != null
            ? TimeOfDay.fromDateTime(_eventDate!)
            : TimeOfDay.now(),
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
      final notice = NoticeModel(
        id: isEditing ? widget.notice!.id : _noticeService.generateId(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: isEditing
            ? widget.notice!.authorId
            : (user?.uid ?? 'unknown'),
        authorName: isEditing
            ? widget.notice!.authorName
            : (authController.userModel?.email ?? 'ADMIN'),
        priority: _selectedPriority,
        createdAt: isEditing ? widget.notice!.createdAt : DateTime.now(),
        isEvent: _isEvent,
        eventDate: _eventDate,
      );

      if (isEditing) {
        await _noticeService.updateNotice(notice);
      } else {
        await _noticeService.createNotice(notice);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? "Notice updated successfully!"
                  : "Notice posted successfully!",
            ),
          ),
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
      appBar: AppBar(title: Text(isEditing ? "Edit Notice" : "Post Notice")),
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
                    : Text(
                        isEditing ? "Update Announcement" : "Post Announcement",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
