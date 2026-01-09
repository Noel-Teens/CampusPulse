import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    try {
      return UserModel(
        uid: map['uid'] as String? ?? '',
        email: map['email'] as String? ?? '',
        name: map['name'] as String?,
        role: UserRole.values.firstWhere(
          (e) => e.name == map['role'],
          orElse: () => UserRole.guest,
        ),
        isVerified: map['isVerified'] as bool? ?? false,
        campusId: map['campusId'] as String?,
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint("Error parsing UserModel: $e | Data: $map");
      return UserModel(
        uid: map['uid'] as String? ?? 'error',
        email: map['email'] as String? ?? 'error',
        role: UserRole.guest,
        createdAt: DateTime.now(),
      );
    }
  }
}
