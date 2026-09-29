// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:devloop/core/di/injection_container.dart' as _i259;
import 'package:devloop/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i468;
import 'package:devloop/features/auth/data/repositories/auth_repository_impl.dart'
    as _i586;
import 'package:devloop/features/auth/presentation/cubit/auth_cubit.dart'
    as _i52;
import 'package:devloop/features/notifications/data/datasources/notification_remots_data_source.dart'
    as _i638;
import 'package:devloop/features/notifications/data/repositories/notification_repository_impl.dart'
    as _i807;
import 'package:devloop/features/notifications/presentation/cubit/notification_cubit.dart'
    as _i725;
import 'package:devloop/features/posts/data/datasources/post_image_upload_data_source.dart'
    as _i668;
import 'package:devloop/features/posts/data/datasources/post_remote_data_source.dart'
    as _i247;
import 'package:devloop/features/posts/data/repositories/post_repository_impl.dart'
    as _i195;
import 'package:devloop/features/posts/presentation/cubit/post_cubit.dart'
    as _i467;
import 'package:devloop/features/profile/data/datasources/image_upload_data_source.dart'
    as _i391;
import 'package:devloop/features/profile/data/datasources/profile_remote_data_source.dart'
    as _i380;
import 'package:devloop/features/profile/data/repositories/profile_repository_impl.dart'
    as _i841;
import 'package:devloop/features/profile/presentation/cubit/profile_cubit.dart'
    as _i527;
import 'package:devloop/features/search/data/datasources/search_remote_data_source.dart'
    as _i105;
import 'package:devloop/features/search/data/repositories/search_repository_impl.dart'
    as _i530;
import 'package:devloop/features/search/presentation/cubit/search_cubit.dart'
    as _i503;
import 'package:devloop/features/social/data/datasources/social_remote_data_source.dart'
    as _i839;
import 'package:devloop/features/social/data/repositories/social_repository_impl.dart'
    as _i691;
import 'package:devloop/features/social/presentation/cubit/social_cubit.dart'
    as _i473;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i668.PostImageUploadDataSource>(
      () => _i668.PostImageUploadDataSource(),
    );
    gh.lazySingleton<_i391.ImageUploadDataSource>(
      () => _i391.ImageUploadDataSource(),
    );
    gh.lazySingleton<_i839.SocialRemoteDataSource>(
      () => _i839.SocialRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i380.ProfileRemoteDataSource>(
      () => _i380.ProfileRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i841.ProfileRepositoryImpl>(
      () => _i841.ProfileRepositoryImpl(
        gh<_i380.ProfileRemoteDataSource>(),
        gh<_i391.ImageUploadDataSource>(),
      ),
    );
    gh.lazySingleton<_i468.AuthRemoteDataSource>(
      () => _i468.AuthRemoteDataSourceImpl(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i638.NotificationRemoteDataSource>(
      () =>
          _i638.NotificationRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i105.SearchRemoteDataSource>(
      () => _i105.SearchRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i247.PostRemoteDataSource>(
      () => _i247.PostRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i527.ProfileCubit>(
      () => _i527.ProfileCubit(gh<_i841.ProfileRepositoryImpl>()),
    );
    gh.lazySingleton<_i530.SearchRepositoryImpl>(
      () => _i530.SearchRepositoryImpl(gh<_i105.SearchRemoteDataSource>()),
    );
    gh.lazySingleton<_i195.PostRepositoryImpl>(
      () => _i195.PostRepositoryImpl(
        gh<_i247.PostRemoteDataSource>(),
        gh<_i668.PostImageUploadDataSource>(),
      ),
    );
    gh.lazySingleton<_i586.AuthRepositoryImpl>(
      () => _i586.AuthRepositoryImpl(gh<_i468.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i691.SocialRepositoryImpl>(
      () => _i691.SocialRepositoryImpl(gh<_i839.SocialRemoteDataSource>()),
    );
    gh.factory<_i503.SearchCubit>(
      () => _i503.SearchCubit(gh<_i530.SearchRepositoryImpl>()),
    );
    gh.lazySingleton<_i807.NotificationRepositoryImpl>(
      () => _i807.NotificationRepositoryImpl(
        gh<_i638.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i467.PostCubit>(
      () => _i467.PostCubit(
        gh<_i195.PostRepositoryImpl>(),
        gh<_i841.ProfileRepositoryImpl>(),
      ),
    );
    gh.factory<_i52.AuthCubit>(
      () => _i52.AuthCubit(gh<_i586.AuthRepositoryImpl>()),
    );
    gh.factory<_i725.NotificationCubit>(
      () => _i725.NotificationCubit(gh<_i807.NotificationRepositoryImpl>()),
    );
    gh.factory<_i473.SocialCubit>(
      () => _i473.SocialCubit(
        gh<_i691.SocialRepositoryImpl>(),
        gh<_i807.NotificationRepositoryImpl>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i259.FirebaseModule {}
