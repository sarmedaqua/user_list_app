
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure() : super('No internet connection. Please check your connection and try again.');
}

class TimeoutFailure extends Failure {
  TimeoutFailure() : super('Request timed out. Please try again.');
}

class CacheFailure extends Failure {
  CacheFailure() : super('Cache error occurred.');
}