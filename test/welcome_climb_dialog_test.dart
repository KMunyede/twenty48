import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twenty48/features/onboarding/welcome_climb_dialog.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => child,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('WelcomeClimbDialog Tests', () {
    testWidgets('shows the title, body, and Let\'s climb button, and button closes it',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const WelcomeClimbDialog()));
      await tester.pumpAndSettle();

      // Tap button to open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title, body, and button
      expect(find.text('Climb the ranks'), findsOneWidget);
      expect(
        find.text(
            'Merge tiles to reach 256 and earn your first title, Great Tactician. Then 512, 1024, 2048 and on, all the way to Walking Legend at 131,072. Every new tile earns a title. How high can you go?'),
        findsOneWidget,
      );
      expect(find.text("Let's climb"), findsOneWidget);

      // Tap "Let's climb" button to close
      await tester.tap(find.text("Let's climb"));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Climb the ranks'), findsNothing);
    });
  });
}
