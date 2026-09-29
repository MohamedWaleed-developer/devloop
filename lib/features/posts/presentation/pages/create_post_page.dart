import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/post_model.dart';
import '../cubit/post_cubit.dart';
import '../cubit/post_state.dart';
import '../widgets/post_image_picker.dart';
import '../widgets/post_type_selector.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() =>
      _CreatePostPageState();
}

class _CreatePostPageState
    extends State<CreatePostPage> {
  final formKey = GlobalKey<FormState>();
  final contentController = TextEditingController();

  PostType selectedType = PostType.knowledge;
  File? selectedImage;

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  void createPost(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    context.read<PostCubit>().createPost(
      content: contentController.text,
      type: selectedType,
      image: selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostCubit>(),
      child: BlocConsumer<PostCubit, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.created) {
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
          final isCreating =
              state.status == PostStatus.creating;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16.w,
              title: Text(
                'Create Post',
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildIntro(),
                          SizedBox(height: 20.h),
                          _buildContentField(isCreating),
                          SizedBox(height: 22.h),
                          _buildSectionTitle(
                            'Post Type',
                          ),
                          SizedBox(height: 10.h),
                          PostTypeSelector(
                            selectedType: selectedType,
                            onChanged: isCreating
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
                          PostImagePicker(
                            image: selectedImage,
                            onImageSelected: isCreating
                                ? (_) {}
                                : (image) {
                              setState(() {
                                selectedImage = image;
                              });
                            },
                          ),
                          SizedBox(height: 28.h),
                          _buildPublishButton(
                            context,
                            isCreating,
                          ),
                        ],
                      ),
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

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with the community',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Share knowledge, projects, ideas or experiences.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
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

  Widget _buildContentField(bool isCreating) {
    return TextFormField(
      controller: contentController,
      enabled: !isCreating,
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
        'What do you want to share with developers?',
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
      ),
      validator: (value) {
        if ((value == null ||
            value.trim().isEmpty) &&
            selectedImage == null) {
          return 'Add text or an image';
        }

        return null;
      },
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

  Widget _buildPublishButton(
      BuildContext context,
      bool isCreating,
      ) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient:
        isCreating ? null : AppColors.buttonGradient,
        color: isCreating
            ? AppColors.primary.withValues(
          alpha: 0.55,
        )
            : null,
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: isCreating
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
          onTap: isCreating
              ? null
              : () => createPost(context),
          borderRadius: BorderRadius.circular(17.r),
          child: Center(
            child: isCreating
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
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Publish Post',
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