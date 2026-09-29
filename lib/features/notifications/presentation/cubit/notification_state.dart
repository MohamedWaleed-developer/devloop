import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

enum NotificationStatus {
  initial,
  loading,
  loaded,
  failure,
}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount {
    return notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications:
      notifications ?? this.notifications,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    errorMessage,
  ];
}