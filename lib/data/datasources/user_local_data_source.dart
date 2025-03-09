import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUsers(UsersResponseModel usersResponse, int page);
  Future<UsersResponseModel?> getCachedUsers(int page);
}

// Implementation of [UserLocalDataSource] using SharedPreferences.
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUsers(UsersResponseModel usersResponse, int page) async {
    await sharedPreferences.setString(
      'CACHED_USERS_PAGE_$page',
      jsonEncode(usersResponse.toJson()),
    );
  }

  @override
  Future<UsersResponseModel?> getCachedUsers(int page) async {
    final jsonString = sharedPreferences.getString('CACHED_USERS_PAGE_$page');

    if (jsonString != null) {
      return UsersResponseModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }
}

// Add toJson method to UsersResponseModel
extension UserResponseModelExtension on UsersResponseModel {
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'data': users.map((user) => user.toJson()).toList(),
    };
  }
}