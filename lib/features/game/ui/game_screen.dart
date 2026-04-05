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
  bool _isMoving = false;
  double _totalDx = 0;
  double _totalDy = 0;

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

    // Request focus after first frame to enable keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timerAnimationController.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final game = context.watch<GameProvider>();

    // Trigger animations if needed
    if (game.shouldCelebrate && _shakeController.status != AnimationStatus.forward) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _confettiController.play();
          _shakeController.forward(from: 0.0);
        }
      });
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          final key = event.logicalKey;
          bool moved = false;
          bool isGameKey = true;

          if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
            moved = game.moveUp();
          } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
            moved = game.moveDown();
          } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
            moved = game.moveLeft();
          } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
            moved = game.moveRight();
          } else {
            isGameKey = false;
          }

          if (isGameKey) {
            if (moved) HapticFeedback.lightImpact();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 48,
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
            child: OrientationBuilder(
              builder: (context, orientation) {
                final bool isLandscape = orientation == Orientation.landscape;
                if (isLandscape) {
                  return _buildLandscapeLayout(context, game);
                }
                return _buildPortraitLayout(context, game);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, GameProvider game) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              if (game.isTimerMode) ...[
                _buildTimer(context, game),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: Center(
                  child: _buildAnimatedGameBoard(),
                ),
              ),
              const SizedBox(height: 16),
              _buildControls(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildOverlays(game),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, GameProvider game) {
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 1000;
    
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32.0 : 16.0,
            vertical: isLargeScreen ? 16.0 : 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                flex: isLargeScreen ? 2 : 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(
                        context, 
                        isCompact: !isLargeScreen, 
                        isExtraLarge: isLargeScreen,
                        isVertical: true,
                      ),
                      if (game.isTimerMode) ...[
                        SizedBox(height: isLargeScreen ? 32 : 16),
                        _buildTimer(
                          context, 
                          game, 
                          isCompact: !isLargeScreen, 
                          isExtraLarge: isLargeScreen,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: isLargeScreen ? 5 : 6,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity,
                        maxHeight: isLargeScreen ? 600 : double.infinity,
                      ),
                      child: _buildAnimatedGameBoard(),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: isLargeScreen ? 2 : 3,
                child: SingleChildScrollView(
                  child: _buildControls(
                    context, 
                    isCompact: !isLargeScreen, 
                    isExtraLarge: isLargeScreen,
                    isVertical: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildOverlays(game),
      ],
    );
  }

  Widget _buildAnimatedGameBoard() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double shake = sin(_shakeController.value * 10 * pi) * 10 * (1 - _shakeController.value);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: _buildGameBoard(context),
        );
      },
    );
  }

  Widget _buildOverlays(GameProvider game) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
        if (game.lastBonusTime > 0)
          Positioned(
            top: 100,
            right: 50,
            child: _BonusTimeAnimation(bonus: game.lastBonusTime),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool isCompact = false, bool isExtraLarge = false, bool isVertical = false}) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final children = [
          _buildScoreBox(
            'SCORE',
            '${game.score}',
            theme,
            isLarge: !isCompact || isExtraLarge,
            isExtraLarge: isExtraLarge,
          ),
          if (isVertical) SizedBox(height: isExtraLarge ? 24 : 12),
          _buildScoreBox(
            'BEST',
            '${game.highScore}',
            theme,
            isLarge: !isCompact || isExtraLarge,
            isExtraLarge: isExtraLarge,
          ),
          if (game.isTimerMode) ...[
            if (isVertical) SizedBox(height: isExtraLarge ? 24 : 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isExtraLarge ? 24 : 12, 
                vertical: isExtraLarge ? 16 : (isCompact ? 4 : 8)
              ),
              decoration: BoxDecoration(
                border: Border.all(color: theme.textColor.withValues(alpha: 0.3), width: isExtraLarge ? 2 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TARGET',
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: isExtraLarge ? 16 : (isCompact ? 9 : 12),
                    ),
                  ),
                  Text(
                    '${game.targetValue}',
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isExtraLarge ? 32 : (isCompact ? 14 : 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ];

        if (isVertical) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: isExtraLarge ? 24 : (isCompact ? 8 : 16),
          runSpacing: 12,
          children: children,
        );
      },
    );
  }

  Widget _buildTimer(BuildContext context, GameProvider game, {bool isCompact = false, bool isExtraLarge = false}) {
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
                baseColor.withValues(alpha: 0.5),
                baseColor.withValues(alpha: 1.0),
                _timerAnimationController.value,
              )
            : baseColor) ?? baseColor;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExtraLarge ? 64 : (isCompact ? 16 : 32), 
            vertical: isExtraLarge ? 24 : (isCompact ? 8 : 12)
          ),
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: displayColor.withValues(alpha: 0.3),
                blurRadius: isExtraLarge ? 16 : 8,
                spreadRadius: isExtraLarge ? 4 : 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TIME REMAINING',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isExtraLarge ? 18 : (isCompact ? 9 : 12),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${game.remainingSeconds}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isExtraLarge ? 56 : (isCompact ? 20 : 32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBox(String label, String value, theme, {bool isLarge = false, bool isExtraLarge = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraLarge ? 48 : (isLarge ? 24 : 12),
        vertical: isExtraLarge ? 20 : (isLarge ? 10 : 6),
      ),
      decoration: BoxDecoration(
        color: theme.scoreTileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: isExtraLarge ? 18 : (isLarge ? 12 : 9),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isExtraLarge ? 40 : (isLarge ? 22 : 16),
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
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final tileSize = (size - (gridSize + 1) * 8) / gridSize;

        return Consumer<GameProvider>(
          builder: (context, game, child) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) {
                _totalDx = 0;
                _totalDy = 0;
                _isMoving = false;
              },
              onPanUpdate: (details) {
                if (game.isSwapMode || _isMoving) return;
                _totalDx += details.delta.dx;
                _totalDy += details.delta.dy;

                const double threshold = 30;
                if (_totalDx.abs() > threshold || _totalDy.abs() > threshold) {
                  _isMoving = true;
                  bool moved = false;
                  if (_totalDx.abs() > _totalDy.abs()) {
                    if (_totalDx > 0) {
                      moved = game.moveRight();
                    } else {
                      moved = game.moveLeft();
                    }
                  } else {
                    if (_totalDy > 0) {
                      moved = game.moveDown();
                    } else {
                      moved = game.moveUp();
                    }
                  }
                  if (moved) HapticFeedback.lightImpact();
                }
              },
              onPanEnd: (_) => _isMoving = false,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  children: [
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
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Stack(
                      children: game.tiles.map((tile) {
                        final isSelected = game.firstSelectedTile?.id == tile.id;
                        final tileWidget = TileWidget(tile: tile);
                        
                        Widget animatedTile = tileWidget;

                        if (tile.isMerged) {
                          animatedTile = TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 100),
                            tween: Tween(begin: 1.0, end: 1.15),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value > 1.075 ? 2.15 - value : value,
                                child: child,
                              );
                            },
                            child: tileWidget,
                          );
                        } else if (tile.isNew) {
                          animatedTile = TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: tileWidget,
                          );
                        }

                        return AnimatedPositioned(
                          key: ValueKey(tile.id),
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          left: tile.y * (tileSize + 8) + 8,
                          top: tile.x * (tileSize + 8) + 8,
                          child: SizedBox(
                            width: tileSize,
                            height: tileSize,
                            child: game.isSwapMode 
                              ? GestureDetector(
                                  onTap: () => game.selectTileForSwap(tile),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    decoration: isSelected ? BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 4),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ) : null,
                                    child: animatedTile,
                                  ),
                                )
                              : animatedTile,
                          ),
                        );
                      }).toList(),
                    ),
                    if (game.isGameOver)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Game Over!',
                                style: TextStyle(
                                  fontSize: size * 0.12,
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
                                    fontSize: 20,
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

  Widget _buildControls(BuildContext context, {bool isCompact = false, bool isExtraLarge = false, bool isVertical = false}) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final size = isExtraLarge ? 140.0 : (isCompact ? 64.0 : 100.0);
    final iconSize = isExtraLarge ? 48.0 : (isCompact ? 20.0 : 30.0);
    final fontSize = isExtraLarge ? 20.0 : (isCompact ? 11.0 : 16.0);

    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final buttons = [
          _buildControlButton(
            onPressed: game.canUndo ? () => game.undo() : null,
            icon: Icons.undo,
            label: 'Undo',
            theme: theme,
            size: size,
            iconSize: iconSize,
            fontSize: fontSize,
            isDisabled: !game.canUndo,
          ),
          if (!isVertical) SizedBox(width: isExtraLarge ? 24 : 8) else SizedBox(height: isExtraLarge ? 24 : 12),
          _buildControlButton(
            onPressed: () => game.toggleSwapMode(),
            icon: Icons.swap_horiz,
            label: game.isSwapMode ? 'Cancel' : 'Swap',
            theme: theme,
            size: size,
            iconSize: iconSize,
            fontSize: fontSize,
            color: game.isSwapMode ? Colors.orange : null,
          ),
          if (!isVertical) SizedBox(width: isExtraLarge ? 24 : 8) else SizedBox(height: isExtraLarge ? 24 : 12),
          _buildControlButton(
            onPressed: () => game.initGame(),
            icon: Icons.refresh,
            label: 'New',
            theme: theme,
            size: size,
            iconSize: iconSize,
            fontSize: fontSize,
          ),
        ];

        return Column(
          children: [
            if (game.isSwapMode)
              Padding(
                padding: EdgeInsets.only(bottom: isExtraLarge ? 24.0 : 12.0),
                child: Text(
                  game.firstSelectedTile == null 
                    ? 'Select first tile' 
                    : 'Select second tile',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: isExtraLarge ? 24 : (isCompact ? 14 : 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isVertical) 
              Column(children: buttons)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required dynamic theme,
    required double size,
    required double iconSize,
    required double fontSize,
    bool isDisabled = false,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        focusNode: FocusNode(skipTraversal: true),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.scoreTileColor,
          padding: EdgeInsets.zero,
          disabledBackgroundColor: theme.scoreTileColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ],
        ),
      ),
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
