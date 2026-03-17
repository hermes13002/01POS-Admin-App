import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart'
    show AppException, ServerException;
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_metadata_model.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<Either<AppException, ApiResponse<List<ExpenseModel>>>> getExpenses({
    int page = 1,
    String? search,
  });

  Future<Either<AppException, ApiResponse<ExpenseModel>>> createExpense(
    Map<String, dynamic> body,
  );

  Future<Either<AppException, ApiResponse<ExpenseModel>>> updateExpense(
    int id,
    Map<String, dynamic> body,
  );

  Future<Either<AppException, ApiResponse<ExpenseMetadataModel>>>
  fetchMetadata();

  Future<Either<AppException, ApiResponse<void>>> deleteExpense(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource _remoteDatasource;

  ExpenseRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<AppException, ApiResponse<ExpenseModel>>> createExpense(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _remoteDatasource.createExpense(body);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<ExpenseModel>>> updateExpense(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _remoteDatasource.updateExpense(id, body);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<ExpenseMetadataModel>>>
  fetchMetadata() async {
    try {
      final response = await _remoteDatasource.fetchMetadata();
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<void>>> deleteExpense(int id) async {
    try {
      final response = await _remoteDatasource.deleteExpense(id);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<List<ExpenseModel>>>> getExpenses({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await _remoteDatasource.fetchExpenses(
        page: page,
        search: search,
      );
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
