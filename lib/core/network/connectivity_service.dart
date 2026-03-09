import 'package:connectivity_plus/connectivity_plus.dart';

/// service for checking and watching network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// returns true if currently connected to any network
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// stream that emits true when online, false when offline
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
