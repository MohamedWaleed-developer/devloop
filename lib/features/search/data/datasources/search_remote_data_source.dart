import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/data/models/profile_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ProfileModel>> searchDevelopers(String query);
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl
    implements SearchRemoteDataSource {
  final FirebaseFirestore firestore;

  SearchRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ProfileModel>> searchDevelopers(
      String query,
      ) async {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) {
      return [];
    }

    final snapshot = await firestore
        .collection('users')
        .limit(100)
        .get();

    return snapshot.docs
        .map(ProfileModel.fromFirestore)
        .where(
          (profile) =>
      profile.name.toLowerCase().contains(value) ||
          profile.role.toLowerCase().contains(value) ||
          profile.skills.any(
                (skill) =>
                skill.toLowerCase().contains(value),
          ),
    )
        .take(30)
        .toList();
  }
}