import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';

abstract class UsersRepository {
  /// fetches users for a given page
  Future<Either<Failure, PaginatedUsersResponse>> getUsers({int page = 1});

  /// activates a user by id
  Future<Either<Failure, UserModel>> activateUser(int userId);

  /// deactivates a user by id
  Future<Either<Failure, UserModel>> deactivateUser(int userId);

  /// fetches a single user by id
  Future<Either<Failure, UserModel>> getUser(int userId);

  /// deletes a user by id
  Future<Either<Failure, void>> deleteUser(int userId);
}
