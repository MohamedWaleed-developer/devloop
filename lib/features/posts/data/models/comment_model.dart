import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? parentCommentId;
  final Map<String, int> reactionCounts;
  final int reactionsCount;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.parentCommentId,
    this.reactionCounts = const {},
    this.reactionsCount = 0,
    this.createdAt,
  });

  bool get isReply => parentCommentId != null;

  factory CommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      String postId,
      ) {
    final data = document.data() ?? {};

    final rawReactionCounts =
        data['reactionCounts'] as Map<String, dynamic>? ?? {};

    return CommentModel(
      id: document.id,
      postId: postId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      parentCommentId: data['parentCommentId'],
      reactionCounts: rawReactionCounts.map(
            (key, value) => MapEntry(
          key,
          (value as num).toInt(),
        ),
      ),
      reactionsCount: data['reactionsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'parentCommentId': parentCommentId,
      'reactionCounts': reactionCounts,
      'reactionsCount': reactionsCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}