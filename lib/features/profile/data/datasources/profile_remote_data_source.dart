import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String uid);

  Future<void> createProfile(ProfileModel profile);

  Future<void> updateProfile(ProfileModel profile);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get usersCollection {
    return firestore.collection('users');
  }

  @override
  Future<ProfileModel?> getProfile(String uid) async {
    final document = await usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return ProfileModel.fromFirestore(document);
  }

  @override
  Future<void> createProfile(ProfileModel profile) {
    return usersCollection.doc(profile.uid).set(
      profile.toFirestore(),
    );
  }

  @override
  Future<void> updateProfile(ProfileModel profile) {
    return usersCollection.doc(profile.uid).update({
      'name': profile.name,
      'email': profile.email,
      'photoUrl': profile.photoUrl,
      'bio': profile.bio,
      'role': profile.role,
      'skills': profile.skills,
      'githubUrl': profile.githubUrl,
      'linkedinUrl': profile.linkedinUrl,
      'portfolioUrl': profile.portfolioUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}