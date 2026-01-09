import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedback';

  // Create feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _firestore
        .collection(_collection)
        .doc(feedback.id)
        .set(feedback.toMap());
  }

  // Get feedback for specific faculty
  Stream<List<FeedbackModel>> getFeedbackForFaculty(String facultyId) {
    return _firestore
        .collection(_collection)
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get all feedback (Admin)
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Report feedback (Faculty)
  Future<void> reportFeedback(String feedbackId, String reason) async {
    await _firestore.collection(_collection).doc(feedbackId).update({
      'isReported': true,
      'reportReason': reason,
    });
  }

  // Delete feedback (Admin Only)
  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection(_collection).doc(feedbackId).delete();
  }

  // Helper to get faculty list (for student submission)
  Future<List<Map<String, dynamic>>> getFacultyList() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'faculty')
        .get();

    // Debugging: print snapshot size
    debugPrint("Faculty found: ${snapshot.docs.length}");

    return snapshot.docs
        .map(
          (doc) => {
            'uid': doc.id,
            'name': doc.data().containsKey('name')
                ? doc['name']
                : 'Faculty (${doc['email']})',
          },
        )
        .toList();
  }

  String generateId() {
    return _firestore.collection(_collection).doc().id;
  }
}
