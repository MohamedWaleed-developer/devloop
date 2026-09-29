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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void register() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _RegisterBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 24.h,
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
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              content: Text(
                state.errorMessage ?? 'Registration failed',
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
                28.h,
                22.w,
                18.h,
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
                      title: 'Create your account',
                      subtitle:
                      'Join developers, share knowledge and grow together',
                    ),
                    SizedBox(height: 30.h),
                    AuthTextField(
                      label: 'Full name',
                      hint: 'Enter your full name',
                      prefixIcon:
                      Icons.person_outline_rounded,
                      controller: nameController,
                      validator: Validators.required,
                    ),
                    SizedBox(height: 15.h),
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
                    SizedBox(height: 15.h),
                    AuthTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      prefixIcon:
                      Icons.lock_outline_rounded,
                      controller: passwordController,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    SizedBox(height: 15.h),
                    AuthTextField(
                      label: 'Confirm password',
                      hint: 'Confirm your password',
                      prefixIcon:
                      Icons.lock_reset_outlined,
                      controller:
                      confirmPasswordController,
                      isPassword: true,
                      validator: (value) {
                        return Validators.confirmPassword(
                          value,
                          passwordController.text,
                        );
                      },
                    ),
                    SizedBox(height: 25.h),
                    AuthPrimaryButton(
                      title: 'Create Account',
                      isLoading:
                      state.status == AuthStatus.loading,
                      onPressed: register,
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Sign in'),
                        ),
                      ],
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

class _RegisterBackground extends StatelessWidget {
  const _RegisterBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.softGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            left: -110,
            child: _Glow(
              size: 330,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            bottom: -150,
            right: -110,
            child: _Glow(
              size: 360,
              color: AppColors.secondary,
            ),
          ),
          Positioned(
            top: 310,
            right: -80,
            child: _Glow(
              size: 180,
              color: AppColors.violet,
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