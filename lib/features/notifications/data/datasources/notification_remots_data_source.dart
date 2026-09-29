import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotifications(
      String userId,
      );

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<void> markAllAsRead(String userId);

  Future<void> createNotification({
    required NotificationModel notification,
  });
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>>
  get notificationsCollection {
    return firestore.collection('notifications');
  }

  @override
  Stream<List<NotificationModel>> getNotifications(
      String userId,
      ) {
    return notificationsCollection
        .where(
      'userId',
      isEqualTo: userId,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .limit(50)
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(NotificationModel.fromFirestore)
            .toList();
      },
    );
  }

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return notificationsCollection
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await notificationsCollection
        .where(
      'userId',
      isEqualTo: userId,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(
        document.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  @override
  Future<void> createNotification({
    required NotificationModel notification,
  }) {
    return notificationsCollection.add({
      'userId': notification.userId,
      'senderId': notification.senderId,
      'senderName': notification.senderName,
      'senderPhotoUrl': notification.senderPhotoUrl,
      'type': notification.type,
      'message': notification.message,
      'postId': notification.postId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}