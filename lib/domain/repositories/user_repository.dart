import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UsersResponseModel>> getUsers({required int page, required int perPage});
}