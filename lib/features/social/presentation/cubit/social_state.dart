import 'package:equatable/equatable.dart';

enum SocialStatus {
  initial,
  loading,
  loaded,
  following,
  unfollowing,
  failure,
}

class SocialState extends Equatable {
  final SocialStatus status;
  final bool isFollowing;
  final int followersCount;
  final int followingCount;
  final String? errorMessage;

  const SocialState({
    this.status = SocialStatus.initial,
    this.isFollowing = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.errorMessage,
  });

  SocialState copyWith({
    SocialStatus? status,
    bool? isFollowing,
    int? followersCount,
    int? followingCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SocialState(
      status: status ?? this.status,
      isFollowing: isFollowing ?? this.isFollowing,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isFollowing,
    followersCount,
    followingCount,
    errorMessage,
  ];
}