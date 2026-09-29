import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController roleController;
  late final TextEditingController bioController;
  late final TextEditingController skillsController;
  late final TextEditingController githubController;
  late final TextEditingController linkedinController;
  late final TextEditingController portfolioController;

  File? selectedImage;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    nameController =
        TextEditingController(text: profile.name);
    roleController =
        TextEditingController(text: profile.role);
    bioController =
        TextEditingController(text: profile.bio);
    skillsController = TextEditingController(
      text: profile.skills.join(', '),
    );
    githubController = TextEditingController(
      text: profile.githubUrl ?? '',
    );
    linkedinController = TextEditingController(
      text: profile.linkedinUrl ?? '',
    );
    portfolioController = TextEditingController(
      text: profile.portfolioUrl ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    bioController.dispose();
    skillsController.dispose();
    githubController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  void saveProfile() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final skills = skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    final updatedProfile = widget.profile.copyWith(
      name: nameController.text.trim(),
      role: roleController.text.trim(),
      bio: bioController.text.trim(),
      skills: skills,
      githubUrl: githubController.text.trim(),
      linkedinUrl: linkedinController.text.trim(),
      portfolioUrl: portfolioController.text.trim(),
    );

    context.read<ProfileCubit>().updateProfile(
      profile: updatedProfile,
      image: selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.updated) {
          Navigator.pop(context);
          return;
        }

        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
              content: Text(
                state.errorMessage ??
                    'Failed to update profile',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isUpdating =
            state.status == ProfileStatus.updating;

        final hasExistingPhoto =
            widget.profile.photoUrl != null &&
                widget.profile.photoUrl!.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: SafeArea(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  8.h,
                  16.w,
                  32.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 600.w,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: AppColors.softGradient,
                            borderRadius:
                            BorderRadius.circular(22.r),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: isUpdating
                                    ? null
                                    : pickImage,
                                child: Container(
                                  padding:
                                  EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient:
                                    AppColors.buttonGradient,
                                  ),
                                  child: CircleAvatar(
                                    radius: 54.r,
                                    backgroundColor:
                                    AppColors.surface,
                                    backgroundImage:
                                    selectedImage != null
                                        ? FileImage(
                                      selectedImage!,
                                    )
                                        : hasExistingPhoto
                                        ? NetworkImage(
                                      widget
                                          .profile
                                          .photoUrl!,
                                    )
                                        : null,
                                    child: selectedImage ==
                                        null &&
                                        !hasExistingPhoto
                                        ? Icon(
                                      Icons
                                          .person_outline_rounded,
                                      size: 46.sp,
                                      color:
                                      AppColors.primary,
                                    )
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Profile Photo',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight:
                                  FontWeight.w700,
                                  color:
                                  AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Keep your developer profile recognizable.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                  AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              TextButton.icon(
                                onPressed:
                                isUpdating
                                    ? null
                                    : pickImage,
                                icon: const Icon(
                                  Icons
                                      .photo_camera_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Change photo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 22.h),
                        _SectionLabel(
                          icon: Icons.person_outline_rounded,
                          title: 'Basic information',
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: nameController,
                          enabled: !isUpdating,
                          label: 'Name',
                          hint: 'Your name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Name is required';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: roleController,
                          enabled: !isUpdating,
                          label: 'Role',
                          hint: 'Flutter Developer',
                          icon: Icons.work_outline_rounded,
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: bioController,
                          enabled: !isUpdating,
                          label: 'Bio',
                          hint:
                          'Tell developers about yourself',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                        ),
                        SizedBox(height: 22.h),
                        _SectionLabel(
                          icon: Icons.code_rounded,
                          title: 'Skills',
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: skillsController,
                          enabled: !isUpdating,
                          label: 'Skills',
                          hint:
                          'Flutter, Dart, Firebase',
                          icon: Icons.code_rounded,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Separate your skills with commas.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        _SectionLabel(
                          icon: Icons.link_rounded,
                          title: 'Developer links',
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: githubController,
                          enabled: !isUpdating,
                          label: 'GitHub',
                          hint: 'https://github.com/...',
                          icon: Icons.code_rounded,
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: linkedinController,
                          enabled: !isUpdating,
                          label: 'LinkedIn',
                          hint:
                          'https://linkedin.com/in/...',
                          icon: Icons.work_outline_rounded,
                        ),
                        SizedBox(height: 12.h),
                        _Field(
                          controller: portfolioController,
                          enabled: !isUpdating,
                          label: 'Portfolio',
                          hint: 'https://yourportfolio.com',
                          icon: Icons.language_rounded,
                        ),
                        SizedBox(height: 28.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient:
                              AppColors.buttonGradient,
                              borderRadius:
                              BorderRadius.circular(15.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isUpdating
                                  ? null
                                  : saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.transparent,
                                shadowColor:
                                Colors.transparent,
                                foregroundColor:
                                Colors.white,
                                disabledBackgroundColor:
                                Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    15.r,
                                  ),
                                ),
                              ),
                              child: isUpdating
                                  ? SizedBox(
                                width: 21.w,
                                height: 21.w,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons
                                        .check_circle_outline,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 17.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 9.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}