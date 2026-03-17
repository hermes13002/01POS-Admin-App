import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/presentation/providers/core/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

part 'notifications_provider.g.dart';

@riverpod
NotificationRemoteDatasource notificationRemoteDatasource(Ref ref) {
  return NotificationRemoteDatasourceImpl(ref.watch(dioClientProvider));
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDatasourceProvider),
  );
}

/// state holder for notifications list with pagination info
class NotificationsState {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;

  const NotificationsState({
    this.notifications = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

@riverpod
class Notifications extends _$Notifications {
  NotificationRepository get _repo => ref.watch(notificationRepositoryProvider);

  @override
  Future<NotificationsState> build() async {
    return _fetchPage(1);
  }

  /// fetches a specific page and returns a fresh state
  Future<NotificationsState> _fetchPage(int page) async {
    final result = await _repo.getNotifications(page: page);
    return result.fold((failure) => throw failure, (response) {
      final data = response.data;
      if (data == null) {
        return const NotificationsState(hasMorePages: false);
      }
      return NotificationsState(
        notifications: data.notifications,
        currentPage: data.currentPage,
        lastPage: data.lastPage,
        hasMorePages: data.hasMorePages,
      );
    });
  }

  /// loads the next page and appends notifications to the existing list
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getNotifications(page: nextPage);

    result.fold(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (response) {
        final data = response.data;
        if (data != null) {
          state = AsyncData(
            current.copyWith(
              notifications: [...current.notifications, ...data.notifications],
              currentPage: data.currentPage,
              lastPage: data.lastPage,
              hasMorePages: data.hasMorePages,
              isLoadingMore: false,
            ),
          );
        } else {
          state = AsyncData(current.copyWith(isLoadingMore: false));
        }
      },
    );
  }

  /// refreshes from page 1
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  /// marks a notification as read and updates local state
  Future<void> markAsRead(int id) async {
    final result = await _repo.markAsRead(id);
    result.fold(
      (failure) => null, // silenty fail or handle as needed
      (_) {
        final current = state.valueOrNull;
        if (current != null) {
          final updatedList = current.notifications.map((n) {
            if (n.id == id) {
              return n.copyWithRead(1);
            }
            return n;
          }).toList();
          state = AsyncData(current.copyWith(notifications: updatedList));
        }
      },
    );
  }

  /// deletes a single notification and updates local state
  Future<String?> deleteNotification(int id) async {
    final result = await _repo.deleteNotification(id);
    return result.fold((failure) => failure.message, (_) {
      final current = state.valueOrNull;
      if (current != null) {
        final updatedList = current.notifications
            .where((n) => n.id != id)
            .toList();
        state = AsyncData(current.copyWith(notifications: updatedList));
      }
      return null;
    });
  }

  /// deletes all read notifications and updates local state
  Future<String?> deleteAllReadNotifications() async {
    final result = await _repo.deleteAllReadNotifications();
    return result.fold((failure) => failure.message, (_) {
      final current = state.valueOrNull;
      if (current != null) {
        final updatedList = current.notifications
            .where((n) => n.read == 0)
            .toList();
        state = AsyncData(current.copyWith(notifications: updatedList));
      }
      return null;
    });
  }
}

@riverpod
Future<NotificationDetailModel> notificationDetail(Ref ref, int id) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final result = await repo.getNotificationDetail(id);
  return result.fold((failure) => throw failure, (response) => response.data!);
}

@riverpod
int unreadNotificationsCount(UnreadNotificationsCountRef ref) {
  final notificationsState = ref.watch(notificationsProvider);
  return notificationsState.maybeWhen(
    data: (state) => state.notifications.where((n) => n.read == 0).length,
    orElse: () => 0,
  );
}
