import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<Either<Failure, PaginatedCategoriesResponse>> getCategories({
    int page = 1,
  });
  Future<Either<Failure, CategoryModel>> getCategoryDetails(int id);
  Future<Either<Failure, CategoryModel>> updateCategory(
    int id, {
    required String name,
    required String description,
  });
  Future<Either<Failure, CategoryModel>> createCategory({
    required String name,
    required String description,
  });
  Future<Either<Failure, void>> deleteCategory(int id);
  Future<Either<Failure, CategoryModel>> activateCategory(int id);
  Future<Either<Failure, CategoryModel>> deactivateCategory(int id);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource _remoteDatasource;

  CategoryRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, PaginatedCategoriesResponse>> getCategories({
    int page = 1,
  }) async {
    try {
      final result = await _remoteDatasource.fetchCategories(page: page);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> getCategoryDetails(int id) async {
    try {
      final result = await _remoteDatasource.fetchCategoryDetails(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> updateCategory(
    int id, {
    required String name,
    required String description,
  }) async {
    try {
      final result = await _remoteDatasource.updateCategory(
        id,
        name: name,
        description: description,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> createCategory({
    required String name,
    required String description,
  }) async {
    try {
      final result = await _remoteDatasource.storeCategory(
        name: name,
        description: description,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      await _remoteDatasource.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> activateCategory(int id) async {
    try {
      final result = await _remoteDatasource.activateCategory(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> deactivateCategory(int id) async {
    try {
      final result = await _remoteDatasource.deactivateCategory(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
