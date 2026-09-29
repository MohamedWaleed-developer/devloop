import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/post_cubit.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class CommentsSheet extends StatefulWidget {
  final PostModel post;

  const CommentsSheet({
    super.key,
    required this.post,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController commentController =
  TextEditingController();
  final FocusNode commentFocusNode = FocusNode();

  String? replyingToCommentId;
  String? replyingToName;
  bool isSending = false;

  @override
  void dispose() {
    commentController.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> sendComment() async {
    final content = commentController.text.trim();

    if (content.isEmpty || isSending) {
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await context.read<PostCubit>().addComment(
        postId: widget.post.id,
        content: content,
        parentCommentId: replyingToCommentId,
      );

      if (!mounted) {
        return;
      }

      commentController.clear();

      setState(() {
        replyingToCommentId = null;
        replyingToName = null;
      });

      commentFocusNode.unfocus();
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  void startReply(CommentModel comment) {
    setState(() {
      replyingToCommentId = comment.id;
      replyingToName = comment.authorName;
    });

    commentFocusNode.requestFocus();
  }

  void cancelReply() {
    setState(() {
      replyingToCommentId = null;
      replyingToName = null;
    });

    commentFocusNode.unfocus();
  }

  Future<void> deleteComment(CommentModel comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: const Text('Delete comment'),
          content: const Text(
            'Are you sure you want to delete this comment?',
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

    await context.read<PostCubit>().deleteComment(
      postId: widget.post.id,
      commentId: comment.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          const _CommentsHandle(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              18.w,
              10.h,
              10.w,
              8.h,
            ),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                StreamBuilder<List<CommentModel>>(
                  stream: context
                      .read<PostCubit>()
                      .commentsStream(widget.post.id),
                  builder: (_, snapshot) {
                    final count = snapshot.data?.length ?? 0;

                    if (count == 0) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
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
            child: StreamBuilder<List<CommentModel>>(
              stream: context
                  .read<PostCubit>()
                  .commentsStream(widget.post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load comments',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  );
                }

                final comments = snapshot.data ?? [];

                final rootComments = comments
                    .where(
                      (comment) => !comment.isReply,
                )
                    .toList();

                if (rootComments.isEmpty) {
                  return const _EmptyComments();
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    14.w,
                    4.h,
                    14.w,
                    120.h,
                  ),
                  itemCount: rootComments.length,
                  itemBuilder: (context, index) {
                    final comment = rootComments[index];

                    final replies = comments
                        .where(
                          (reply) =>
                      reply.parentCommentId ==
                          comment.id,
                    )
                        .toList();

                    return _CommentThread(
                      comment: comment,
                      replies: replies,
                      onReply: startReply,
                      onDelete: deleteComment,
                    );
                  },
                );
              },
            ),
          ),
          _CommentInput(
            controller: commentController,
            focusNode: commentFocusNode,
            isSending: isSending,
            replyingToName: replyingToName,
            onCancelReply: cancelReply,
            onSend: sendComment,
          ),
        ],
      ),
    );
  }
}

class _CommentThread extends StatelessWidget {
  final CommentModel comment;
  final List<CommentModel> replies;
  final ValueChanged<CommentModel> onReply;
  final ValueChanged<CommentModel> onDelete;

  const _CommentThread({
    required this.comment,
    required this.replies,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentTile(
          comment: comment,
          onReply: onReply,
          onDelete: onDelete,
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 42.w),
            child: Column(
              children: replies
                  .map(
                    (reply) => _CommentTile(
                  comment: reply,
                  isReply: true,
                  onReply: onReply,
                  onDelete: onDelete,
                ),
              )
                  .toList(),
            ),
          ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _CommentTile extends StatefulWidget {
  final CommentModel comment;
  final bool isReply;
  final ValueChanged<CommentModel> onReply;
  final ValueChanged<CommentModel> onDelete;

  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  ReactionType? currentReaction;
  bool isLoadingReaction = true;
  bool isReacting = false;

  @override
  void initState() {
    super.initState();
    loadReaction();
  }

  Future<void> loadReaction() async {
    final reaction = await context
        .read<PostCubit>()
        .getCommentReaction(
      postId: widget.comment.postId,
      commentId: widget.comment.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      currentReaction = reaction;
      isLoadingReaction = false;
    });
  }

  Future<void> toggleReaction(
      ReactionType reaction,
      ) async {
    if (isReacting) {
      return;
    }

    final isRemoving = currentReaction == reaction;

    setState(() {
      isReacting = true;
    });

    try {
      await context.read<PostCubit>().setCommentReaction(
        postId: widget.comment.postId,
        commentId: widget.comment.id,
        reaction: reaction,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        currentReaction =
        isRemoving ? null : reaction;
      });
    } finally {
      if (mounted) {
        setState(() {
          isReacting = false;
        });
      }
    }
  }

  Future<void> openReactionPicker() async {
    if (isLoadingReaction || isReacting) {
      return;
    }

    final reaction =
    await showModalBottomSheet<ReactionType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _CommentReactionPicker(
          currentReaction: currentReaction,
        );
      },
    );

    if (reaction == null || !mounted) {
      return;
    }

    await toggleReaction(reaction);
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          uid: widget.comment.authorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final hasPhoto = comment.authorPhotoUrl != null &&
        comment.authorPhotoUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        top: 8.h,
        bottom: 3.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: openProfile,
            child: CircleAvatar(
              radius: widget.isReply ? 16.r : 19.r,
              backgroundColor:
              AppColors.primary.withValues(alpha: 0.08),
              backgroundImage: hasPhoto
                  ? NetworkImage(comment.authorPhotoUrl!)
                  : null,
              child: !hasPhoto
                  ? Icon(
                Icons.person_outline_rounded,
                size: widget.isReply ? 17.sp : 20.sp,
                color: AppColors.primary,
              )
                  : null,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                12.w,
                10.h,
                10.w,
                8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: openProfile,
                          child: Text(
                            comment.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 18.sp,
                        tooltip: 'Options',
                        onSelected: (value) {
                          if (value == 'delete') {
                            widget.onDelete(comment);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                ),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        comment.createdAt == null
                            ? 'Just now'
                            : DateFormatter.format(
                          comment.createdAt!,
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      GestureDetector(
                        onTap: () =>
                            widget.onReply(comment),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      GestureDetector(
                        onTap: openReactionPicker,
                        child: Row(
                          children: [
                            if (isReacting)
                              SizedBox(
                                width: 13.w,
                                height: 13.w,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                ),
                              )
                            else
                              Text(
                                currentReaction?.emoji ??
                                    '♡',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                            SizedBox(width: 4.w),
                            Text(
                              currentReaction?.label ??
                                  'React',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight:
                                currentReaction != null
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color:
                                currentReaction != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final String? replyingToName;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.replyingToName,
    required this.onCancelReply,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingToName != null)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 7.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.07,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Replying to $replyingToName',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: Icon(
                        Icons.close_rounded,
                        size: 17.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: replyingToName == null
                          ? 'Write a comment...'
                          : 'Write a reply...',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 11.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18.r),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InkWell(
                    onTap: isSending ? null : onSend,
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: 46.w,
                      height: 46.w,
                      child: Center(
                        child: isSending
                            ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child:
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 21.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentReactionPicker extends StatelessWidget {
  final ReactionType? currentReaction;

  const _CommentReactionPicker({
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
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CommentsHandle(),
            SizedBox(height: 14.h),
            Text(
              'React to comment',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: ReactionType.values.map(
                    (reaction) {
                  final selected =
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
                        color: selected
                            ? AppColors.primary.withValues(
                          alpha: 0.08,
                        )
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(14.r),
                        border: selected
                            ? Border.all(
                          color: AppColors.primary,
                        )
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            reaction.emoji,
                            style: TextStyle(
                              fontSize: 27.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            reaction.label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
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

class _CommentsHandle extends StatelessWidget {
  const _CommentsHandle();

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

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 31.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Start the conversation and share your thoughts.',
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