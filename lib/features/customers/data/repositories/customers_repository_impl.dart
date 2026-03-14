import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/features/customers/data/datasources/customers_remote_datasource.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';
import 'package:onepos_admin_app/features/customers/domain/repositories/customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDatasource _datasource;

  CustomersRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PaginatedCustomersResponse>> getCustomers({int page = 1}) async {
    try {
      final result = await _datasource.getCustomers(page: page);
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
  Future<Either<Failure, CustomerModel>> getCustomer(int customerId) async {
    try {
      final result = await _datasource.getCustomer(customerId);
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
  Future<Either<Failure, CustomerModel>> createCustomer(
    Map<String, dynamic> body,
  ) async {
    try {
      final result = await _datasource.createCustomer(body);
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
  Future<Either<Failure, CustomerModel>> updateCustomer(
    int customerId,
    Map<String, dynamic> body,
  ) async {
    try {
      final result = await _datasource.updateCustomer(customerId, body);
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
  Future<Either<Failure, void>> deleteCustomer(int customerId) async {
    try {
      await _datasource.deleteCustomer(customerId);
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
