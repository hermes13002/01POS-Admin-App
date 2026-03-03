import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';

part 'dio_provider.g.dart';

/// Provider for DioClient instance
@riverpod
DioClient dioClient(DioClientRef ref) {
  return DioClient();
}
