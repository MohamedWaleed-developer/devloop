import 'package:injectable/injectable.dart';

import '../datasources/auth_remote_data_source.dart';
import '../models/uesr_model.dart';
import '../datasources/auth_remote_data_source.dart';


@LazySingleton()
class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  Stream<UserModel?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
          (user) {
        if (user == null) {
          return null;
        }

        return UserModel.fromFirebaseUser(user);
      },
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.login(
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user);
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  Future<void> logout() {
    return remoteDataSource.logout();
  }
}