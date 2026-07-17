import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community.dart';
import '../repositories/community_repository.dart';

class FirestoreCommunityRepository implements CommunityRepository {
  FirestoreCommunityRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<CommunityPost>> watchFeed(String viewerId) async* {
    final blocked = await blockedUsers(viewerId);
    yield* _firestore
        .collection('communityPosts')
        .where('status', isEqualTo: CommunityPostStatus.visible.name)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromJson(doc.id, doc.data()))
              .where((post) => !blocked.contains(post.authorId))
              .toList(growable: false),
        );
  }

  @override
  Future<void> createPost(CommunityPost post) async {
    final rateLimit = _firestore
        .collection('users')
        .doc(post.authorId)
        .collection('rateLimits')
        .doc('communityPost');
    final target = _firestore.collection('communityPosts').doc(post.id);
    await _firestore.runTransaction((transaction) async {
      final previous = await transaction.get(rateLimit);
      final last = previous.data()?['lastCreatedAt'] as Timestamp?;
      if (last != null &&
          DateTime.now().difference(last.toDate()) <
              const Duration(seconds: 30)) {
        throw StateError('Please wait before posting again.');
      }
      transaction.set(target, post.toJson());
      transaction
          .set(rateLimit, {'lastCreatedAt': FieldValue.serverTimestamp()});
    });
  }

  @override
  Future<void> deletePost(String userId, String postId) {
    return _firestore.collection('communityPosts').doc(postId).update({
      'status': CommunityPostStatus.removed.name,
      'body': '',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> report(CommunityReport report) {
    return _firestore.collection('communityReports').doc(report.id).set(
          report.toJson(),
        );
  }

  @override
  Future<void> blockUser(String userId, String blockedUserId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .doc(blockedUserId)
        .set({'createdAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<Set<String>> blockedUsers(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blocks')
        .get();
    return snapshot.docs.map((document) => document.id).toSet();
  }
}
