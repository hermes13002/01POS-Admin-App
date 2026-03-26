import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:onepos_admin_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:onepos_admin_app/core/services/local_notification_service.dart';
import 'package:onepos_admin_app/core/storage/shared_prefs_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await SharedPrefsService().init();

      final localAuth = LocalNotificationService();
      await localAuth.init();

      if (task == BackgroundSyncService.checkLowStockTask) {
        log('Background task triggered: $task');

        final dio = DioClient();
        final remoteDatasource = ProductRemoteDatasource(dioClient: dio);
        final productRepo = ProductRepositoryImpl(
          remoteDatasource: remoteDatasource,
        );

        final response = await productRepo.fetchLowStockProducts();

        if (response.success && response.data != null) {
          final lowStockItems = response.data!;
          final count = lowStockItems.length;

          final prefs = SharedPrefsService();
          final lastCount = prefs.readInt('last_low_stock_count') ?? 0;

          if (count > 0 && count != lastCount) {
            await localAuth.showNotification(
              id: 100,
              title: 'Inventory Alert',
              body:
                  'You might be running low on some items, check your stock. ($count item(s) low)',
            );
            await prefs.writeInt('last_low_stock_count', count);
          }
        }
      }
      return Future.value(true);
    } catch (err) {
      log('Background task failed: $err');
      return Future.value(false);
    }
  });
}

class BackgroundSyncService {
  static const checkLowStockTask = "checkLowStockTask";

  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> registerPeriodicTasks() async {
    await Workmanager().registerPeriodicTask(
      "low_stock_bg_sync",
      checkLowStockTask,
      frequency: const Duration(hours: 12),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
