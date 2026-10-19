// lib/core/services/ump_consent_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// EEA Consent Testing guide:
/// flutter run --dart-define=UMP_DEBUG_EEA=true --dart-define=UMP_TEST_ID=(hash from logcat)

class UmpConsentService {
  final Duration timeoutDuration;

  const UmpConsentService({Duration? timeoutDuration})
      : timeoutDuration = timeoutDuration ?? const Duration(seconds: 10);

  Future<bool> gatherConsent() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    try {
      final debugSettings = (kDebugMode &&
              const String.fromEnvironment('UMP_DEBUG_EEA') == 'true')
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: [
                const String.fromEnvironment('UMP_TEST_ID')
              ].where((id) => id.isNotEmpty).toList(),
            )
          : null;

      final params = ConsentRequestParameters(
        consentDebugSettings: debugSettings,
      );

      final updateCompleter = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () => updateCompleter.complete(),
        (error) => updateCompleter.completeError(error),
      );
      await updateCompleter.future.timeout(timeoutDuration);

      final formCompleter = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
        if (formError != null) {
          formCompleter.completeError(formError);
        } else {
          formCompleter.complete();
        }
      }).timeout(timeoutDuration);

      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      try {
        return await ConsentInformation.instance.canRequestAds();
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> privacyOptionsRequired() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      return false;
    }
  }

  Future<void> showPrivacyOptions() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    try {
      await ConsentForm.showPrivacyOptionsForm((FormError? error) {});
    } catch (e) {}
  }
}
