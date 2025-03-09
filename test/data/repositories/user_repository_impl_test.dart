
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:user_list_app/core/errors/exceptions.dart';
import 'package:user_list_app/core/errors/failures.dart';
import 'package:user_list_app/core/network/connectivity_service.dart';
import 'package:user_list_app/data/datasources/user_local_data_source.dart';
import 'package:user_list_app/data/datasources/user_remote_data_source.dart';
import 'package:user_list_app/data/models/user_model.dart';
import 'package:user_list_app/data/repositories/user_repository_impl.dart';

// Generate mocks
@GenerateMocks([
  UserRemoteDataSource,
  UserLocalDataSource,
  ConnectivityService,
])
import 'user_repository_impl_test.mocks.dart';

void main() {
  late MockUserRemoteDataSource mockRemoteDataSource;
  late MockUserLocalDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;
  late UserRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockUserRemoteDataSource();
    mockLocalDataSource = MockUserLocalDataSource();
    mockConnectivityService = MockConnectivityService();
    repository = UserRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivityService: mockConnectivityService,
    );
  });

  final tUsersResponse = UsersResponseModel(
    page: 1,
    perPage: 10,
    total: 12,
    totalPages: 2,
    users: [
      UserModel(
        id: 1,
        email: 'george.bluth@reqres.in',
        firstName: 'George',
        lastName: 'Bluth',
        avatar: 'https://reqres.in/img/faces/1-image.jpg',
      )
    ],
  );

  group('getUsers', () {
    const tPage = 1;
    const tPerPage = 10;

    test(
      'should return remote data when the call to remote data source is successful',
          () async {
        // arrange
        when(mockConnectivityService.hasConnection())
            .thenAnswer((_) async => true);
        when(mockRemoteDataSource.getUsers(page: tPage, perPage: tPerPage))
            .thenAnswer((_) async => tUsersResponse);
        // act
        final result = await repository.getUsers(page: tPage, perPage: tPerPage);
        // assert
        expect(result, Right(tUsersResponse));
        verify(mockRemoteDataSource.getUsers(page: tPage, perPage: tPerPage));
        verify(mockLocalDataSource.cacheUsers(tUsersResponse, tPage));
      },
    );

    test(
      'should return cached data when there is no connection and cached data is available',
          () async {
        // arrange
        when(mockConnectivityService.hasConnection())
            .thenAnswer((_) async => false);
        when(mockLocalDataSource.getCachedUsers(tPage))
            .thenAnswer((_) async => tUsersResponse);
        // act
        final result = await repository.getUsers(page: tPage, perPage: tPerPage);
        // assert
        expect(result, Right(tUsersResponse));
        verify(mockLocalDataSource.getCachedUsers(tPage));
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );

  });
}