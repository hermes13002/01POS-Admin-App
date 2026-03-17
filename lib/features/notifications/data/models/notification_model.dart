import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/data/models/base_model.dart';

/// model for a notification detail
class NotificationDetailModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final int read;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;

  const NotificationDetailModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory NotificationDetailModel.fromJson(Map<String, dynamic> json) {
    return NotificationDetailModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] is int
          ? json['read']
          : int.tryParse(json['read'].toString()) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'read': read,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
    };
  }

  NotificationDetailModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    int? read,
    String? createdAt,
    String? updatedAt,
    UserModel? user,
  }) {
    return NotificationDetailModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

/// model for a user's notification link (pivot)
class NotificationModel extends BaseModel {
  final int id;
  final int read;
  final int deleted;
  final int userId;
  final int notificationId;
  final String createdAt;
  final String updatedAt;
  final NotificationDetailModel? notification;

  NotificationModel({
    required this.id,
    required this.read,
    required this.deleted,
    required this.userId,
    required this.notificationId,
    required this.createdAt,
    required this.updatedAt,
    this.notification,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      read: json['read'] is int
          ? json['read']
          : int.tryParse(json['read'].toString()) ?? 0,
      deleted: json['deleted'] is int
          ? json['deleted']
          : int.tryParse(json['deleted'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      notificationId: json['notification_id'] is int
          ? json['notification_id']
          : int.tryParse(json['notification_id'].toString()) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      notification: json['notification'] != null
          ? NotificationDetailModel.fromJson(json['notification'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'read': read,
      'deleted': deleted,
      'user_id': userId,
      'notification_id': notificationId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'notification': notification?.toJson(),
    };
  }

  NotificationModel copyWith({
    int? id,
    int? read,
    int? deleted,
    int? userId,
    int? notificationId,
    String? createdAt,
    String? updatedAt,
    NotificationDetailModel? notification,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      read: read ?? this.read,
      deleted: deleted ?? this.deleted,
      userId: userId ?? this.userId,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notification: notification ?? this.notification,
    );
  }

  NotificationModel copyWithRead(int read) {
    return copyWith(read: read);
  }
}

/// paginated response wrapper for notifications
class PaginatedNotificationsResponse {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  const PaginatedNotificationsResponse({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginatedNotificationsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];

    final currentPage = json['current_page'] is int
        ? json['current_page']
        : int.tryParse(json['current_page'].toString()) ?? 1;
    final lastPage = json['last_page'] is int
        ? json['last_page']
        : int.tryParse(json['last_page'].toString()) ?? 1;
    final perPage = json['per_page'] is int
        ? json['per_page']
        : int.tryParse(json['per_page'].toString()) ?? 10;
    final total = json['total'] is int
        ? json['total']
        : int.tryParse(json['total'].toString()) ?? 0;

    return PaginatedNotificationsResponse(
      notifications: list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMorePages: currentPage < lastPage,
    );
  }
}
