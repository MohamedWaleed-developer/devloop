import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../social/presentation/cubit/social_cubit.dart';
import '../../../social/presentation/cubit/social_state.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  ProfileModel _createInitialProfile() {
    final user = FirebaseAuth.instance.currentUser;

    return ProfileModel(
      uid: uid,
      name: user?.displayName ?? 'DevLoop User',
      email: user?.email ?? '',
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnProfile = currentUser?.uid == uid;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          getIt<ProfileCubit>()..getProfile(uid),
        ),
        BlocProvider(
          create: (_) =>
          getIt<SocialCubit>()..loadUserSocialData(uid),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              titleSpacing: 20.w,
              title: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius:
                      BorderRadius.circular(11.r),
                    ),
                    child: Image.asset(
                      'assets/branding/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                if (isOwnProfile)
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state.profile == null) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BlocProvider.value(
                                    value:
                                    context.read<ProfileCubit>(),
                                    child: EditProfilePage(
                                      profile: state.profile!,
                                    ),
                                  ),
                            ),
                          );

                          if (context.mounted) {
                            context
                                .read<ProfileCubit>()
                                .getProfile(uid);
                          }
                        },
                        icon: Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                            BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(width: 8.w),
              ],
            ),
            body: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.status == ProfileStatus.failure &&
                    state.errorMessage !=
                        'Profile not found') {
                  return _ProfileError(
                    message: state.errorMessage ??
                        'Failed to load profile',
                  );
                }

                if (state.profile == null) {
                  final profile = _createInitialProfile();

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                    if (!context.mounted) {
                      return;
                    }

                    context
                        .read<ProfileCubit>()
                        .createProfile(profile);
                  });

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final profile = state.profile!;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () {
                    return context
                        .read<ProfileCubit>()
                        .getProfile(uid);
                  },
                  child: SingleChildScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      12.h,
                      16.w,
                      32.h,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 700.w,
                        ),
                        child: Column(
                          children: [
                            ProfileHeader(
                              profile: profile,
                            ),
                            SizedBox(height: 18.h),
                            _SocialCard(
                              uid: uid,
                              isOwnProfile: isOwnProfile,
                            ),
                            if (profile.bio.isNotEmpty ||
                                profile.skills.isNotEmpty) ...[
                              SizedBox(height: 14.h),
                              _InfoCard(
                                child: ProfileInfo(
                                  profile: profile,
                                ),
                              ),
                            ],
                            if (isOwnProfile) ...[
                              SizedBox(height: 20.h),
                              _LogoutButton(
                                onPressed: () {
                                  _logout(context);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final String uid;
  final bool isOwnProfile;

  const _SocialCard({
    required this.uid,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        final isProcessing =
            state.status == SocialStatus.following ||
                state.status == SocialStatus.unfollowing;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      value: state.followersCount,
                      label: 'Followers',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38.h,
                    color: AppColors.borderLight,
                  ),
                  Expanded(
                    child: _Stat(
                      value: state.followingCount,
                      label: 'Following',
                    ),
                  ),
                ],
              ),
              if (!isOwnProfile) ...[
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: FilledButton(
                    onPressed:
                    isProcessing
                        ? null
                        : () {
                      context
                          .read<SocialCubit>()
                          .toggleFollow(uid);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                      state.isFollowing
                          ? AppColors.surface
                          : AppColors.primary,
                      foregroundColor:
                      state.isFollowing
                          ? AppColors.primary
                          : Colors.white,
                      side: state.isFollowing
                          ? const BorderSide(
                        color: AppColors.primary,
                      )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),
                    ),
                    child: isProcessing
                        ? SizedBox(
                      width: 19.w,
                      height: 19.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.isFollowing
                              ? Icons.check_rounded
                              : Icons.person_add_alt_1,
                          size: 18.sp,
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          state.isFollowing
                              ? 'Following'
                              : 'Follow',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: child,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(
            color: AppColors.error.withValues(alpha: 0.22),
          ),
          backgroundColor:
          AppColors.error.withValues(alpha: 0.035),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        icon: const Icon(
          Icons.logout_outlined,
          size: 19,
        ),
        label: const Text('Log out'),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}