import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';
import 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepositoryImpl repository;

  StreamSubscription<List<NotificationModel>>?
  _subscription;

  NotificationCubit(this.repository)
      : super(const NotificationState());

  void listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationStatus.loading,
        clearError: true,
      ),
    );

    _subscription?.cancel();

    _subscription = repository
        .getNotifications(user.uid)
        .listen(
          (notifications) {
        emit(
          state.copyWith(
            status: NotificationStatus.loaded,
            notifications: notifications,
            clearError: true,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: NotificationStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> markAsRead(
      NotificationModel notification,
      ) async {
    if (notification.isRead) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await repository.markAsRead(
        userId: user.uid,
        notificationId: notification.id,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await repository.markAllAsRead(user.uid);
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createNotification({
    required String userId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String type,
    required String message,
    String? postId,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: type,
        message: message,
        postId: postId,
      );

      await repository.createNotification(
        notification: notification,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}