import 'package:equatable/equatable.dart';

import '../../data/models/uesr_model.dart';


enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  success,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user?.uid,
    user?.email,
    user?.displayName,
    user?.photoUrl,
    errorMessage,
  ];
}