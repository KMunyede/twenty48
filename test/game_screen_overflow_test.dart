import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twenty48/features/game/providers/game_provider.dart';
import 'package:twenty48/features/game/ui/game_screen.dart';
import 'package:twenty48/features/game/ui/widgets/tile_widget.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

void main() {
  group('GameScreen Overflow & Scaling Tests (T48-88C)', () {
    final sizes = [
      const _TestDevice(size: Size(360, 640), dpr: 2.0),
      const _TestDevice(size: Size(384, 832), dpr: 2.8125, topInset: 37.7, bottomInset: 22.4),
      const _TestDevice(size: Size(411, 891), dpr: 2.0),
      const _TestDevice(size: Size(412, 915), dpr: 2.0),
      const _TestDevice(size: Size(800, 1280), dpr: 2.0),
    ];

    final adHeights = [0.0, 50.0, 60.0, 90.0, 120.0];

    for (final dev in sizes) {
      for (final swapOn in [false, true]) {
        for (final adDp in adHeights) {
          testWidgets(
            'No overflow at ${dev.size.width.toInt()}x${dev.size.height.toInt()} swap=$swapOn ad=${adDp.toInt()}dp',
            (WidgetTester tester) async {
              tester.view.physicalSize = Size(dev.size.width * dev.dpr, dev.size.height * dev.dpr);
              tester.view.devicePixelRatio = dev.dpr;
              tester.view.padding = FakeViewPadding(
                top: dev.topInset * dev.dpr,
                bottom: dev.bottomInset * dev.dpr,
              );
              addTearDown(() {
                tester.view.resetPhysicalSize();
                tester.view.resetDevicePixelRatio();
                tester.view.resetPadding();
              });

              final game = GameProvider();
              game.initGame();
              if (swapOn) {
                game.toggleSwapMode();
              }

              await tester.pumpWidget(
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => ThemeProvider()),
                    ChangeNotifierProvider.value(value: game),
                  ],
                  child: MaterialApp(
                    home: GameScreen(
                      adSlotBuilder: (context) => SizedBox(height: adDp, width: double.infinity),
                    ),
                  ),
                ),
              );

              await tester.pump();
              await tester.pump(const Duration(milliseconds: 300));

              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }

    testWidgets('Board scale check: 412x915 swap OFF ad 50dp vs 384x832 swap ON ad 90dp', (WidgetTester tester) async {
      // 1. 412x915 with Swap OFF and 50 dp ad -> Board is NOT scaled
      tester.view.physicalSize = const Size(412 * 2.0, 915 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      final game1 = GameProvider();
      game1.initGame();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: game1),
          ],
          child: MaterialApp(
            home: GameScreen(
              adSlotBuilder: (context) => const SizedBox(height: 50, width: double.infinity),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final fixedSize412 = 412.0 - 32.0;
      final boardFinder412 = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == fixedSize412 && w.height == fixedSize412,
      ).last;

      final renderedRect412 = tester.getRect(boardFinder412);
      final scale412 = renderedRect412.width / fixedSize412;
      expect((scale412 - 1.0).abs(), lessThan(0.001), reason: '412x915 board should not be scaled');

      // 2. 384x832 with Swap ON and 90 dp ad -> Board IS scaled and scale >= 0.85
      tester.view.physicalSize = const Size(384 * 2.8125, 832 * 2.8125);
      tester.view.devicePixelRatio = 2.8125;
      tester.view.padding = const FakeViewPadding(
        top: 37.7 * 2.8125,
        bottom: 22.4 * 2.8125,
      );

      final game2 = GameProvider();
      game2.initGame();
      game2.toggleSwapMode();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: game2),
          ],
          child: MaterialApp(
            home: GameScreen(
              adSlotBuilder: (context) => const SizedBox(height: 90, width: double.infinity),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final fixedSize384 = 384.0 - 32.0;
      final boardFinder384 = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == fixedSize384 && w.height == fixedSize384,
      ).last;

      final renderedRect384 = tester.getRect(boardFinder384);
      final scale384 = renderedRect384.width / fixedSize384;

      debugPrint('SCALE_RESULT: 412x915_swap_off_ad50=$scale412, 384x832_swap_on_ad90=$scale384');

      expect(scale384, lessThan(1.0 - 0.001), reason: '384x832 board should be scaled down');
      expect(scale384, greaterThanOrEqualTo(0.85), reason: '384x832 board scale should be at least 0.85');
    });

    testWidgets('Gesture checks on scaled board: drag produces move, tap selects tile in Swap mode', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(384 * 2.8125, 832 * 2.8125);
      tester.view.devicePixelRatio = 2.8125;
      tester.view.padding = const FakeViewPadding(
        top: 37.7 * 2.8125,
        bottom: 22.4 * 2.8125,
      );
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPadding();
      });

      // Part A: Drag gesture on scaled board with Swap OFF
      final gameDrag = GameProvider();
      gameDrag.initGame();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: gameDrag),
          ],
          child: MaterialApp(
            home: GameScreen(
              adSlotBuilder: (context) => const SizedBox(height: 90, width: double.infinity),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final initialMoves = gameDrag.moveCount;

      // Drag across board
      final fixedSize384 = 384.0 - 32.0;
      final boardFinder = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == fixedSize384 && w.height == fixedSize384,
      ).last;
      final boardCenter = tester.getCenter(boardFinder);

      await tester.dragFrom(boardCenter, const Offset(-150, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(gameDrag.moveCount, greaterThan(initialMoves), reason: 'Drag on scaled board produced moveCount > initialMoves');

      // Part B: Swap mode tile selection tap on scaled board
      final gameSwap = GameProvider();
      gameSwap.initGame();
      gameSwap.toggleSwapMode();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: gameSwap),
          ],
          child: MaterialApp(
            home: GameScreen(
              adSlotBuilder: (context) => const SizedBox(height: 90, width: double.infinity),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(gameSwap.isSwapMode, isTrue);
      expect(gameSwap.firstSelectedTile, isNull);

      final tileFinder = find.byType(TileWidget).first;
      await tester.tap(tileFinder, warnIfMissed: false);
      await tester.pump();

      expect(gameSwap.firstSelectedTile, isNotNull, reason: 'Tap on tile in Swap mode selected a tile');
    });
  });
}

class _TestDevice {
  final Size size;
  final double dpr;
  final double topInset;
  final double bottomInset;

  const _TestDevice({
    required this.size,
    required this.dpr,
    this.topInset = 0.0,
    this.bottomInset = 0.0,
  });
}
