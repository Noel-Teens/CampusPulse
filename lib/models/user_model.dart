import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  faculty,
  admin,
  guest, // For initial state or visitors
}

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final UserRole role;
  final bool isVerified;
  final String? campusId;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
    this.isVerified = false,
    this.campusId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name, // Store enum as string
      'isVerified': isVerified,
      'campusId': campusId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.guest,
      ),
      isVerified: map['isVerified'] ?? false,
      campusId: map['campusId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
