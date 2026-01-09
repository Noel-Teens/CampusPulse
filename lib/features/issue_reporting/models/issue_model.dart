import 'package:cloud_firestore/cloud_firestore.dart';

enum IssueStatus { open, inProgress, resolved, closed }

enum IssueCategory { infrastructure, sanitation, academic, other }

class IssueModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final IssueCategory category;
  final IssueStatus status;
  final String? imageUrl;
  final DateTime createdAt;
  final int upvotes;

  IssueModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    this.upvotes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
    };
  }

  factory IssueModel.fromMap(Map<String, dynamic> map) {
    return IssueModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: IssueCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => IssueCategory.other,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => IssueStatus.open,
      ),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      upvotes: map['upvotes'] ?? 0,
    );
  }
}
