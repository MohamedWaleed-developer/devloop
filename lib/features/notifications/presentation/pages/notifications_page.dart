import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../posts/presentation/pages/post_details_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      getIt<NotificationCubit>()
        ..listenToNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20.w,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: TextButton(
                  onPressed: () {
                    context
                        .read<NotificationCubit>()
                        .markAllAsRead();
                  },
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == NotificationStatus.failure &&
              state.notifications.isEmpty) {
            return _NotificationError(
              message: state.errorMessage ??
                  'Failed to load notifications',
            );
          }

          if (state.notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16.w,
              8.h,
              16.w,
              28.h,
            ),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: 9.h),
            itemBuilder: (context, index) {
              return _NotificationTile(
                notification: state.notifications[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({
    required this.notification,
  });

  IconData get icon {
    switch (notification.type) {
      case 'follow':
        return Icons.person_add_alt_1_rounded;
      case 'like':
      case 'reaction':
      case 'post_reaction':
      case 'comment_reaction':
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.chat_bubble_rounded;
      case 'reply':
        return Icons.reply_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get iconColor {
    switch (notification.type) {
      case 'follow':
        return AppColors.primary;
      case 'like':
      case 'reaction':
      case 'post_reaction':
      case 'comment_reaction':
        return AppColors.error;
      case 'comment':
      case 'reply':
        return AppColors.violet;
      default:
        return AppColors.primary;
    }
  }

  bool get opensPost {
    return notification.postId != null &&
        notification.postId!.isNotEmpty &&
        notification.type != 'follow';
  }

  void openNotification(BuildContext context) {
    context
        .read<NotificationCubit>()
        .markAsRead(notification);

    if (opensPost) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostDetailsPage(
            postId: notification.postId!,
          ),
        ),
      );
      return;
    }

    if (notification.senderId.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          uid: notification.senderId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        notification.senderPhotoUrl != null &&
            notification.senderPhotoUrl!.isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () => openNotification(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withValues(
              alpha: 0.055,
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderLight
                  : AppColors.primary.withValues(
                alpha: 0.14,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor:
                    iconColor.withValues(alpha: 0.1),
                    backgroundImage: hasPhoto
                        ? NetworkImage(
                      notification.senderPhotoUrl!,
                    )
                        : null,
                    child: !hasPhoto
                        ? Icon(
                      icon,
                      color: iconColor,
                      size: 21.sp,
                    )
                        : null,
                  ),
                  Positioned(
                    right: -2.w,
                    bottom: -2.h,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderLight,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 11.sp,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.45,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        _formatDate(
                          notification.createdAt!,
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(
                    top: 6.h,
                    left: 8.w,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'You are all caught up',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your developer activity and connections will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  final String message;

  const _NotificationError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}