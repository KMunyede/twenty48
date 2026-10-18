import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UpdateCheckResult { latest, downloading, notSupported }

class UpdateService {
  static const String _lastCheckKey = 'update_last_check_ms';
  static const int _throttleDurationMs = 24 * 60 * 60 * 1000; // 24 hours

  Future<void> checkOnLaunch() async {
    if (!Platform.isAndroid || !kReleaseMode) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastCheck < _throttleDurationMs) {
        return;
      }

      await prefs.setInt(_lastCheckKey, now);

      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('UpdateService checkOnLaunch error: $e');
    }
  }

  Future<UpdateCheckResult> checkNow() async {
    if (!Platform.isAndroid) {
      return UpdateCheckResult.notSupported;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        try {
          await InAppUpdate.completeFlexibleUpdate();
        } catch (_) {}
        return UpdateCheckResult.downloading;
      } else {
        return UpdateCheckResult.latest;
      }
    } catch (e) {
      debugPrint('UpdateService checkNow error: $e');
      return UpdateCheckResult.latest;
    }
  }
}
