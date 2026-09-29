import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';

class PostTypeSelector extends StatelessWidget {
  final PostType selectedType;
  final ValueChanged<PostType> onChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  IconData iconForType(PostType type) {
    switch (type) {
      case PostType.knowledge:
        return Icons.menu_book_outlined;
      case PostType.project:
        return Icons.code_rounded;
      case PostType.career:
        return Icons.work_outline_rounded;
      case PostType.experience:
        return Icons.auto_stories_outlined;
      case PostType.question:
        return Icons.help_outline_rounded;
      case PostType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Post type',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: PostType.values.map(
                (type) {
              final isSelected =
                  selectedType == type;

              return GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 9.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(
                      alpha: 0.09,
                    )
                        : AppColors.surface,
                    borderRadius:
                    BorderRadius.circular(13.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconForType(type),
                        size: 17.sp,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 5.w),
                        Icon(
                          Icons.check_rounded,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}