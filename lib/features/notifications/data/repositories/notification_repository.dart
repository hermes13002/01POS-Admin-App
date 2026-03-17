import 'package:dartz/dartz.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<AppException, ApiResponse<PaginatedNotificationsResponse>>>
  getNotifications({int page = 1});

  Future<Either<AppException, ApiResponse<NotificationDetailModel>>>
  getNotificationDetail(int id);

  Future<Either<AppException, ApiResponse<void>>> markAsRead(int id);
  Future<Either<AppException, ApiResponse<void>>> deleteNotification(int id);
  Future<Either<AppException, ApiResponse<void>>> deleteAllReadNotifications();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<AppException, ApiResponse<PaginatedNotificationsResponse>>>
  getNotifications({int page = 1}) async {
    try {
      final response = await _remoteDatasource.fetchNotifications(page: page);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<NotificationDetailModel>>>
  getNotificationDetail(int id) async {
    try {
      final response = await _remoteDatasource.fetchNotificationDetail(id);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<void>>> markAsRead(int id) async {
    try {
      final response = await _remoteDatasource.markAsRead(id);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<void>>> deleteNotification(
    int id,
  ) async {
    try {
      final response = await _remoteDatasource.deleteNotification(id);
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<AppException, ApiResponse<void>>>
  deleteAllReadNotifications() async {
    try {
      final response = await _remoteDatasource.deleteAllReadNotifications();
      return Right(response);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
