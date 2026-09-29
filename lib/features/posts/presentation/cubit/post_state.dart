import 'package:equatable/equatable.dart';

import '../../data/models/post_model.dart';

enum PostStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  failure,
}

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> posts;
  final String? errorMessage;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    errorMessage,
  ];
}