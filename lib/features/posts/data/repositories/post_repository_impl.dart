import 'dart:io';

import 'package:injectable/injectable.dart';

import '../datasources/post_image_upload_data_source.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/reaction_model.dart';

@LazySingleton()
class PostRepositoryImpl {
  final PostRemoteDataSource remoteDataSource;
  final PostImageUploadDataSource imageUploadDataSource;

  PostRepositoryImpl(
      this.remoteDataSource,
      this.imageUploadDataSource,
      );

  Future<void> createPost({
    required PostModel post,
    File? image,
  }) async {
    var updatedPost = post;

    if (image != null) {
      final uploadedImage =
      await imageUploadDataSource.uploadImage(
        image,
      );

      updatedPost = post.copyWith(
        imageUrl: uploadedImage.secureUrl,
        imagePublicId: uploadedImage.publicId,
      );
    }

    await remoteDataSource.createPost(
      updatedPost,
    );
  }

  Future<void> updatePost({
    required PostModel post,
    File? image,
    bool removeImage = false,
  }) async {
    var updatedPost = post;

    if (removeImage) {
      updatedPost = post.copyWith(
        clearImage: true,
      );
    } else if (image != null) {
      final uploadedImage =
      await imageUploadDataSource.uploadImage(
        image,
      );

      updatedPost = post.copyWith(
        imageUrl: uploadedImage.secureUrl,
        imagePublicId: uploadedImage.publicId,
      );
    }

    await remoteDataSource.updatePost(
      updatedPost,
    );
  }

  Future<void> deletePost(String postId) {
    return remoteDataSource.deletePost(
      postId,
    );
  }

  Stream<List<PostModel>> getPosts() {
    return remoteDataSource.getPosts();
  }

  Future<PostModel?> getPost(String postId) {
    return remoteDataSource.getPost(
      postId,
    );
  }

  Future<void> setPostReaction({
    required String postId,
    required String userId,
    required ReactionType reaction,
  }) {
    return remoteDataSource.setPostReaction(
      postId: postId,
      userId: userId,
      reaction: reaction,
    );
  }

  Future<ReactionType?> getPostReaction({
    required String postId,
    required String userId,
  }) {
    return remoteDataSource.getPostReaction(
      postId: postId,
      userId: userId,
    );
  }

  Future<List<PostReactionModel>> getPostReactions(
      String postId,
      ) {
    return remoteDataSource.getPostReactions(
      postId,
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(
      String userId,
      ) {
    return remoteDataSource.getUserProfile(
      userId,
    );
  }

  Stream<List<CommentModel>> getComments(
      String postId,
      ) {
    return remoteDataSource.getComments(
      postId,
    );
  }

  Future<CommentModel?> getComment({
    required String postId,
    required String commentId,
  }) {
    return remoteDataSource.getComment(
      postId: postId,
      commentId: commentId,
    );
  }

  Future<void> addComment(
      CommentModel comment,
      ) {
    return remoteDataSource.addComment(
      comment,
    );
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String authorId,
  }) {
    return remoteDataSource.deleteComment(
      postId: postId,
      commentId: commentId,
      authorId: authorId,
    );
  }

  Future<void> setCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
    required ReactionType reaction,
  }) {
    return remoteDataSource.setCommentReaction(
      postId: postId,
      commentId: commentId,
      userId: userId,
      reaction: reaction,
    );
  }

  Future<ReactionType?> getCommentReaction({
    required String postId,
    required String commentId,
    required String userId,
  }) {
    return remoteDataSource.getCommentReaction(
      postId: postId,
      commentId: commentId,
      userId: userId,
    );
  }
}