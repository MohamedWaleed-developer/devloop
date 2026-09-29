import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final String? imageUrl;
  final String? imagePublicId;
  final PostType type;
  final int likesCount;
  final int commentsCount;
  final Map<String, int> reactionCounts;
  final int reactionsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.imageUrl,
    this.imagePublicId,
    required this.type,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.reactionCounts = const {},
    this.reactionsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final rawReactionCounts =
        data['reactionCounts'] as Map<String, dynamic>? ?? {};

    return PostModel(
      id: document.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      imagePublicId: data['imagePublicId'],
      type: PostTypeExtension.fromValue(
        data['type'] ?? 'knowledge',
      ),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      reactionCounts: rawReactionCounts.map(
            (key, value) => MapEntry(
          key,
          (value as num).toInt(),
        ),
      ),
      reactionsCount: data['reactionsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'type': type.value,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'reactionCounts': reactionCounts,
      'reactionsCount': reactionsCount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  PostModel copyWith({
    String? content,
    String? imageUrl,
    String? imagePublicId,
    PostType? type,
    int? likesCount,
    int? commentsCount,
    Map<String, int>? reactionCounts,
    int? reactionsCount,
    bool clearImage = false,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content ?? this.content,
      imageUrl: clearImage ? null : imageUrl ?? this.imageUrl,
      imagePublicId:
      clearImage ? null : imagePublicId ?? this.imagePublicId,
      type: type ?? this.type,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

enum PostType {
  knowledge,
  project,
  career,
  experience,
  question,
  achievement,
}

extension PostTypeExtension on PostType {
  String get value {
    switch (this) {
      case PostType.knowledge:
        return 'knowledge';
      case PostType.project:
        return 'project';
      case PostType.career:
        return 'career';
      case PostType.experience:
        return 'experience';
      case PostType.question:
        return 'question';
      case PostType.achievement:
        return 'achievement';
    }
  }

  String get label {
    switch (this) {
      case PostType.knowledge:
        return 'Knowledge';
      case PostType.project:
        return 'Project';
      case PostType.career:
        return 'Career';
      case PostType.experience:
        return 'Experience';
      case PostType.question:
        return 'Question';
      case PostType.achievement:
        return 'Achievement';
    }
  }

  static PostType fromValue(String value) {
    return PostType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => PostType.knowledge,
    );
  }
}