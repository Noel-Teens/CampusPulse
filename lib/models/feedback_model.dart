import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String content;
  final String studentId;
  final String? studentName;
  final bool isAnonymous;
  final String facultyId;
  final String facultyName;
  final bool isReported;
  final String? reportReason;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.content,
    required this.studentId,
    this.studentName,
    required this.isAnonymous,
    required this.facultyId,
    required this.facultyName,
    this.isReported = false,
    this.reportReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'studentId': studentId,
      'studentName': isAnonymous ? null : studentName,
      'isAnonymous': isAnonymous,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'isReported': isReported,
      'reportReason': reportReason,
      'createdAt': createdAt,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'],
      isAnonymous: map['isAnonymous'] ?? true,
      facultyId: map['facultyId'] ?? '',
      facultyName: map['facultyName'] ?? '',
      isReported: map['isReported'] ?? false,
      reportReason: map['reportReason'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
