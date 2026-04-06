import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/broadcasts/data/datasources/broadcast_remote_datasource.dart';
import 'package:onepos_admin_app/features/broadcasts/data/models/broadcast_model.dart';
import 'package:onepos_admin_app/features/broadcasts/data/repositories/broadcast_repository_impl.dart';
import 'package:onepos_admin_app/features/broadcasts/domain/repositories/broadcast_repository.dart';

class BroadcastNotifier extends AsyncNotifier<List<BroadcastModel>> {
  BroadcastRepository get _repo =>
      BroadcastRepositoryImpl(BroadcastRemoteDatasourceImpl(DioClient()));

  @override
  Future<List<BroadcastModel>> build() async {
    return _fetchHistory();
  }

  Future<List<BroadcastModel>> _fetchHistory() async {
    final result = await _repo.getBroadcastHistory();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (history) => history,
    );
  }

  Future<void> refreshHistory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHistory());
  }

  Future<String?> sendBroadcast(Map<String, dynamic> body) async {
    final result = await _repo.sendBroadcast(body);
    return result.fold((failure) => failure.message, (_) {
      refreshHistory();
      return null;
    });
  }
}

final broadcastProvider =
    AsyncNotifierProvider<BroadcastNotifier, List<BroadcastModel>>(
      BroadcastNotifier.new,
    );
