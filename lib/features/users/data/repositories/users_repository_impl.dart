import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/users/data/datasources/users_remote_datasource.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDatasource _datasource;

  UsersRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedUsersResponse>> getUsers(
      {int page = 1}) async {
    try {
      final result = await _datasource.getUsers(page: page);
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> activateUser(int userId) async {
    try {
      final result = await _datasource.activateUser(userId);
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> deactivateUser(int userId) async {
    try {
      final result = await _datasource.deactivateUser(userId);
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUser(int userId) async {
    try {
      final result = await _datasource.getUser(userId);
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await _datasource.deleteUser(userId);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
