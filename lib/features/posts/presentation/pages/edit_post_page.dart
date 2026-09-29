import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';
import '../widgets/post_image_picker.dart';
import '../widgets/post_type_selector.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({
    super.key,
    required this.post,
  });

  @override
  State<EditPostPage> createState() =>
      _EditPostPageState();
}

class _EditPostPageState
    extends State<EditPostPage> {
  late final TextEditingController contentController;

  late PostType selectedType;

  File? selectedImage;
  bool removeExistingImage = false;

  @override
  void initState() {
    super.initState();

    contentController = TextEditingController(
      text: widget.post.content,
    );

    selectedType = widget.post.type;
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  Future<void> pickNewImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
      removeExistingImage = false;
    });
  }

  Future<void> updatePost(BuildContext context) async {
    final content = contentController.text.trim();

    if (content.isEmpty &&
        selectedImage == null &&
        widget.post.imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add text or an image'),
        ),
      );
      return;
    }

    final updatedPost = widget.post.copyWith(
      content: content,
      type: selectedType,
    );

    await context.read<PostCubit>().updatePost(
      post: updatedPost,
      image: selectedImage,
      removeImage: removeExistingImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostCubit>(),
      child: BlocConsumer<PostCubit, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.updated) {
            Navigator.pop(context);
          }

          if (state.status == PostStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                content: Text(
                  state.errorMessage ??
                      'Something went wrong',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isUpdating =
              state.status == PostStatus.updating;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16.w,
              title: Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18.w,
                  8.h,
                  18.w,
                  30.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 700.w,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 20.h),
                        _buildContentField(isUpdating),
                        SizedBox(height: 22.h),
                        _buildSectionTitle(
                          'Post Type',
                        ),
                        SizedBox(height: 10.h),
                        PostTypeSelector(
                          selectedType: selectedType,
                          onChanged: isUpdating
                              ? (_) {}
                              : (type) {
                            setState(() {
                              selectedType = type;
                            });
                          },
                        ),
                        SizedBox(height: 22.h),
                        _buildSectionTitle(
                          'Media',
                        ),
                        SizedBox(height: 10.h),
                        _buildImageSection(isUpdating),
                        SizedBox(height: 28.h),
                        _buildSaveButton(
                          context,
                          isUpdating,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.09,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 23.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit your post',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Update your content, type or image.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentField(bool isUpdating) {
    return TextField(
      controller: contentController,
      enabled: !isUpdating,
      minLines: 6,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText:
        'Share something with developers...',
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: AppColors.textMuted,
        ),
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.all(16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildImageSection(bool isUpdating) {
    if (selectedImage != null) {
      return PostImagePicker(
        image: selectedImage,
        onImageSelected: isUpdating
            ? (_) {}
            : (image) {
          setState(() {
            selectedImage = image;
          });
        },
      );
    }

    if (widget.post.imageUrl != null &&
        !removeExistingImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Image.network(
              widget.post.imageUrl!,
              width: double.infinity,
              height: 230.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 230.h,
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                    size: 32.sp,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Material(
              color: Colors.black.withValues(
                alpha: 0.60,
              ),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isUpdating
                    ? null
                    : () {
                  setState(() {
                    removeExistingImage = true;
                  });
                },
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(9.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 19.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return PostImagePicker(
      image: null,
      onImageSelected: isUpdating
          ? (_) {}
          : (image) {
        setState(() {
          selectedImage = image;
        });
      },
    );
  }

  Widget _buildSaveButton(
      BuildContext context,
      bool isUpdating,
      ) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient:
        isUpdating ? null : AppColors.buttonGradient,
        color: isUpdating
            ? AppColors.primary.withValues(
          alpha: 0.55,
        )
            : null,
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: isUpdating
            ? null
            : [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUpdating
              ? null
              : () => updatePost(context),
          borderRadius: BorderRadius.circular(17.r),
          child: Center(
            child: isUpdating
                ? SizedBox(
              width: 22.w,
              height: 22.w,
              child:
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.2,
              ),
            )
                : Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 19.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}