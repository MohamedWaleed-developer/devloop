import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';
import '../cubit/post_cubit.dart';
import '../widgets/post_card.dart';

class PostDetailsPage extends StatelessWidget {
  final String postId;

  const PostDetailsPage({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostCubit>(),
      child: _PostDetailsView(
        postId: postId,
      ),
    );
  }
}

class _PostDetailsView extends StatefulWidget {
  final String postId;

  const _PostDetailsView({
    required this.postId,
  });

  @override
  State<_PostDetailsView> createState() =>
      _PostDetailsViewState();
}

class _PostDetailsViewState
    extends State<_PostDetailsView> {
  late Future<PostModel?> postFuture;

  @override
  void initState() {
    super.initState();

    postFuture =
        context.read<PostCubit>().getPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4.w,
        title: Text(
          'Post',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<PostModel?>(
        future: postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 26.w,
                height: 26.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final post = snapshot.data;

          if (post == null) {
            return _buildNotFoundState();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              8.h,
              16.w,
              30.h,
            ),
            child: PostCard(
              post: post,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Failed to load post',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                color: AppColors.primary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Post no longer exists',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'This post may have been deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}