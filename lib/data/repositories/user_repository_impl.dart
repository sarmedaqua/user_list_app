import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/connectivity_service.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

// Implementation of UserRepository that handles user data fetching
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, UsersResponseModel>> getUsers({required int page, required int perPage}) async {
    if (await connectivityService.hasConnection()) {
      try {
        final remoteUsers = await remoteDataSource.getUsers(page: page, perPage: perPage);
        localDataSource.cacheUsers(remoteUsers, page);
        return Right(remoteUsers);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on TimeoutException {
        return Left(TimeoutFailure());
      }
    } else {
      try {
        final localUsers = await localDataSource.getCachedUsers(page);
        if (localUsers != null) {
          return Right(localUsers);
        } else {
          return Left(NoConnectionFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}