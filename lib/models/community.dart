enum CommunityPostStatus { visible, underReview, removed }

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.status = CommunityPostStatus.visible,
    this.reportCount = 0,
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommunityPostStatus status;
  final int reportCount;

  factory CommunityPost.fromJson(String id, Map<String, dynamic> json) {
    return CommunityPost(
      id: id,
      authorId: json['authorId'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: CommunityPostStatus.values.byName(
        json['status'] as String? ?? 'visible',
      ),
      reportCount: json['reportCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorId': authorId,
        'body': body,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'status': status.name,
        'reportCount': reportCount,
      };
}

class CommunityReport {
  const CommunityReport({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String reporterId;
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'status': 'open',
      };
}
