// test/consent_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/consent/consent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConsentService Tests', () {
    test('empty storage returns needsPrompt', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ConsentService();
      final status = await service.load();
      expect(status, ConsentStatus.needsPrompt);
    });

    test('save(true) then load returns agreed', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ConsentService();
      await service.save(true);
      final status = await service.load();
      expect(status, ConsentStatus.agreed);
    });

    test('save(false) then load returns declined', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ConsentService();
      await service.save(false);
      final status = await service.load();
      expect(status, ConsentStatus.declined);
    });

    test('an older saved version returns needsPrompt', () async {
      SharedPreferences.setMockInitialValues({
        'consentVersion': 0,
        'consentDecision': 'agree',
      });
      final service = ConsentService();
      final status = await service.load();
      expect(status, ConsentStatus.needsPrompt);
    });
  });
}
