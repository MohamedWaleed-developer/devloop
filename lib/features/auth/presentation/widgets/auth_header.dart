import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82.w,
          height: 82.w,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.20,
                ),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Image.asset(
              'assets/branding/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 18.h),
        ShaderMask(
          shaderCallback: (bounds) {
            return AppColors.primaryGradient.createShader(bounds);
          },
          child: Text(
            'DevLoop',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 21.sp,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          title,
          style: AppTextStyles.heading1.copyWith(
            fontSize: 27.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}