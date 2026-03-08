import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';
import 'package:onepos_admin_app/core/constants/app_constants.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/login_response_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

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
      (data) {
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
        state = AsyncData(data);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await SecureStorageService().delete(AppConstants.keyAccessToken);
    await SecureStorageService().delete(AppConstants.keyUserId);
    state = const AsyncData(null);
  }
}
