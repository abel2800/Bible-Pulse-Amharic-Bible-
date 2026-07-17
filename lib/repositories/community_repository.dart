import '../models/community.dart';

abstract interface class CommunityRepository {
  Stream<List<CommunityPost>> watchFeed(String viewerId);
  Future<void> createPost(CommunityPost post);
  Future<void> deletePost(String userId, String postId);
  Future<void> report(CommunityReport report);
  Future<void> blockUser(String userId, String blockedUserId);
  Future<Set<String>> blockedUsers(String userId);
}
