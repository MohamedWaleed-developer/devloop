import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void sendResetLink() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(
      email: emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _ForgotPasswordBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 28.h,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 470.w,
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              content: const Text(
                'Password reset link sent successfully',
              ),
            ),
          );

          Navigator.pop(context);
        }

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              content: Text(
                state.errorMessage ??
                    'Something went wrong',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                22.w,
                30.h,
                22.w,
                24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 35,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Reset your password',
                      subtitle:
                      'Enter your email and we will send you a secure reset link',
                    ),
                    SizedBox(height: 34.h),
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.06,
                        ),
                        borderRadius:
                        BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                          AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              gradient:
                              AppColors.buttonGradient,
                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.mark_email_read_outlined,
                              color: Colors.white,
                              size: 19.sp,
                            ),
                          ),
                          SizedBox(width: 11.w),
                          Expanded(
                            child: Text(
                              'We will send a password reset link to your email address.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.45,
                                color:
                                AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),
                    AuthTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon:
                      Icons.email_outlined,
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 25.h),
                    AuthPrimaryButton(
                      title: 'Send Reset Link',
                      isLoading:
                      state.status == AuthStatus.loading,
                      onPressed: sendResetLink,
                    ),
                    SizedBox(height: 12.h),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      label: const Text(
                        'Back to sign in',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordBackground extends StatelessWidget {
  const _ForgotPasswordBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.softGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _Glow(
              size: 310,
              color: AppColors.secondary,
            ),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: _Glow(
              size: 350,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.07),
      ),
    );
  }
}