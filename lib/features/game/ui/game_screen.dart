// lib/features/game/ui/game_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../settings/ui/settings_dialog.dart';
import 'widgets/tile_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _timerAnimationController;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 7));
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timerAnimationController.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onGameUpdate() {
    final game = context.read<GameProvider>();
    if (game.shouldCelebrate) {
      _confettiController.play();
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final game = context.watch<GameProvider>(); // Switch to watch to react to celebration flags

    // Ensure we request focus whenever the screen is built to catch keyboard events
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    // Trigger animations if needed
    if (game.shouldCelebrate && _shakeController.status != AnimationStatus.forward) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
        _shakeController.forward(from: 0.0);
      });
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    if (game.isTimerMode) ...[
                      _buildTimer(context, game),
                      const SizedBox(height: 24),
                    ],
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            final double shake = sin(_shakeController.value * 10 * pi) * 10 * (1 - _shakeController.value);
                            return Transform.translate(
                              offset: Offset(shake, 0),
                              child: _buildGameBoard(context),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildControls(context),
                  ],
                ),
              ),
              // Confetti Overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // downwards
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                ),
              ),
              // Floating Bonus Time
              if (game.lastBonusTime > 0)
                Positioned(
                  top: 100,
                  right: 50,
                  child: _BonusTimeAnimation(bonus: game.lastBonusTime),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreBox(
              'SCORE',
              '${game.score}',
              theme,
              isLarge: true,
            ),
            const SizedBox(width: 16),
            _buildScoreBox(
              'BEST',
              '${game.highScore}',
              theme,
              isLarge: true,
            ),
            if (game.isTimerMode) ...[
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET',
                    style: TextStyle(
                      color: theme.textColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${game.targetValue}',
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTimer(BuildContext context, GameProvider game) {
    return AnimatedBuilder(
      animation: _timerAnimationController,
      builder: (context, child) {
        Color baseColor;
        bool shouldFlash;

        if (game.remainingSeconds >= 200) {
          baseColor = Colors.green;
          shouldFlash = false;
        } else if (game.remainingSeconds >= 100) {
          baseColor = Colors.yellow[700]!;
          shouldFlash = false;
        } else if (game.remainingSeconds >= 30) {
          baseColor = Colors.orange;
          shouldFlash = true;
        } else {
          baseColor = Colors.red;
          shouldFlash = true;
        }

        final displayColor = (shouldFlash
            ? Color.lerp(
                baseColor.withOpacity(0.5),
                baseColor.withOpacity(1.0),
                _timerAnimationController.value,
              )
            : baseColor) ?? baseColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: displayColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TIME REMAINING',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${game.remainingSeconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBox(String label, String value, theme, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 32 : 12,
        vertical: isLarge ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.scoreTileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 14 : 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 28 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
                        final isMovingToMerge = tile.isDeleting || tile.isMerged;
                        
                        return AnimatedPositioned(
                          key: ValueKey(tile.id),
                          duration: const Duration(milliseconds: 100), // Snappy movement like 2048.co
                          curve: Curves.easeInOut,
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
                                child: tile.isDeleting 
                                  ? TileWidget(tile: tile) // The disappearing tile
                                  : tile.isMerged
                                    ? TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 200), // Quick pop
                                        tween: Tween(begin: 1.0, end: 1.15),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          // Pop and return to 1.0
                                          double scale = value;
                                          if (value > 1.1) {
                                            scale = 1.1 - (value - 1.1);
                                          }
                                          return Transform.scale(
                                            scale: scale,
                                            child: child,
                                          );
                                        },
                                        child: TileWidget(tile: tile),
                                      )
                                    : tile.isNew 
                                      ? TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 200),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          curve: Curves.easeOut,
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
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: game.canUndo ? () => game.undo() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scoreTileColor,
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: theme.scoreTileColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.undo, color: Colors.white, size: 30),
                        SizedBox(height: 4),
                        Text(
                          'Undo',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () => game.toggleSwapMode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: game.isSwapMode ? Colors.orange : theme.scoreTileColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
                        const SizedBox(height: 4),
                        Text(
                          game.isSwapMode ? 'Cancel' : 'Swap',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: () => game.initGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scoreTileColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 30),
                        SizedBox(height: 4),
                        Text(
                          'New',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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

class _BonusTimeAnimation extends StatefulWidget {
  final int bonus;
  const _BonusTimeAnimation({required this.bonus});

  @override
  State<_BonusTimeAnimation> createState() => _BonusTimeAnimationState();
}

class _BonusTimeAnimationState extends State<_BonusTimeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _moveAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _moveAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                '+${widget.bonus}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
