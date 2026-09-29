import 'package:injectable/injectable.dart';

import '../datasources/social_remote_data_source.dart';

@LazySingleton()
class SocialRepositoryImpl {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl(this.remoteDataSource);

  Future<void> followUser({
    required String followerId,
    required String followingId,
  }) {
    return remoteDataSource.followUser(
      followerId: followerId,
      followingId: followingId,
    );
  }

  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) {
    return remoteDataSource.unfollowUser(
      followerId: followerId,
      followingId: followingId,
    );
  }

  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) {
    return remoteDataSource.isFollowing(
      followerId: followerId,
      followingId: followingId,
    );
  }

  Future<int> getFollowersCount(String userId) {
    return remoteDataSource.getFollowersCount(userId);
  }

  Future<int> getFollowingCount(String userId) {
    return remoteDataSource.getFollowingCount(userId);
  }
}