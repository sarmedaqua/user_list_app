import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/datasources/user_local_data_source.dart';
//import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../presentation/providers/user_providers.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => ConnectivityService(sl()));

  // datasources
  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
        () => UserLocalDataSourceImpl(sl()),
  );

  // repositories
  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivityService: sl(),
    ),
  );

  // usecases
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));

  // Providers
  //sl.registerFactory<GetUsersUseCase>(() => sl());
}