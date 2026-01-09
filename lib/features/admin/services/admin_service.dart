import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getUserCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getIssueCount() {
    // Assuming 'issues' collection handles all reported problems
    return _firestore
        .collection('issues')
        .where('status', isNotEqualTo: 'resolved')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
