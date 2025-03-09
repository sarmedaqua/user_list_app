
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';

abstract class UserRemoteDataSource {
  Future<UsersResponseModel> getUsers({required int page, required int perPage});
}

// Implementation of UserRemoteDataSource using ApiClient
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UsersResponseModel> getUsers({required int page, required int perPage}) async {
    final response = await apiClient.get(
      'users',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    if (response.statusCode == 200) {
      return UsersResponseModel.fromJson(response.data);
    } else {
      throw ServerException('Failed to load users: ${response.statusCode}');
    }
  }
}