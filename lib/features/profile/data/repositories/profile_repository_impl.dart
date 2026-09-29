import 'dart:io';

import 'package:injectable/injectable.dart';

import '../datasources/image_upload_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

@LazySingleton()
class ProfileRepositoryImpl {
  final ProfileRemoteDataSource remoteDataSource;
  final ImageUploadDataSource imageUploadDataSource;

  ProfileRepositoryImpl(
      this.remoteDataSource,
      this.imageUploadDataSource,
      );

  Future<ProfileModel?> getProfile(String uid) {
    return remoteDataSource.getProfile(uid);
  }

  Future<void> createProfile(ProfileModel profile) {
    return remoteDataSource.createProfile(profile);
  }

  Future<ProfileModel> updateProfile({
    required ProfileModel profile,
    File? image,
  }) async {
    var updatedProfile = profile;

    if (image != null) {
      final imageUrl =
      await imageUploadDataSource.uploadImage(image);

      updatedProfile = profile.copyWith(
        photoUrl: imageUrl,
      );
    }

    await remoteDataSource.updateProfile(updatedProfile);

    return updatedProfile;
  }
}