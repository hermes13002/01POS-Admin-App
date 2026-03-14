import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/users/data/datasources/users_remote_datasource.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/features/users/data/repositories/users_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_provider.g.dart';

/// manages paginated users state
@Riverpod(keepAlive: true)
class AllUsers extends _$AllUsers {
  UsersRepositoryImpl get _repo => UsersRepositoryImpl(
        UsersRemoteDatasourceImpl(DioClient()),
      );

  @override
  Future<UsersState> build() async {
    return _fetchPage(1);
  }

  /// fetches a specific page and returns a fresh state
  Future<UsersState> _fetchPage(int page) async {
    final result = await _repo.getUsers(page: page);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) => UsersState(
        users: response.users,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        hasMorePages: response.hasMorePages,
      ),
    );
  }

  /// creates a user and prepends it to the local list
  /// returns null on success, or an error message on failure
  Future<String?> createUser(Map<String, dynamic> body) async {
    final result = await _repo.createUser(body);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    final createdUser = result.getOrElse(
      () => throw Exception('Failed to parse created user'),
    );

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(users: [createdUser, ...current.users]));
    }

    return null;
  }

  /// loads the next page and appends users to the existing list
  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMorePages || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getUsers(page: nextPage);

    result.fold(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (response) {
        state = AsyncData(
          current.copyWith(
            users: [...current.users, ...response.users],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            hasMorePages: response.hasMorePages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// toggles user active status and updates the user in the list
  /// returns null on success, or an error message on failure
  Future<String?> toggleUserStatus(int userId, {required bool activate}) async {
    final current = state.valueOrNull;
    if (current == null) return 'Users not loaded';

    // call activate or deactivate endpoint
    final toggleResult = activate
        ? await _repo.activateUser(userId)
        : await _repo.deactivateUser(userId);

    if (toggleResult.isLeft()) {
      return toggleResult.fold((f) => f.message, (_) => '');
    }

    // fetch fresh user data from show endpoint
    final userResult = await _repo.getUser(userId);
    userResult.fold(
      (_) {},
      (updatedUser) {
        final updatedList = current.users.map((u) {
          return u.id == userId ? updatedUser : u;
        }).toList();
        state = AsyncData(current.copyWith(users: updatedList));
      },
    );
    return null;
  }

  /// deletes a user and removes them from the local list
  /// returns null on success, or an error message on failure
  Future<String?> deleteUser(int userId) async {
    final current = state.valueOrNull;
    if (current == null) return 'Users not loaded';

    final result = await _repo.deleteUser(userId);

    if (result.isLeft()) {
      return result.fold((f) => f.message, (_) => '');
    }

    // remove user from local list
    final updatedList = current.users.where((u) => u.id != userId).toList();
    state = AsyncData(current.copyWith(users: updatedList));
    return null;
  }

  /// refreshes from page 1
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}
