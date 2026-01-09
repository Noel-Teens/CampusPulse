import 'package:cloud_firestore/cloud_firestore.dart';

enum NoticePriority { low, normal, high, urgent }

class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final NoticePriority priority;
  final DateTime createdAt;
  final String? imageUrl;
  final bool isEvent;
  final DateTime? eventDate;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.priority = NoticePriority.normal,
    required this.createdAt,
    this.imageUrl,
    this.isEvent = false,
    this.eventDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'isEvent': isEvent,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Admin',
      priority: NoticePriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NoticePriority.normal,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      isEvent: map['isEvent'] ?? false,
      eventDate: map['eventDate'] != null
          ? (map['eventDate'] as Timestamp).toDate()
          : null,
    );
  }
}
