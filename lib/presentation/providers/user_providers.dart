import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../core/errors/failures.dart';

// UserState
class UserState {
  final List<UserModel> users;
  final bool isLoading;
  final bool hasReachedMax;
  final Failure? failure;
  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final bool isSearching;

  UserState({
    required this.users,
    required this.isLoading,
    required this.hasReachedMax,
    this.failure,
    required this.currentPage,
    required this.totalPages,
    required this.searchQuery,
    required this.isSearching,
  });

  // Initial state
  factory UserState.initial() {
    return UserState(
      users: [],
      isLoading: false,
      hasReachedMax: false,
      failure: null,
      currentPage: 1,
      totalPages: 1,
      searchQuery: '',
      isSearching: false,
    );
  }

  // copyWith method for immutability
  UserState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? hasReachedMax,
    Failure? failure,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    bool? isSearching,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: failure,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  // Get filtered users based on search query
  List<UserModel> get filteredUsers {
    if (searchQuery.isEmpty) return users;

    return users.where((user) =>
        user.fullName.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
}

// UserNotifier
class UserNotifier extends StateNotifier<UserState> {
  final GetUsersUseCase _getUsersUseCase;
  static const int _perPage = 10;

  UserNotifier(this._getUsersUseCase) : super(UserState.initial());

  Future<void> getUsers({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        failure: null,
        users: [],
        hasReachedMax: false,
      );
    } else {
      // Return when reaching maximum
      if (state.hasReachedMax) return;

      state = state.copyWith(
        isLoading: true,
        failure: null,
      );
    }

    final result = await _getUsersUseCase(
      page: state.currentPage,
      perPage: _perPage,
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
        );
      },
          (usersResponse) {
        final hasReachedMax = state.currentPage >= usersResponse.totalPages;

        state = state.copyWith(
          isLoading: false,
          users: refresh
              ? usersResponse.users
              : [...state.users, ...usersResponse.users],
          hasReachedMax: hasReachedMax,
          currentPage: state.currentPage + 1,
          totalPages: usersResponse.totalPages,
        );
      },
    );
  }

  void searchUsers(String query) {
    state = state.copyWith(
      searchQuery: query,
      isSearching: query.isNotEmpty,
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      isSearching: false,
    );
  }
}

// Providers
final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  // injection in app
  throw UnimplementedError();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final getUsersUseCase = ref.watch(getUsersUseCaseProvider);
  return UserNotifier(getUsersUseCase);
});