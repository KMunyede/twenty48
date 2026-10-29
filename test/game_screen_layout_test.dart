import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/ui/game_screen.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

void main() {
  group('GameScreen Layout Tests', () {
    final testSizes = [
      const Size(360, 640),
      const Size(411, 891),
      const Size(412, 915),
      const Size(800, 1280),
    ];

    for (final size in testSizes) {
      testWidgets('Pump GameScreen at ${size.width}x${size.height} portrait has no overflow and contains Help pill and GOAL text', (WidgetTester tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => GameProvider()),
            ],
            child: const MaterialApp(
              home: GameScreen(),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Help'), findsOneWidget);
        expect(find.textContaining('NEXT'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
