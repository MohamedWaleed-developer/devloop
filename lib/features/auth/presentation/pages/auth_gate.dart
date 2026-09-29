import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/pages/main_navigation_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            final user = state.user;

            if (user == null) {
              return const LoginPage();
            }

            return MainNavigationPage(
              uid: user.uid,
            );

          case AuthStatus.unauthenticated:
            return const LoginPage();

          case AuthStatus.initial:
          case AuthStatus.loading:
          case AuthStatus.success:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthStatus.failure:
            return Scaffold(
              body: Center(
                child: Text(
                  state.errorMessage ??
                      'Something went wrong',
                ),
              ),
            );
        }
      },
    );
  }
}