import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../social/presentation/cubit/social_cubit.dart';
import '../../../social/presentation/cubit/social_state.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20.w,
        title: Text(
          'Discover Developers',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              8.h,
              16.w,
              12.h,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(17.r),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.035,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                onChanged:
                context.read<SearchCubit>().search,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search developers...',
                  prefixIcon: Container(
                    margin: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                      BorderRadius.circular(10.r),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.status == SearchStatus.initial) {
                  return _InitialState();
                }

                if (state.status == SearchStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.status == SearchStatus.failure) {
                  return _SearchError(
                    message:
                    state.errorMessage ?? 'Search failed',
                  );
                }

                if (state.results.isEmpty) {
                  return const _EmptySearch();
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    2.h,
                    16.w,
                    24.h,
                  ),
                  itemCount: state.results.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    return DeveloperSearchTile(
                      profile: state.results[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperSearchTile extends StatelessWidget {
  final ProfileModel profile;

  const DeveloperSearchTile({
    super.key,
    required this.profile,
  });

  void openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          uid: profile.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      getIt<SocialCubit>()
        ..loadUserSocialData(profile.uid),
      child: Builder(
        builder: (context) {
          return BlocBuilder<SocialCubit, SocialState>(
            builder: (context, state) {
              final currentUid =
                  FirebaseAuth.instance.currentUser?.uid;

              final isProcessing =
                  state.status ==
                      SocialStatus.following ||
                      state.status ==
                          SocialStatus.unfollowing;

              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(19.r),
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(19.r),
                  onTap: () => openProfile(context),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(19.r),
                      border: Border.all(
                        color: AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                            AppColors.buttonGradient,
                          ),
                          child: CircleAvatar(
                            radius: 26.r,
                            backgroundColor:
                            AppColors.surface,
                            backgroundImage:
                            profile.photoUrl != null &&
                                profile.photoUrl!
                                    .isNotEmpty
                                ? NetworkImage(
                              profile.photoUrl!,
                            )
                                : null,
                            child: profile.photoUrl ==
                                null ||
                                profile.photoUrl!.isEmpty
                                ? Icon(
                              Icons
                                  .person_outline_rounded,
                              color:
                              AppColors.primary,
                              size: 25.sp,
                            )
                                : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight:
                                  FontWeight.w700,
                                  color:
                                  AppColors.textPrimary,
                                ),
                              ),
                              if (profile.role.isNotEmpty) ...[
                                SizedBox(height: 3.h),
                                Text(
                                  profile.role,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                    AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if (profile.skills.isNotEmpty) ...[
                                SizedBox(height: 7.h),
                                Text(
                                  profile.skills
                                      .take(2)
                                      .join(' • '),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (profile.uid != currentUid)
                          SizedBox(width: 8.w),
                        if (profile.uid != currentUid)
                          SizedBox(
                            width: 88.w,
                            height: 37.h,
                            child: FilledButton(
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                context
                                    .read<
                                    SocialCubit>()
                                    .toggleFollow(
                                  profile.uid,
                                );
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
                                  color:
                                  AppColors.primary,
                                )
                                    : null,
                                padding: EdgeInsets.zero,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    11.r,
                                  ),
                                ),
                              ),
                              child: isProcessing
                                  ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                state.isFollowing
                                    ? 'Following'
                                    : 'Follow',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
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
                Icons.people_alt_outlined,
                color: Colors.white,
                size: 34,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Find your developer community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              'Search by name, role, or skill and connect with developers.',
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

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 58.sp,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 14.h),
            Text(
              'No developers found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Try another name, role, or skill.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String message;

  const _SearchError({
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