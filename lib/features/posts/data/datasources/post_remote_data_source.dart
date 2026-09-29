import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/reaction_model.dart';

abstract class PostRemoteDataSource {
  Future<void> createPost(PostModel post);

  Future<void> updatePost(PostModel post);

  Future<void> deletePost(String postId);

  Future<PostModel?> getPost(String postId);

  Stream<List<PostModel>> getPosts();

  Future<void> setPostReaction({
    required String postId,
    required String userId,
    required ReactionType reaction,
  });

  Future<ReactionType?> getPostReaction({
    required String postId,
    required String userId,
  });

  Future<List<PostReactionModel>> getPostReactions(
      String postId,
      );

  Future<Map<String, dynamic>?> getUserProfile(
      String userId,
      );

  Stream<List<CommentModel>> getComments(String postId);

  Future<CommentModel?> getComment({
    required String postId,
    required String commentId,
  });

  Future<void> addComment(CommentModel comment);

  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String authorId,
  });

  Future<void> setCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
    required ReactionType reaction,
  });

  Future<ReactionType?> getCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
  });
}

@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl
    implements PostRemoteDataSource {
  final FirebaseFirestore firestore;

  PostRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get postsCollection {
    return firestore.collection('posts');
  }

  CollectionReference<Map<String, dynamic>> get usersCollection {
    return firestore.collection('users');
  }

  DocumentReference<Map<String, dynamic>> postDocument(
      String postId,
      ) {
    return postsCollection.doc(postId);
  }

  CollectionReference<Map<String, dynamic>> commentsCollection(
      String postId,
      ) {
    return postDocument(postId).collection('comments');
  }

  @override
  Future<void> createPost(PostModel post) async {
    await postsCollection.add(
      post.toFirestore(),
    );
  }

  @override
  Future<void> updatePost(PostModel post) async {
    await postDocument(post.id).update({
      'content': post.content,
      'imageUrl': post.imageUrl,
      'imagePublicId': post.imagePublicId,
      'type': post.type.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    final commentsSnapshot =
    await commentsCollection(postId).get();

    final batch = firestore.batch();

    for (final comment in commentsSnapshot.docs) {
      batch.delete(comment.reference);
    }

    batch.delete(
      postDocument(postId),
    );

    await batch.commit();
  }

  @override
  Future<PostModel?> getPost(String postId) async {
    final document =
    await postDocument(postId).get();

    if (!document.exists) {
      return null;
    }

    return PostModel.fromFirestore(document);
  }

  @override
  Stream<List<PostModel>> getPosts() {
    return postsCollection
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(PostModel.fromFirestore)
          .toList(),
    );
  }

  @override
  Future<void> setPostReaction({
    required String postId,
    required String userId,
    required ReactionType reaction,
  }) async {
    final postRef = postDocument(postId);
    final reactionRef =
    postRef.collection('reactions').doc(userId);

    final postSnapshot = await postRef.get();

    if (!postSnapshot.exists) {
      return;
    }

    final postData =
        postSnapshot.data() ?? {};

    final rawCounts =
        postData['reactionCounts']
        as Map<String, dynamic>? ??
            {};

    final reactionCounts = rawCounts.map(
          (key, value) => MapEntry(
        key,
        (value as num).toInt(),
      ),
    );

    final existingReactionSnapshot =
    await reactionRef.get();

    final existingReactionData =
    existingReactionSnapshot.data();

    final existingReactionValue =
    existingReactionData?['type'];

    if (existingReactionValue == reaction.value) {
      reactionCounts[reaction.value] =
          (reactionCounts[reaction.value] ?? 0) - 1;

      if (reactionCounts[reaction.value]! <= 0) {
        reactionCounts.remove(
          reaction.value,
        );
      }

      final totalReactions =
      (postData['reactionsCount'] ?? 0) as num;

      await firestore.runTransaction(
            (transaction) async {
          transaction.delete(
            reactionRef,
          );

          transaction.update(
            postRef,
            {
              'reactionCounts': reactionCounts,
              'reactionsCount':
              totalReactions.toInt() > 0
                  ? totalReactions.toInt() - 1
                  : 0,
              'likesCount':
              reaction == ReactionType.like
                  ? ((postData['likesCount'] ?? 0) as num)
                  .toInt() >
                  0
                  ? ((postData['likesCount'] ?? 0)
              as num)
                  .toInt() -
                  1
                  : 0
                  : postData['likesCount'] ?? 0,
              'updatedAt':
              FieldValue.serverTimestamp(),
            },
          );
        },
      );

      return;
    }

    if (existingReactionValue != null) {
      final oldReaction =
      existingReactionValue.toString();

      reactionCounts[oldReaction] =
          (reactionCounts[oldReaction] ?? 0) - 1;

      if (reactionCounts[oldReaction]! <= 0) {
        reactionCounts.remove(
          oldReaction,
        );
      }

      reactionCounts[reaction.value] =
          (reactionCounts[reaction.value] ?? 0) + 1;

      await firestore.runTransaction(
            (transaction) async {
          transaction.set(
            reactionRef,
            {
              'userId': userId,
              'type': reaction.value,
              'createdAt':
              FieldValue.serverTimestamp(),
            },
          );

          transaction.update(
            postRef,
            {
              'reactionCounts': reactionCounts,
              'updatedAt':
              FieldValue.serverTimestamp(),
              'likesCount':
              reaction == ReactionType.like &&
                  oldReaction !=
                      ReactionType.like.value
                  ? ((postData['likesCount'] ?? 0)
              as num)
                  .toInt() +
                  1
                  : reaction != ReactionType.like &&
                  oldReaction ==
                      ReactionType.like.value
                  ? ((postData['likesCount'] ?? 0)
              as num)
                  .toInt() >
                  0
                  ? ((postData['likesCount'] ?? 0)
              as num)
                  .toInt() -
                  1
                  : 0
                  : postData['likesCount'] ?? 0,
            },
          );
        },
      );

      return;
    }

    final totalReactions =
    (postData['reactionsCount'] ?? 0) as num;

    reactionCounts[reaction.value] =
        (reactionCounts[reaction.value] ?? 0) + 1;

    await firestore.runTransaction(
          (transaction) async {
        transaction.set(
          reactionRef,
          {
            'userId': userId,
            'type': reaction.value,
            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          postRef,
          {
            'reactionCounts': reactionCounts,
            'reactionsCount':
            totalReactions.toInt() + 1,
            'likesCount':
            reaction == ReactionType.like
                ? ((postData['likesCount'] ?? 0) as num)
                .toInt() +
                1
                : postData['likesCount'] ?? 0,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  @override
  Future<ReactionType?> getPostReaction({
    required String postId,
    required String userId,
  }) async {
    final document = await postDocument(postId)
        .collection('reactions')
        .doc(userId)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();
    final value = data?['type'];

    if (value == null) {
      return null;
    }

    return ReactionTypeExtension.fromValue(
      value.toString(),
    );
  }

  @override
  Future<List<PostReactionModel>> getPostReactions(
      String postId,
      ) async {
    final reactionsSnapshot =
    await postDocument(postId)
        .collection('reactions')
        .get();

    if (reactionsSnapshot.docs.isEmpty) {
      return [];
    }

    final reactions = <PostReactionModel>[];

    for (final reactionDocument
    in reactionsSnapshot.docs) {
      final reactionData =
      reactionDocument.data();

      final userId =
          reactionData['userId'] ??
              reactionDocument.id;

      final reactionValue =
      reactionData['type'];

      if (reactionValue == null) {
        continue;
      }

      final userDocument =
      await usersCollection.doc(userId).get();

      final userData =
          userDocument.data() ?? {};

      reactions.add(
        PostReactionModel(
          userId: userId.toString(),
          userName:
          userData['name']?.toString() ??
              'DevLoop User',
          userPhotoUrl:
          userData['photoUrl']?.toString(),
          reaction:
          ReactionTypeExtension.fromValue(
            reactionValue.toString(),
          ),
        ),
      );
    }

    return reactions;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(
      String userId,
      ) async {
    final document =
    await usersCollection.doc(userId).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  @override
  Stream<List<CommentModel>> getComments(
      String postId,
      ) {
    return commentsCollection(postId)
        .orderBy(
      'createdAt',
      descending: false,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (document) =>
            CommentModel.fromFirestore(
              document,
              postId,
            ),
      )
          .toList(),
    );
  }

  @override
  Future<CommentModel?> getComment({
    required String postId,
    required String commentId,
  }) async {
    final document =
    await commentsCollection(postId)
        .doc(commentId)
        .get();

    if (!document.exists) {
      return null;
    }

    return CommentModel.fromFirestore(
      document,
      postId,
    );
  }

  @override
  Future<void> addComment(
      CommentModel comment,
      ) async {
    final postRef =
    postDocument(comment.postId);

    final commentRef =
    commentsCollection(comment.postId).doc();

    await firestore.runTransaction(
          (transaction) async {
        transaction.set(
          commentRef,
          comment.toFirestore(),
        );

        final postSnapshot =
        await transaction.get(postRef);

        if (!postSnapshot.exists) {
          return;
        }

        final data =
            postSnapshot.data() ?? {};

        final commentsCount =
        (data['commentsCount'] ?? 0) as num;

        transaction.update(
          postRef,
          {
            'commentsCount':
            commentsCount.toInt() + 1,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String authorId,
  }) async {
    final commentRef =
    commentsCollection(postId)
        .doc(commentId);

    final postRef =
    postDocument(postId);

    await firestore.runTransaction(
          (transaction) async {
        final commentSnapshot =
        await transaction.get(commentRef);

        if (!commentSnapshot.exists) {
          return;
        }

        final commentData =
            commentSnapshot.data() ?? {};

        if (commentData['authorId'] != authorId) {
          throw Exception(
            'You can only delete your own comment',
          );
        }

        final postSnapshot =
        await transaction.get(postRef);

        transaction.delete(commentRef);

        if (!postSnapshot.exists) {
          return;
        }

        final postData =
            postSnapshot.data() ?? {};

        final commentsCount =
        (postData['commentsCount'] ?? 0) as num;

        transaction.update(
          postRef,
          {
            'commentsCount':
            commentsCount.toInt() > 0
                ? commentsCount.toInt() - 1
                : 0,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  @override
  Future<void> setCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
    required ReactionType reaction,
  }) async {
    final commentRef =
    commentsCollection(postId)
        .doc(commentId);

    final reactionRef =
    commentRef.collection('reactions').doc(userId);

    final commentSnapshot =
    await commentRef.get();

    if (!commentSnapshot.exists) {
      return;
    }

    final commentData =
        commentSnapshot.data() ?? {};

    final rawCounts =
        commentData['reactionCounts']
        as Map<String, dynamic>? ??
            {};

    final reactionCounts = rawCounts.map(
          (key, value) => MapEntry(
        key,
        (value as num).toInt(),
      ),
    );

    final existingReactionSnapshot =
    await reactionRef.get();

    final existingReactionData =
    existingReactionSnapshot.data();

    final existingReactionValue =
    existingReactionData?['type'];

    if (existingReactionValue == reaction.value) {
      reactionCounts[reaction.value] =
          (reactionCounts[reaction.value] ?? 0) - 1;

      if (reactionCounts[reaction.value]! <= 0) {
        reactionCounts.remove(
          reaction.value,
        );
      }

      final totalReactions =
      (commentData['reactionsCount'] ?? 0) as num;

      await firestore.runTransaction(
            (transaction) async {
          transaction.delete(
            reactionRef,
          );

          transaction.update(
            commentRef,
            {
              'reactionCounts': reactionCounts,
              'reactionsCount':
              totalReactions.toInt() > 0
                  ? totalReactions.toInt() - 1
                  : 0,
            },
          );
        },
      );

      return;
    }

    if (existingReactionValue != null) {
      final oldReaction =
      existingReactionValue.toString();

      reactionCounts[oldReaction] =
          (reactionCounts[oldReaction] ?? 0) - 1;

      if (reactionCounts[oldReaction]! <= 0) {
        reactionCounts.remove(
          oldReaction,
        );
      }
    }

    if (existingReactionValue == null) {
      final totalReactions =
      (commentData['reactionsCount'] ?? 0) as num;

      reactionCounts[reaction.value] =
          (reactionCounts[reaction.value] ?? 0) + 1;

      await firestore.runTransaction(
            (transaction) async {
          transaction.set(
            reactionRef,
            {
              'userId': userId,
              'type': reaction.value,
              'createdAt':
              FieldValue.serverTimestamp(),
            },
          );

          transaction.update(
            commentRef,
            {
              'reactionCounts': reactionCounts,
              'reactionsCount':
              totalReactions.toInt() + 1,
            },
          );
        },
      );

      return;
    }

    reactionCounts[reaction.value] =
        (reactionCounts[reaction.value] ?? 0) + 1;

    await firestore.runTransaction(
          (transaction) async {
        transaction.set(
          reactionRef,
          {
            'userId': userId,
            'type': reaction.value,
            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );

        transaction.update(
          commentRef,
          {
            'reactionCounts': reactionCounts,
          },
        );
      },
    );
  }

  @override
  Future<ReactionType?> getCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    final document =
    await commentsCollection(postId)
        .doc(commentId)
        .collection('reactions')
        .doc(userId)
        .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();
    final value = data?['type'];

    if (value == null) {
      return null;
    }

    return ReactionTypeExtension.fromValue(
      value.toString(),
    );
  }
}