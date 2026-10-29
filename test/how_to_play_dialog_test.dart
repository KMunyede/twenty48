import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twenty48/features/onboarding/how_to_play_dialog.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('HowToPlayDialog', () {
    testWidgets('shows 3 pages and Next then Got it closes dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const HowToPlayDialog()));
      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Swipe to slide'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to go to Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 2
      expect(find.text('Keep going'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to go to Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page 3
      expect(find.text('Helpers'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      // Tap Got it to close
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Dialog dismissed
      expect(find.text('Helpers'), findsNothing);
    });
  });
}
