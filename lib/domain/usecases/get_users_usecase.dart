import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  Future<Either<Failure, UsersResponseModel>> call({required int page, required int perPage}) {
    return repository.getUsers(page: page, perPage: perPage);
  }
}