import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

class PostImagePicker extends StatefulWidget {
  final File? image;
  final ValueChanged<File?> onImageSelected;

  const PostImagePicker({
    super.key,
    this.image,
    required this.onImageSelected,
  });

  @override
  State<PostImagePicker> createState() =>
      _PostImagePickerState();
}

class _PostImagePickerState
    extends State<PostImagePicker> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.image;
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    final file = File(pickedFile.path);

    setState(() {
      selectedImage = file;
    });

    widget.onImageSelected(file);
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
    });

    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedImage != null) {
      return _SelectedImage(
        image: selectedImage!,
        onRemove: removeImage,
      );
    }

    return _EmptyImagePicker(
      onTap: pickImage,
    );
  }
}

class _EmptyImagePicker extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyImagePicker({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          height: 145.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                  BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.primary,
                  size: 25.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Add an image',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Share a screenshot, project or achievement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedImage extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _SelectedImage({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Stack(
        children: [
          Image.file(
            image,
            width: double.infinity,
            height: 220.h,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Material(
              color: Colors.black.withValues(alpha: 0.58),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 38.w,
                  height: 38.w,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            bottom: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 9.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.55,
                ),
                borderRadius:
                BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Selected image',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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