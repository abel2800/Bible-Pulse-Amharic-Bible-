import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/community.dart';
import '../repositories/community_repository.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider(this._repository);

  final CommunityRepository _repository;
  final _uuid = const Uuid();
  StreamSubscription<List<CommunityPost>>? _subscription;
  List<CommunityPost> _posts = const [];
  String? _error;
  bool _loading = false;

  List<CommunityPost> get posts => _posts;
  String? get error => _error;
  bool get loading => _loading;

  void watch(String userId) {
    _subscription?.cancel();
    _loading = true;
    notifyListeners();
    _subscription = _repository.watchFeed(userId).listen(
      (posts) {
        _posts = posts;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = 'Unable to load the community.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> create(String userId, String body) async {
    final text = body.trim();
    if (text.isEmpty || text.length > 2000) {
      throw ArgumentError('Posts must contain 1–2000 characters.');
    }
    final now = DateTime.now().toUtc();
    await _repository.createPost(
      CommunityPost(
        id: _uuid.v4(),
        authorId: userId,
        body: text,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> report(String userId, String postId, String reason) {
    return _repository.report(
      CommunityReport(
        id: _uuid.v4(),
        postId: postId,
        reporterId: userId,
        reason: reason,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> block(String userId, String authorId) async {
    await _repository.blockUser(userId, authorId);
    _posts = _posts.where((post) => post.authorId != authorId).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
