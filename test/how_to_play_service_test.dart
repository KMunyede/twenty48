import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/onboarding/how_to_play_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HowToPlayService', () {
    test('hasSeen returns false initially and true after markSeen', () async {
      final service = HowToPlayService();
      expect(await service.hasSeen(), isFalse);

      await service.markSeen();
      expect(await service.hasSeen(), isTrue);

      final service2 = HowToPlayService();
      expect(await service2.hasSeen(), isTrue);
    });
  });
}
