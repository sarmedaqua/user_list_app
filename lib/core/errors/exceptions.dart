
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}