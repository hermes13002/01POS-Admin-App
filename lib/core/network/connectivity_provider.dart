import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:onepos_admin_app/core/network/connectivity_service.dart';

part 'connectivity_provider.g.dart';

/// watches connectivity and emits true = online, false = offline
@riverpod
Stream<bool> connectivity(Ref ref) {
  final service = ConnectivityService();
  return service.onConnectivityChanged;
}

/// one-shot check — used before making a request
@riverpod
Future<bool> isConnected(Ref ref) async {
  return ConnectivityService().isConnected;
}
