import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository_impl.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepositoryImpl repository;

  ProfileCubit(this.repository) : super(const ProfileState());

  Future<void> getProfile(String uid) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
      ),
    );

    try {
      final profile = await repository.getProfile(uid);

      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'Profile not found',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createProfile(ProfileModel profile) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
      ),
    );

    try {
      await repository.createProfile(profile);

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateProfile({
    required ProfileModel profile,
    File? image,
  }) async {
    emit(
      state.copyWith(
        status: ProfileStatus.updating,
        clearError: true,
      ),
    );

    try {
      final updatedProfile = await repository.updateProfile(
        profile: profile,
        image: image,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.updated,
          profile: updatedProfile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}