import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/levels/level_service.dart';

void main() {
  group('LevelService Tests', () {
    test('default level is 1 when preference is missing', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LevelService();
      await service.load();
      expect(service.currentLevel, equals(1));
    });

    test('saveLevel and load persists and clamps level', () async {
      SharedPreferences.setMockInitialValues({});
      final service = LevelService();
      await service.load();
      expect(service.currentLevel, equals(1));

      await service.saveLevel(2);
      expect(service.currentLevel, equals(2));

      // Test bad/out of range values clamp
      await service.saveLevel(99);
      expect(service.currentLevel, equals(3));

      await service.saveLevel(-5);
      expect(service.currentLevel, equals(1));
    });
  });
}
