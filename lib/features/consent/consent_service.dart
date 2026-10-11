// lib/features/consent/consent_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'consent_texts.dart';

enum ConsentStatus {
  needsPrompt,
  agreed,
  declined,
}

typedef SharedPreferencesGetter = Future<SharedPreferences> Function();

class ConsentService {
  final SharedPreferencesGetter _prefsGetter;

  ConsentService({SharedPreferencesGetter? prefsGetter})
      : _prefsGetter = prefsGetter ?? SharedPreferences.getInstance;

  static const String keyConsentVersion = 'consentVersion';
  static const String keyConsentDecision = 'consentDecision';

  Future<ConsentStatus> load() async {
    try {
      final prefs = await _prefsGetter();
      final version = prefs.getInt(keyConsentVersion);
      if (version == null || version != kConsentVersion) {
        return ConsentStatus.needsPrompt;
      }
      final decision = prefs.getString(keyConsentDecision);
      if (decision == 'agree') {
        return ConsentStatus.agreed;
      } else if (decision == 'decline') {
        return ConsentStatus.declined;
      } else {
        return ConsentStatus.needsPrompt;
      }
    } catch (e) {
      debugPrint('ConsentService load error: $e');
      return ConsentStatus.needsPrompt;
    }
  }

  Future<void> save(bool agreed) async {
    try {
      final prefs = await _prefsGetter();
      await prefs.setInt(keyConsentVersion, kConsentVersion);
      await prefs.setString(
        keyConsentDecision,
        agreed ? 'agree' : 'decline',
      );
    } catch (e) {
      debugPrint('ConsentService save error: $e');
    }
  }
}
