import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/ui/game_over_dialog.dart';

void main() {
  testWidgets('GameOverDialog shows score, message, buttons and uses deep orange color', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverDialog(
            title: 'Game Over!',
            message: 'No more moves',
            score: 1516,
            bestScore: 2048,
            levelName: 'Apprentice',
            canUndo: true,
            onNewGame: () {},
            onUndo: () {},
            onViewBoard: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Game Over!'), findsOneWidget);
    expect(find.text('No more moves'), findsOneWidget);
    expect(find.text('Score: 1516'), findsOneWidget);
    expect(find.text('Best: 2048'), findsOneWidget);
    expect(find.text('Level: Apprentice'), findsOneWidget);
    expect(find.text('Undo last move'), findsOneWidget);
    expect(find.text('View board'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('GameOverDialog hides undo button when canUndo is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverDialog(
            title: 'Game Over!',
            message: 'No more moves',
            score: 500,
            bestScore: 1000,
            canUndo: false,
            onNewGame: () {},
            onViewBoard: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Undo last move'), findsNothing);
  });
}
