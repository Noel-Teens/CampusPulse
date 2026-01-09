import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';
import 'package:uuid/uuid.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notices';

  Future<void> createNotice(NoticeModel notice) async {
    await _firestore.collection(_collection).doc(notice.id).set(notice.toMap());
  }

  String generateId() {
    return const Uuid().v4();
  }

  Stream<List<NoticeModel>> getNotices() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NoticeModel.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
