import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void openCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostPage(),
      ),
    );
  }

  void openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in'),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PostCubit>()..listenToPosts(),
        ),
        BlocProvider(
          create: (_) => getIt<ProfileCubit>()..getProfile(user.uid),
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildCreatePostCard(context),
                Expanded(
                  child: _buildPosts(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 68.h,
      titleSpacing: 16.w,
      title: Row(
        children: [
          Container(
            width: 43.w,
            height: 43.w,
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(13.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.16,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Image.asset(
              'assets/branding/appicon.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DevLoop',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Connect. Learn. Build.',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: () => openNotifications(context),
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: 43.w,
                height: 43.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 22.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostCard(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final photoUrl = state.profile?.photoUrl;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            3.h,
            16.w,
            7.h,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 9.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: CircleAvatar(
                    radius: 19.r,
                    backgroundColor: AppColors.surface,
                    backgroundImage:
                    photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Icon(
                      Icons.person_outline_rounded,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    )
                        : null,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => openCreatePost(context),
                    child: Container(
                      height: 45.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "What's on your developer mind?",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _ComposerAction(
                  icon: Icons.image_outlined,
                  onTap: () => openCreatePost(context),
                ),
                SizedBox(width: 5.w),
                _ComposerAction(
                  icon: Icons.sell_outlined,
                  onTap: () => openCreatePost(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosts(
      BuildContext context,
      PostState state,
      ) {
    if (state.status == PostStatus.loading &&
        state.posts.isEmpty) {
      return Center(
        child: SizedBox(
          width: 25.w,
          height: 25.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.4,
          ),
        ),
      );
    }

    if (state.status == PostStatus.failure &&
        state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: 0.08,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.error,
                  size: 27.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                state.errorMessage ??
                    'Failed to load posts',
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

    if (state.posts.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future<void>.delayed(
            const Duration(milliseconds: 300),
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20.w,
            48.h,
            20.w,
            100.h,
          ),
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              margin: EdgeInsets.symmetric(
                horizontal: 120.w,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'No posts yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              'Be the first developer to share something.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future<void>.delayed(
          const Duration(milliseconds: 300),
        );
      },
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16.w,
          5.h,
          16.w,
          100.h,
        ),
        itemCount: state.posts.length,
        separatorBuilder: (_, __) {
          return SizedBox(height: 12.h);
        },
        itemBuilder: (context, index) {
          return PostCard(
            post: state.posts[index],
          );
        },
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ComposerAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(
        alpha: 0.08,
      ),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(
            icon,
            size: 19.sp,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}