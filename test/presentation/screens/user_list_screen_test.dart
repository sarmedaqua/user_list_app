
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:user_list_app/core/errors/failures.dart';
import 'package:user_list_app/data/models/user_model.dart';
import 'package:user_list_app/domain/usecases/get_users_usecase.dart';
import 'package:user_list_app/presentation/providers/user_providers.dart';
import 'package:user_list_app/presentation/screens/user_list_screen.dart';

@GenerateMocks([GetUsersUseCase])
import 'user_list_screen_test.mocks.dart';

void main() {
  late MockGetUsersUseCase mockGetUsersUseCase;

  setUp(() {
    mockGetUsersUseCase = MockGetUsersUseCase();
  });

  testWidgets('should show user list when data is loaded', (WidgetTester tester) async {
    // Arrange
    when(mockGetUsersUseCase.call(page: 1, perPage: 10)).thenAnswer(
          (_) async => Right(
        UsersResponseModel(
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
            ),
            UserModel(
              id: 2,
              email: 'janet.weaver@reqres.in',
              firstName: 'Janet',
              lastName: 'Weaver',
              avatar: 'https://reqres.in/img/faces/2-image.jpg',
            ),
          ],
        ),
      ),
    );

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getUsersUseCaseProvider.overrideWithValue(mockGetUsersUseCase),
        ],
        child: const MaterialApp(
          home: UserListScreen(),
        ),
      ),
    );

    // Wait for the data to load
    await tester.pump(const Duration(milliseconds: 300));

    // Assert
    expect(find.text('George Bluth'), findsOneWidget);
    expect(find.text('Janet Weaver'), findsOneWidget);
  });

  testWidgets('should show error widget when error occurs', (WidgetTester tester) async {
    // Arrange
    when(mockGetUsersUseCase.call(page: 1, perPage: 10)).thenAnswer(
          (_) async => Left(ServerFailure('Server error')),
    );

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getUsersUseCaseProvider.overrideWithValue(mockGetUsersUseCase),
        ],
        child: const MaterialApp(
          home: UserListScreen(),
        ),
      ),
    );

    // Wait for the error widget to appear
    await tester.pump(const Duration(milliseconds: 300));

    // Assert
    expect(find.text('Server error'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });


}