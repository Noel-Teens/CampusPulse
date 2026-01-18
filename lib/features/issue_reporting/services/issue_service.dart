import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/issue_model.dart';

class IssueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'issues';
  final _uuid = const Uuid();

  // Create a new issue
  Future<void> createIssue(IssueModel issue) async {
    try {
      await _db.collection(_collection).doc(issue.id).set(issue.toMap());
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  // Generate a new ID
  String generateId() => _uuid.v4();

  // Stream of unresolved issues (Open or In Progress)
  Stream<List<IssueModel>> getUnresolvedIssues() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IssueModel.fromMap(doc.data()))
              .where(
                (issue) =>
                    issue.status == IssueStatus.open ||
                    issue.status == IssueStatus.inProgress,
              )
              .toList();
        });
  }

  // Stream of issues (all)
  Stream<List<IssueModel>> getIssues() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => IssueModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Update status (Admin function mostly)
  Future<void> updateStatus(String issueId, IssueStatus newStatus) async {
    await _db.collection(_collection).doc(issueId).update({
      'status': newStatus.name,
    });
  }
}
