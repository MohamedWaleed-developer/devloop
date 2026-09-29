import 'package:injectable/injectable.dart';


import '../datasources/notification_remots_data_source.dart';
import '../models/notification_model.dart';

@LazySingleton()
class NotificationRepositoryImpl {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  Stream<List<NotificationModel>> getNotifications(
      String userId,
      ) {
    return remoteDataSource.getNotifications(userId);
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return remoteDataSource.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
  }

  Future<void> markAllAsRead(String userId) {
    return remoteDataSource.markAllAsRead(userId);
  }

  Future<void> createNotification({
    required NotificationModel notification,
  }) {
    return remoteDataSource.createNotification(
      notification: notification,
    );
  }
}