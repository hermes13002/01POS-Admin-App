import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/reports_model.dart';

class ReportCacheService {
  static const String _boxName = 'reports_cache';
  static const String _reportsKey = 'latest_reports';
  static const String _lastUpdateKey = 'last_update_time';

  /// saves reports data to local cache
  Future<void> cacheReports(ReportsData data) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_reportsKey, jsonEncode(data.toJson()));
    await box.put(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// retrieves reports data from local cache
  Future<ReportsData?> getCachedReports() async {
    final box = await Hive.openBox(_boxName);
    final String? jsonData = box.get(_reportsKey);

    if (jsonData == null) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(jsonData);
      return ReportsData.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// checks if the cache is older than 1 hour
  Future<bool> isCacheStale() async {
    final lastUpdate = await getLastUpdateTime();
    if (lastUpdate == null) return true;

    final difference = DateTime.now().difference(lastUpdate);
    return difference.inHours >= 1;
  }

  /// returns the last time the cache was updated
  Future<DateTime?> getLastUpdateTime() async {
    final box = await Hive.openBox(_boxName);
    final int? timestamp = box.get(_lastUpdateKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// clears the local cache
  Future<void> clearCache() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
