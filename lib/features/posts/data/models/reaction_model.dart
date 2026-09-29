class PostReactionModel {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final ReactionType reaction;

  const PostReactionModel({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.reaction,
  });
}

enum ReactionType {
  like,
  support,
  haha,
  wow,
  angry,
}

extension ReactionTypeExtension on ReactionType {
  String get value {
    switch (this) {
      case ReactionType.like:
        return 'like';
      case ReactionType.support:
        return 'support';
      case ReactionType.haha:
        return 'haha';
      case ReactionType.wow:
        return 'wow';
      case ReactionType.angry:
        return 'angry';
    }
  }

  String get emoji {
    switch (this) {
      case ReactionType.like:
        return '❤️';
      case ReactionType.support:
        return '👍';
      case ReactionType.haha:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.angry:
        return '😡';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.support:
        return 'Support';
      case ReactionType.haha:
        return 'Haha';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.angry:
        return 'Angry';
    }
  }

  static ReactionType fromValue(String value) {
    return ReactionType.values.firstWhere(
          (reaction) => reaction.value == value,
      orElse: () => ReactionType.like,
    );
  }
}