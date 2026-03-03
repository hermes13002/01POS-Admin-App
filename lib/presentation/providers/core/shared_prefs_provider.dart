import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';

part 'shared_prefs_provider.g.dart';

/// Provider for SharedPrefsService instance
@riverpod
SharedPrefsService sharedPrefsService(SharedPrefsServiceRef ref) {
  return SharedPrefsService();
}
