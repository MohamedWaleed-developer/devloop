import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl
    implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
      await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'Unable to complete login',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapFirebaseError(e.code),
      );
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential =
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'Unable to create account',
        );
      }

      await user.updateDisplayName(
        name.trim(),
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapFirebaseError(e.code),
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _mapFirebaseError(e.code),
      );
    }
  }

  @override
  Future<void> logout() {
    return firebaseAuth.signOut();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address';

      case 'user-disabled':
        return 'This account has been disabled';

      case 'user-not-found':
        return 'No account found with this email';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';

      case 'email-already-in-use':
        return 'This email is already registered';

      case 'weak-password':
        return 'Password is too weak';

      case 'too-many-requests':
        return 'Too many attempts. Try again later';

      case 'network-request-failed':
        return 'Check your internet connection';

      case 'operation-not-allowed':
        return 'Email and password authentication is not enabled';

      default:
        return 'Something went wrong. Please try again';
    }
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}