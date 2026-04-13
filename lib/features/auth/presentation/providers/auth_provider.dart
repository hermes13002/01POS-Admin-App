import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/features/chats/presentation/providers/chat_provider.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/users_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/login_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    AuthRemoteDatasourceImpl(DioClient(), SecureStorageService()),
  );
}

/// holds the current logged-in session
@riverpod
class Auth extends _$Auth {
  @override
  AsyncValue<LoginResponseModel?> build() => const AsyncData(null);

  AuthRepositoryImpl get _repo => AuthRepositoryImpl(
    AuthRemoteDatasourceImpl(DioClient(), SecureStorageService()),
  );

  Future<String?> loginWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await _repo.loginWithEmail(email, password);
    return result.fold(
      (failure) {
        state = const AsyncData(null);
        return failure.message;
      },
      (data) async {
        // Save password for profile update autofill
        await SecureStorageService().write('user_password', password);
        // Save email for next login
        await SharedPrefsService().writeString('last_login_email', email);

        // Trigger immediate fetch of chat data
        ref.invalidate(chatContactsProvider);

        state = AsyncData(data);
        return null;
      },
    );
  }

  Future<String?> loginWithPin(String pin) async {
    state = const AsyncLoading();
    final result = await _repo.loginWithPin(pin);
    return result.fold(
      (failure) {
        state = const AsyncData(null);
        return failure.message;
      },
      (data) {
        // Trigger immediate fetch of chat data
        ref.invalidate(chatContactsProvider);

        state = AsyncData(data);
        return null;
      },
    );
  }

  Future<void> logout() async {
    // call logout api — ignore errors so we always clear local tokens
    try {
      await _repo.logout();
    } catch (_) {}
    await SecureStorageService().deleteAll();

    // invalidate all keepAlive data providers so stale data is cleared
    ref.invalidate(allUsersProvider);
    ref.invalidate(userProfileProvider);

    state = const AsyncData(null);
  }

  Future<String?> resetPassword(String email) async {
    final result = await _repo.resetPassword(email);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<String?> signUp(Map<String, dynamic> body) async {
    state = const AsyncLoading();
    final result = await _repo.signUp(body);
    state = const AsyncData(null);
    return result.fold((failure) => failure.message, (_) => null);
  }
}
