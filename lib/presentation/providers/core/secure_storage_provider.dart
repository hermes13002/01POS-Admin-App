import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/storage/secure_storage_service.dart';

part 'secure_storage_provider.g.dart';

/// Provider for SecureStorageService instance
@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService();
}
