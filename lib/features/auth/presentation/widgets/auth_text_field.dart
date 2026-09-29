import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool obscureText = true;
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Focus(
          onFocusChange: (value) {
            setState(() {
              focused = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              boxShadow: focused
                  ? [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              obscureText:
              widget.isPassword && obscureText,
              keyboardType: widget.keyboardType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(
                    left: 4.w,
                    right: 4.w,
                  ),
                  child: Icon(
                    widget.prefixIcon,
                    size: 20.sp,
                  ),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                  splashRadius: 22,
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20.sp,
                  ),
                )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}