import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/post_cubit.dart';
import '../pages/edit_post_page.dart';
import 'comments_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ReactionType? currentReaction;
  bool isCheckingReaction = true;
  bool isReacting = false;

  String? authorPhotoUrl;
  bool isLoadingAuthorPhoto = false;

  @override
  void initState() {
    super.initState();
    checkReaction();
    loadAuthorPhoto();
  }

  Future<void> checkReaction() async {
    final reaction = await context
        .read<PostCubit>()
        .getPostReaction(widget.post.id);

    if (!mounted) {
      return;
    }

    setState(() {
      currentReaction = reaction;
      isCheckingReaction = false;
    });
  }

  Future<void> loadAuthorPhoto() async {
    final existingPhoto = widget.post.authorPhotoUrl;

    if (existingPhoto != null && existingPhoto.isNotEmpty) {
      setState(() {
        authorPhotoUrl = existingPhoto;
      });
      return;
    }

    if (widget.post.authorId.isEmpty) {
      return;
    }

    setState(() {
      isLoadingAuthorPhoto = true;
    });

    try {
      final photoUrl = await context
          .read<PostCubit>()
          .getPostAuthorPhoto(widget.post.authorId);

      if (!mounted) {
        return;
      }

      setState(() {
        authorPhotoUrl = photoUrl;
        isLoadingAuthorPhoto = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingAuthorPhoto = false;
      });
    }
  }

  Future<void> openReactionPicker() async {
    if (isReacting || isCheckingReaction) {
      return;
    }

    final selectedReaction =
    await showModalBottomSheet<ReactionType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ReactionPicker(
          currentReaction: currentReaction,
        );
      },
    );

    if (selectedReaction == null || !mounted) {
      return;
    }

    final isRemoving = currentReaction == selectedReaction;

    setState(() {
      isReacting = true;
    });

    try {
      await context.read<PostCubit>().setPostReaction(
        postId: widget.post.id,
        reaction: selectedReaction,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        currentReaction =
        isRemoving ? null : selectedReaction;
      });
    } finally {
      if (mounted) {
        setState(() {
          isReacting = false;
        });
      }
    }
  }

  void openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PostCubit>(),
          child: CommentsSheet(
            post: widget.post,
          ),
        );
      },
    );
  }

  Future<void> openReactions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PostCubit>(),
          child: PostReactionsSheet(
            postId: widget.post.id,
          ),
        );
      },
    );
  }

  void openEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPostPage(
          post: widget.post,
        ),
      ),
    );
  }

  void openFullScreenImage() {
    if (widget.post.imageUrl == null ||
        widget.post.imageUrl!.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImagePage(
          imageUrl: widget.post.imageUrl!,
        ),
      ),
    );
  }

  Future<void> deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post?',
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<PostCubit>().deletePost(widget.post.id);
  }

  void handleMenuAction(String value) {
    if (value == 'edit') {
      openEditPage();
      return;
    }

    if (value == 'delete') {
      deletePost();
    }
  }

  List<ReactionType> get visibleReactions {
    final reactions = widget.post.reactionCounts.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => ReactionTypeExtension.fromValue(
        entry.key,
      ),
    )
        .toList();

    reactions.sort(
          (first, second) {
        final firstCount =
            widget.post.reactionCounts[first.value] ?? 0;

        final secondCount =
            widget.post.reactionCounts[second.value] ?? 0;

        return secondCount.compareTo(firstCount);
      },
    );

    return reactions.take(3).toList();
  }

  Widget buildReactionSummary() {
    final reactions = visibleReactions;

    if (widget.post.reactionsCount <= 0 &&
        widget.post.commentsCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          if (widget.post.reactionsCount > 0)
            Expanded(
              child: GestureDetector(
                onTap: openReactions,
                child: Row(
                  children: [
                    if (reactions.isNotEmpty)
                      SizedBox(
                        width: (reactions.length * 17 + 5).w,
                        height: 23.h,
                        child: Stack(
                          children: [
                            for (int index = 0;
                            index < reactions.length;
                            index++)
                              Positioned(
                                left: index * 16.w,
                                child: Container(
                                  width: 23.w,
                                  height: 23.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    reactions[index].emoji,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (reactions.isNotEmpty)
                      SizedBox(width: 7.w),
                    Flexible(
                      child: Text(
                        '${widget.post.reactionsCount} reactions',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
          if (widget.post.commentsCount > 0)
            GestureDetector(
              onTap: openComments,
              child: Text(
                '${widget.post.commentsCount} comments',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildReactionButton() {
    final reaction = currentReaction;

    return Expanded(
      child: GestureDetector(
        onLongPress: openReactionPicker,
        child: _PostActionButton(
          icon: reaction?.emoji ?? '👍',
          label: reaction?.label ?? 'React',
          isActive: reaction != null,
          isLoading: isReacting,
          onTap: isCheckingReaction
              ? null
              : openReactionPicker,
        ),
      ),
    );
  }

  Widget buildCommentButton() {
    return Expanded(
      child: _PostActionButton(
        iconData: Icons.chat_bubble_outline_rounded,
        label: 'Comment',
        onTap: openComments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == post.authorId;

    final hasAuthorPhoto =
        authorPhotoUrl != null && authorPhotoUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                15.w,
                15.h,
                10.w,
                12.h,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.7.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: CircleAvatar(
                      radius: 21.r,
                      backgroundColor: AppColors.surface,
                      backgroundImage: hasAuthorPhoto
                          ? NetworkImage(authorPhotoUrl!)
                          : null,
                      child: !hasAuthorPhoto
                          ? isLoadingAuthorPhoto
                          ? SizedBox(
                        width: 17.w,
                        height: 17.w,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                        size: 21.sp,
                      )
                          : null,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius:
                                BorderRadius.circular(7.r),
                              ),
                              child: Text(
                                post.type.label,
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              '•',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              post.createdAt == null
                                  ? 'Just now'
                                  : DateFormatter.format(
                                post.createdAt!,
                              ),
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      tooltip: 'Post options',
                      onSelected: handleMenuAction,
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textSecondary,
                        size: 21.sp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (post.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  15.w,
                  0,
                  15.w,
                  14.h,
                ),
                child: Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            if (post.imageUrl != null &&
                post.imageUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 13.h),
                child: _PostImage(
                  imageUrl: post.imageUrl!,
                  onTap: openFullScreenImage,
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: buildReactionSummary(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                10.w,
                10.h,
                10.w,
                8.h,
              ),
              child: Container(
                height: 1,
                color: AppColors.borderLight,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                8.w,
                0,
                8.w,
                7.h,
              ),
              child: Row(
                children: [
                  buildReactionButton(),
                  buildCommentButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _PostImage({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.background,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return SizedBox(
              height: 220.h,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                  size: 34.sp,
                ),
              ),
            );
          },
          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {
            if (loadingProgress == null) {
              return child;
            }

            return SizedBox(
              height: 220.h,
              child: Center(
                child: SizedBox(
                  width: 25.w,
                  height: 25.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                    value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress
                        .cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImagePage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 48.sp,
                    );
                  },
                  loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                      ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 23.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String label;
  final bool isActive;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PostActionButton({
    this.icon,
    this.iconData,
    required this.label,
    this.isActive = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 42.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 17.w,
                  height: 17.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else if (icon != null)
                Text(
                  icon!,
                  style: TextStyle(fontSize: 17.sp),
                )
              else
                Icon(
                  iconData,
                  size: 19.sp,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostReactionsSheet extends StatefulWidget {
  final String postId;

  const PostReactionsSheet({
    super.key,
    required this.postId,
  });

  @override
  State<PostReactionsSheet> createState() =>
      _PostReactionsSheetState();
}

class _PostReactionsSheetState
    extends State<PostReactionsSheet> {
  late Future<List<PostReactionModel>> reactionsFuture;

  @override
  void initState() {
    super.initState();

    reactionsFuture = context
        .read<PostCubit>()
        .getPostReactions(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.65,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          const _SheetHandle(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              18.w,
              12.h,
              10.w,
              10.h,
            ),
            child: Row(
              children: [
                Text(
                  'Reactions',
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PostReactionModel>>(
              future: reactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load reactions'),
                  );
                }

                final reactions = snapshot.data ?? [];

                if (reactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No reactions yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: reactions.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      color: AppColors.borderLight,
                    );
                  },
                  itemBuilder: (context, index) {
                    final reaction = reactions[index];

                    final hasPhoto =
                        reaction.userPhotoUrl != null &&
                            reaction.userPhotoUrl!.isNotEmpty;

                    return ListTile(
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 5.h),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                        backgroundImage: hasPhoto
                            ? NetworkImage(
                          reaction.userPhotoUrl!,
                        )
                            : null,
                        child: !hasPhoto
                            ? Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                      title: Text(
                        reaction.userName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        reaction.reaction.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        reaction.reaction.emoji,
                        style: TextStyle(fontSize: 25.sp),
                      ),
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

class _ReactionPicker extends StatelessWidget {
  final ReactionType? currentReaction;

  const _ReactionPicker({
    required this.currentReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            SizedBox(height: 14.h),
            Text(
              'React to this post',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 17.h),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: ReactionType.values.map(
                    (reaction) {
                  final isSelected =
                      currentReaction == reaction;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        reaction,
                      );
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 150),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(
                          alpha: 0.09,
                        )
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(14.r),
                        border: isSelected
                            ? Border.all(
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            reaction.emoji,
                            style: TextStyle(
                              fontSize: 28.sp,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            reaction.label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}