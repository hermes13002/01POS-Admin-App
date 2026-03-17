import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/failures.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import '../datasources/sub_category_remote_datasource.dart';
import '../models/category_model.dart';

abstract class SubCategoryRepository {
  Future<Either<Failure, PaginatedSubCategoriesResponse>> getSubCategories({
    int page = 1,
  });
  Future<Either<Failure, SubCategoryModel>> createSubCategory({
    required int categoryId,
    required String name,
  });
  Future<Either<Failure, SubCategoryModel>> updateSubCategory(
    int id, {
    required int categoryId,
    required String name,
  });
  Future<Either<Failure, SubCategoryModel>> getSubCategoryDetails(int id);
  Future<Either<Failure, SubCategoryModel>> activateSubCategory(int id);
  Future<Either<Failure, SubCategoryModel>> deactivateSubCategory(int id);
  Future<Either<Failure, void>> deleteSubCategory(int id);
}

class SubCategoryRepositoryImpl implements SubCategoryRepository {
  final SubCategoryRemoteDatasource _remoteDatasource;

  SubCategoryRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, PaginatedSubCategoriesResponse>> getSubCategories({
    int page = 1,
  }) async {
    try {
      final result = await _remoteDatasource.fetchSubCategories(page: page);
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
  Future<Either<Failure, SubCategoryModel>> createSubCategory({
    required int categoryId,
    required String name,
  }) async {
    try {
      final result = await _remoteDatasource.storeSubCategory(
        categoryId: categoryId,
        name: name,
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
  Future<Either<Failure, SubCategoryModel>> getSubCategoryDetails(
    int id,
  ) async {
    try {
      final result = await _remoteDatasource.fetchSubCategoryDetails(id);
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
  Future<Either<Failure, SubCategoryModel>> updateSubCategory(
    int id, {
    required int categoryId,
    required String name,
  }) async {
    try {
      final result = await _remoteDatasource.updateSubCategory(
        id,
        categoryId: categoryId,
        name: name,
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
  Future<Either<Failure, SubCategoryModel>> activateSubCategory(int id) async {
    try {
      final result = await _remoteDatasource.activateSubCategory(id);
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
  Future<Either<Failure, SubCategoryModel>> deactivateSubCategory(
    int id,
  ) async {
    try {
      final result = await _remoteDatasource.deactivateSubCategory(id);
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
  Future<Either<Failure, void>> deleteSubCategory(int id) async {
    try {
      await _remoteDatasource.deleteSubCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
