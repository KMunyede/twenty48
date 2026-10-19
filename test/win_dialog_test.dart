import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/levels/level_service.dart';
import 'package:twenty48/features/game/ui/win_dialog.dart';

void main() {
  testWidgets('WinDialog shows actions at level 1', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'playerLevel': 1});
    final levelService = LevelService();
    await levelService.load();
    final gameProvider = GameProvider(levelService: levelService);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: const Scaffold(body: WinDialog()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level complete!'), findsOneWidget);
    expect(find.text('Next: Expert (2048)'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('WinDialog shows actions at level 3', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'playerLevel': 3});
    final levelService = LevelService();
    await levelService.load();
    final gameProvider = GameProvider(levelService: levelService);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: const Scaffold(body: WinDialog()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level complete!'), findsOneWidget);
    expect(find.text('You are a GrandMaster!'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
  });
}
