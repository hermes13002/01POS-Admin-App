import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onepos_admin_app/core/utils/session_manager.dart';
import 'package:onepos_admin_app/presentation/widgets/update_dialog.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      'min_required_version_android': '1.0.0',
      'latest_version_android': '1.0.0',
      'min_required_version_ios': '1.0.0',
      'latest_version_ios': '1.0.0',
      'store_url':
          'https://play.google.com/store/apps/details?id=com.onepos.admin', // Android store url
      'ios_store_url':
          'https://apps.apple.com/app/id6784260341', // iOS store url
    });
  }

  Future<void> checkForUpdates() async {
    try {
      await _remoteConfig.fetchAndActivate();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = packageInfo.buildNumber;

      final isIOS = !kIsWeb && Platform.isIOS;
      final minRequiredVersion = _remoteConfig.getString(
        isIOS ? 'min_required_version_ios' : 'min_required_version_android',
      );
      final latestVersion = _remoteConfig.getString(
        isIOS ? 'latest_version_ios' : 'latest_version_android',
      );
      
      final storeUrl = isIOS
          ? _remoteConfig.getString('ios_store_url')
          : _remoteConfig.getString('store_url');

      if (_isVersionOlder(currentVersion, currentBuild, minRequiredVersion)) {
        _showUpdateDialog(isMandatory: true, storeUrl: storeUrl);
      } else if (_isVersionOlder(currentVersion, currentBuild, latestVersion)) {
        _showUpdateDialog(isMandatory: false, storeUrl: storeUrl);
      }
    } catch (e) {
      debugPrint('update check failed: $e');
    }
  }

  bool _isVersionOlder(String current, String currentBuild, String target) {
    try {
      // Split target into version and build if present (e.g., 1.1.0+6)
      final targetParts = target.split('+');
      final targetVersion = targetParts[0];
      final targetBuild = targetParts.length > 1
          ? int.tryParse(targetParts[1]) ?? 0
          : 0;

      final currentVersionParts = current
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final targetVersionParts = targetVersion
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      for (var i = 0; i < 3; i++) {
        final c = i < currentVersionParts.length ? currentVersionParts[i] : 0;
        final t = i < targetVersionParts.length ? targetVersionParts[i] : 0;
        if (t > c) return true;
        if (t < c) return false;
      }

      // If version names are equal, compare build numbers
      if (targetBuild > 0) {
        final cBuild = int.tryParse(currentBuild) ?? 0;
        if (targetBuild > cBuild) return true;
      }
    } catch (_) {}
    return false;
  }

  void _showUpdateDialog({
    required bool isMandatory,
    required String storeUrl,
  }) {
    final context = SessionManager.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) => UpdateDialog(
        isMandatory: isMandatory,
        onUpdate: () => _launchStore(storeUrl),
      ),
    );
  }

  Future<void> _launchStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
