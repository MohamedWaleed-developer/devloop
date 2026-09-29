import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_model.dart';

class ProfileInfo extends StatelessWidget {
  final ProfileModel profile;

  const ProfileInfo({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.bio.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'About',
          ),
          SizedBox(height: 10.h),
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (profile.skills.isNotEmpty)
            SizedBox(height: 24.h),
        ],
        if (profile.skills.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.code_rounded,
            title: 'Skills',
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: profile.skills
                .map(
                  (skill) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.07,
                  ),
                  borderRadius:
                  BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.1,
                    ),
                  ),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
        if (_hasLinks) ...[
          SizedBox(height: 24.h),
          _SectionTitle(
            icon: Icons.link_rounded,
            title: 'Links',
          ),
          SizedBox(height: 10.h),
          if (profile.githubUrl?.isNotEmpty == true)
            _ProfileLink(
              icon: Icons.code_rounded,
              label: 'GitHub',
              value: profile.githubUrl!,
            ),
          if (profile.linkedinUrl?.isNotEmpty == true)
            _ProfileLink(
              icon: Icons.work_outline_rounded,
              label: 'LinkedIn',
              value: profile.linkedinUrl!,
            ),
          if (profile.portfolioUrl?.isNotEmpty == true)
            _ProfileLink(
              icon: Icons.language_rounded,
              label: 'Portfolio',
              value: profile.portfolioUrl!,
            ),
        ],
      ],
    );
  }

  bool get _hasLinks {
    return profile.githubUrl?.isNotEmpty == true ||
        profile.linkedinUrl?.isNotEmpty == true ||
        profile.portfolioUrl?.isNotEmpty == true;
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 17.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 9.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileLink({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 11.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}