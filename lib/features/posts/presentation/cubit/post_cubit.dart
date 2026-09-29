import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_model.dart';
import '../../data/repositories/post_repository_impl.dart';
import 'post_state.dart';

@injectable
class PostCubit extends Cubit<PostState> {
  final PostRepositoryImpl repository;
  final ProfileRepositoryImpl profileRepository;

  StreamSubscription<List<PostModel>>?
  _postsSubscription;

  PostCubit(
      this.repository,
      this.profileRepository,
      ) : super(const PostState());

  void listenToPosts() {
    emit(
      state.copyWith(
        status: PostStatus.loading,
        clearError: true,
      ),
    );

    _postsSubscription?.cancel();

    _postsSubscription =
        repository.getPosts().listen(
              (posts) {
            emit(
              state.copyWith(
                status: PostStatus.loaded,
                posts: posts,
              ),
            );
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: PostStatus.failure,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  Future<void> createPost({
    required String content,
    required PostType type,
    File? image,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: 'You must be logged in',
        ),
      );
      return;
    }

    if (content.trim().isEmpty && image == null) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: 'Add text or an image',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PostStatus.creating,
        clearError: true,
      ),
    );

    try {
      final profile =
      await profileRepository.getProfile(
        user.uid,
      );

      final post = PostModel(
        id: '',
        authorId: user.uid,
        authorName:
        profile?.name ??
            user.displayName ??
            'DevLoop User',
        authorPhotoUrl:
        profile?.photoUrl,
        content: content.trim(),
        type: type,
      );

      await repository.createPost(
        post: post,
        image: image,
      );

      emit(
        state.copyWith(
          status: PostStatus.created,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updatePost({
    required PostModel post,
    File? image,
    bool removeImage = false,
  }) async {
    emit(
      state.copyWith(
        status: PostStatus.updating,
        clearError: true,
      ),
    );

    try {
      await repository.updatePost(
        post: post,
        image: image,
        removeImage: removeImage,
      );

      emit(
        state.copyWith(
          status: PostStatus.updated,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deletePost(String postId) async {
    emit(
      state.copyWith(
        status: PostStatus.deleting,
        clearError: true,
      ),
    );

    try {
      await repository.deletePost(postId);

      emit(
        state.copyWith(
          status: PostStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<PostModel?> getPost(String postId) {
    return repository.getPost(postId);
  }

  Future<void> setPostReaction({
    required String postId,
    required ReactionType reaction,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await repository.setPostReaction(
        postId: postId,
        userId: user.uid,
        reaction: reaction,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<ReactionType?> getPostReaction(
      String postId,
      ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return repository.getPostReaction(
      postId: postId,
      userId: user.uid,
    );
  }

  Future<List<PostReactionModel>> getPostReactions(
      String postId,
      ) {
    return repository.getPostReactions(
      postId,
    );
  }

  Future<String?> getPostAuthorPhoto(
      String authorId,
      ) async {
    final profile =
    await repository.getUserProfile(
      authorId,
    );

    return profile?['photoUrl']?.toString();
  }

  Stream<List<CommentModel>> commentsStream(
      String postId,
      ) {
    return repository.getComments(
      postId,
    );
  }

  Future<void> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null ||
        content.trim().isEmpty) {
      return;
    }

    final profile =
    await profileRepository.getProfile(
      user.uid,
    );

    final comment = CommentModel(
      id: '',
      postId: postId,
      authorId: user.uid,
      authorName:
      profile?.name ??
          user.displayName ??
          'DevLoop User',
      authorPhotoUrl:
      profile?.photoUrl ??
          user.photoURL,
      content: content.trim(),
      parentCommentId: parentCommentId,
    );

    try {
      await repository.addComment(
        comment,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await repository.deleteComment(
        postId: postId,
        commentId: commentId,
        authorId: user.uid,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> setCommentReaction({
    required String postId,
    required String commentId,
    required ReactionType reaction,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await repository.setCommentReaction(
        postId: postId,
        commentId: commentId,
        userId: user.uid,
        reaction: reaction,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PostStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<ReactionType?> getCommentReaction({
    required String postId,
    required String commentId,
  }) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return repository.getCommentReaction(
      postId: postId,
      commentId: commentId,
      userId: user.uid,
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}