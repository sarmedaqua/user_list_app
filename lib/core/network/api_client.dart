
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options.baseUrl = 'https://reqres.in/api/';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException(e.message ?? 'Unknown error occurred');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NoConnectionException(e.message ?? 'No internet connection');
      } else {
        throw ServerException(e.message ?? 'Unknown error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}