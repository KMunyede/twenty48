import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/ui/game_screen.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

void main() {
  testWidgets('2048 game screen test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    expect(find.text('SCORE'), findsOneWidget);
  });
}
