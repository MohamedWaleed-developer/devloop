import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/repositories/notification_repository_impl.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'social_state.dart';

@injectable
class SocialCubit extends Cubit<SocialState> {
  final SocialRepositoryImpl repository;
  final NotificationRepositoryImpl notificationRepository;

  SocialCubit(
      this.repository,
      this.notificationRepository,
      ) : super(const SocialState());

  Future<void> loadUserSocialData(
      String userId,
      ) async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    emit(
      state.copyWith(
        status: SocialStatus.loading,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait([
        repository.isFollowing(
          followerId: currentUser.uid,
          followingId: userId,
        ),
        repository.getFollowersCount(userId),
        repository.getFollowingCount(userId),
      ]);

      emit(
        state.copyWith(
          status: SocialStatus.loaded,
          isFollowing: results[0] as bool,
          followersCount: results[1] as int,
          followingCount: results[2] as int,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SocialStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> toggleFollow(
      String userId,
      ) async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    if (currentUser.uid == userId) {
      emit(
        state.copyWith(
          status: SocialStatus.failure,
          errorMessage:
          'You cannot follow yourself',
        ),
      );
      return;
    }

    final wasFollowing = state.isFollowing;

    emit(
      state.copyWith(
        status: wasFollowing
            ? SocialStatus.unfollowing
            : SocialStatus.following,
        clearError: true,
      ),
    );

    try {
      if (wasFollowing) {
        await repository.unfollowUser(
          followerId: currentUser.uid,
          followingId: userId,
        );
      } else {
        await repository.followUser(
          followerId: currentUser.uid,
          followingId: userId,
        );

        await _createFollowNotification(
          currentUser: currentUser,
          targetUserId: userId,
        );
      }

      emit(
        state.copyWith(
          status: SocialStatus.loaded,
          isFollowing: !wasFollowing,
          followersCount: wasFollowing
              ? (state.followersCount > 0
              ? state.followersCount - 1
              : 0)
              : state.followersCount + 1,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SocialStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _createFollowNotification({
    required User currentUser,
    required String targetUserId,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: targetUserId,
      senderId: currentUser.uid,
      senderName:
      currentUser.displayName ??
          'DevLoop User',
      senderPhotoUrl:
      currentUser.photoURL,
      type: 'follow',
      message:
      '${currentUser.displayName ?? 'Someone'} started following you',
    );

    await notificationRepository.createNotification(
      notification: notification,
    );
  }
}