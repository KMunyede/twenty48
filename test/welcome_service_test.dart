import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/welcome_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WelcomeService Tests', () {
    test('default is false; markSeen persists true', () async {
      SharedPreferences.setMockInitialValues({});
      final service = WelcomeService();

      expect(await service.seen, isFalse);

      await service.markSeen();

      expect(await service.seen, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('welcome_climb_seen_v1'), isTrue);
    });
  });
}
