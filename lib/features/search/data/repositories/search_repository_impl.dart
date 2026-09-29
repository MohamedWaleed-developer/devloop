import 'package:injectable/injectable.dart';

import '../../../profile/data/models/profile_model.dart';
import '../datasources/search_remote_data_source.dart';

@LazySingleton()
class SearchRepositoryImpl {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  Future<List<ProfileModel>> searchDevelopers(
      String query,
      ) {
    return remoteDataSource.searchDevelopers(query);
  }
}