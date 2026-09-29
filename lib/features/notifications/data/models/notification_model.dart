import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String type;
  final String message;
  final String? postId;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.type,
    required this.message,
    this.postId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return NotificationModel(
      id: document.id,
      userId: data['userId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      type: data['type'] ?? 'general',
      message: data['message'] ?? '',
      postId: data['postId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}