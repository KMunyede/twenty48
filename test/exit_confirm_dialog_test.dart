import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/features/game/ui/exit_confirm_dialog.dart';

void main() {
  testWidgets('ExitConfirmDialog shows Exit game?, Stay and Exit buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => const ExitConfirmDialog(),
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Exit game?'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
  });

  testWidgets('Stay button returns false', (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => const ExitConfirmDialog(),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();

    expect(result, false);
  });

  testWidgets('Exit button returns true', (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => const ExitConfirmDialog(),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(result, true);
  });
}
