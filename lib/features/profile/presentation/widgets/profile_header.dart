import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  void openProfileImage(BuildContext context) {
    if (profile.photoUrl == null ||
        profile.photoUrl!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(18.w),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: Image.network(
                profile.photoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 280.w,
                    height: 280.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      BorderRadius.circular(22.r),
                    ),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        profile.photoUrl != null &&
            profile.photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20.w,
        24.h,
        20.w,
        20.h,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: hasPhoto
                ? () => openProfileImage(context)
                : null,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.buttonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 52.r,
                backgroundColor: AppColors.surface,
                backgroundImage: hasPhoto
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: !hasPhoto
                    ? Icon(
                  Icons.person_outline_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                )
                    : null,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (profile.role.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                profile.role,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          if (profile.email.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 14.sp,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}