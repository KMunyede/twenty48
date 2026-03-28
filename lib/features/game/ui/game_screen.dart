// lib/features/game/ui/game_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../settings/ui/settings_dialog.dart';
import 'widgets/tile_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _timerAnimationController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final game = context.read<GameProvider>();

    // Ensure we request focus whenever the screen is built to catch keyboard events
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            game.moveUp();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            game.moveDown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            game.moveLeft();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            game.moveRight();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: theme.textColor),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: _buildGameBoard(context),
                  ),
                ),
                const SizedBox(height: 32),
                _buildControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2048',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.scoreTileColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SCORE',
                        style: TextStyle(
                          color: theme.backgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${game.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (game.isTimerMode)
              AnimatedBuilder(
                animation: _timerAnimationController,
                builder: (context, child) {
                  Color baseColor;
                  bool shouldFlash;

                  if (game.remainingSeconds >= 200) {
                    baseColor = Colors.green;
                    shouldFlash = false;
                  } else if (game.remainingSeconds >= 100) {
                    baseColor = Colors.yellow[700]!; // Darker yellow for better contrast
                    shouldFlash = false;
                  } else if (game.remainingSeconds >= 30) {
                    baseColor = Colors.orange;
                    shouldFlash = true;
                  } else {
                    baseColor = Colors.red;
                    shouldFlash = true;
                  }

                  final displayColor = shouldFlash
                      ? Color.lerp(
                          baseColor.withOpacity(0.5),
                          baseColor.withOpacity(1.0),
                          _timerAnimationController.value,
                        )
                      : baseColor;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Time Challenge Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Time Remaining:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${game.remainingSeconds}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildGameBoard(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final gridSize = GameProvider.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum possible board size based on available space
        final maxPossibleSize = min(constraints.maxWidth, constraints.maxHeight);
        // Add padding to ensure the board doesn't touch the edges exactly
        final size = maxPossibleSize - 16; 
        final tileSize = (size - (gridSize + 1) * 8) / gridSize;

        return Consumer<GameProvider>(
          builder: (context, game, child) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanEnd: (details) {
                final velocity = details.velocity.pixelsPerSecond;
                if (velocity.dx.abs() > velocity.dy.abs()) {
                  if (velocity.dx < -500) game.moveLeft();
                  else if (velocity.dx > 500) game.moveRight();
                } else {
                  if (velocity.dy < -500) game.moveUp();
                  else if (velocity.dy > 500) game.moveDown();
                }
              },
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    // Background Grid
                    Container(
                      decoration: BoxDecoration(
                        color: theme.boardColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: List.generate(gridSize * gridSize, (index) {
                          int x = index ~/ gridSize;
                          int y = index % gridSize;
                          return Positioned(
                            left: y * (tileSize + 8) + 8,
                            top: x * (tileSize + 8) + 8,
                            child: Container(
                              width: tileSize,
                              height: tileSize,
                              decoration: BoxDecoration(
                                color: theme.emptyTileColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Active Tiles
                    Stack(
                      children: game.tiles.map((tile) {
                        final isSelected = game.firstSelectedTile?.id == tile.id;
                        return AnimatedPositioned(
                          key: ValueKey(tile.id),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          left: tile.y * (tileSize + 8) + 8,
                          top: tile.x * (tileSize + 8) + 8,
                          child: GestureDetector(
                            onTap: game.isSwapMode ? () => game.selectTileForSwap(tile) : null,
                            child: SizedBox(
                              width: tileSize,
                              height: tileSize,
                              child: Container(
                                decoration: isSelected ? BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 4),
                                  borderRadius: BorderRadius.circular(8.0),
                                ) : null,
                                child: tile.isNew 
                                  ? TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 500),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: TileWidget(tile: tile),
                                    )
                                  : TileWidget(tile: tile),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Game Over Overlay
                    if (game.isGameOver)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Game Over!',
                                style: TextStyle(
                                  fontSize: size * 0.12, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                  color: theme.textColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => game.initGame(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.scoreTileColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Play Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20, // Increased size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Column(
          children: [
            if (game.isSwapMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  game.firstSelectedTile == null 
                    ? 'Select first tile to swap' 
                    : 'Select second tile to swap',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: game.canUndo ? () => game.undo() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.scoreTileColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    disabledBackgroundColor: theme.scoreTileColor.withOpacity(0.3),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.undo, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Undo',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => game.toggleSwapMode(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: game.isSwapMode ? Colors.orange : theme.scoreTileColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        game.isSwapMode ? 'Cancel' : 'Swap Tiles',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => game.initGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.scoreTileColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
