// lib/features/game/providers/game_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tile.dart';

class GameProvider extends ChangeNotifier {
  static const int gridSize = 4;
  List<Tile> _tiles = [];
  int _score = 0;
  bool _isGameOver = false;

  // Timer Challenge State
  bool _isTimerMode = false;
  int _remainingSeconds = 300;
  int _targetValue = 1024;
  Timer? _timer;

  // Swap Tile State
  bool _isSwapMode = false;
  Tile? _firstSelectedTile;

  // Undo history
  final List<List<Tile>> _tilesHistory = [];
  final List<int> _scoreHistory = [];
  final List<int> _timerHistory = [];

  List<Tile> get tiles => _tiles;
  int get score => _score;
  bool get isGameOver => _isGameOver;
  bool get canUndo => _tilesHistory.isNotEmpty;
  bool get isSwapMode => _isSwapMode;
  Tile? get firstSelectedTile => _firstSelectedTile;
  bool get isTimerMode => _isTimerMode;
  int get remainingSeconds => _remainingSeconds;
  int get targetValue => _targetValue;

  GameProvider() {
    initGame();
  }

  void startTimerChallenge(int target) {
    _isTimerMode = true;
    _targetValue = target;
    _remainingSeconds = target == 2048 ? 360 : 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_isGameOver) {
        _remainingSeconds--;
        notifyListeners();
      } else if (_remainingSeconds <= 0) {
        _isGameOver = true;
        _timer?.cancel();
        notifyListeners();
      }
    });
    initGame(keepTimerMode: true);
  }

  void initGame({bool keepTimerMode = false}) {
    _tiles = [];
    _score = 0;
    _isGameOver = false;
    _isSwapMode = false;
    _firstSelectedTile = null;
    _tilesHistory.clear();
    _scoreHistory.clear();
    _timerHistory.clear();
    
    if (!keepTimerMode) {
      _isTimerMode = false;
      _timer?.cancel();
    }
    
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 50), () {
      _addNewTile();
      _addNewTile();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addNewTile() {
    final emptyPositions = <Point<int>>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if (!_tiles.any((t) => t.x == x && t.y == y)) {
          emptyPositions.add(Point(x, y));
        }
      }
    }

    if (emptyPositions.isNotEmpty) {
      final pos = emptyPositions[Random().nextInt(emptyPositions.length)];
      _tiles.add(Tile(
        x: pos.x,
        y: pos.y,
        value: Random().nextInt(10) == 0 ? 4 : 2,
        isNew: true,
      ));
    }
  }

  void toggleSwapMode() {
    _isSwapMode = !_isSwapMode;
    _firstSelectedTile = null;
    notifyListeners();
  }

  void selectTileForSwap(Tile tile) {
    if (!_isSwapMode) return;

    if (_firstSelectedTile == null) {
      _firstSelectedTile = tile;
      notifyListeners();
    } else {
      if (_firstSelectedTile!.id == tile.id) {
        // Deselect if clicking the same tile
        _firstSelectedTile = null;
      } else {
        _performSwap(_firstSelectedTile!, tile);
        _isSwapMode = false;
        _firstSelectedTile = null;
      }
      notifyListeners();
    }
  }

  void _performSwap(Tile t1, Tile t2) {
    // Save state for undo
    _tilesHistory.add(_tiles.map((t) => t.copyWith()).toList());
    _scoreHistory.add(_score);
    _timerHistory.add(_remainingSeconds);
    if (_tilesHistory.length > 10) {
      _tilesHistory.removeAt(0);
      _scoreHistory.removeAt(0);
      _timerHistory.removeAt(0);
    }

    final index1 = _tiles.indexWhere((t) => t.id == t1.id);
    final index2 = _tiles.indexWhere((t) => t.id == t2.id);

    if (index1 != -1 && index2 != -1) {
      final pos1x = _tiles[index1].x;
      final pos1y = _tiles[index1].y;
      final pos2x = _tiles[index2].x;
      final pos2y = _tiles[index2].y;

      _tiles[index1] = _tiles[index1].copyWith(x: pos2x, y: pos2y);
      _tiles[index2] = _tiles[index2].copyWith(x: pos1x, y: pos1y);
      
      _isGameOver = _calculateGameOver();
    }
  }

  void moveLeft() => _move(0, -1);
  void moveRight() => _move(0, 1);
  void moveUp() => _move(-1, 0);
  void moveDown() => _move(1, 0);

  void undo() {
    if (!canUndo) return;

    _tiles = _tilesHistory.removeLast();
    _score = _scoreHistory.removeLast();
    _remainingSeconds = _timerHistory.removeLast();
    _isGameOver = _calculateGameOver(); // Recalculate in case we undo a loss
    notifyListeners();
  }

  void _move(int dx, int dy) {
    if (_isGameOver || _isSwapMode) return; // Disable moves while swapping

    // Save current state for undo
    final currentTiles = _tiles.map((t) => t.copyWith()).toList();
    final currentScore = _score;
    final currentTimer = _remainingSeconds;

    bool moved = false;
    List<Tile> nextTiles = [];
    int bonusTime = 0;

    // Reset merged/new flags from previous turn
    _tiles = _tiles.map((t) => t.copyWith(isMerged: false, isNew: false)).toList();

    for (int i = 0; i < gridSize; i++) {
      // 1. Extract current line (row or column)
      List<Tile> line = _tiles.where((t) => dx == 0 ? t.x == i : t.y == i).toList();
      if (line.isEmpty) continue;

      // 2. Sort tiles by proximity to target wall
      line.sort((a, b) {
        if (dx < 0) return a.x.compareTo(b.x); // Up
        if (dx > 0) return b.x.compareTo(a.x); // Down
        if (dy < 0) return a.y.compareTo(b.y); // Left
        return b.y.compareTo(a.y);            // Right
      });

      // 3. Perform Merges
      List<Tile> mergedLine = [];
      for (int j = 0; j < line.length; j++) {
        if (j + 1 < line.length && line[j].value == line[j + 1].value) {
          int val = line[j].value * 2;
          _score += val;
          
          if (_isTimerMode) {
            if (val == 64) bonusTime += 10;
            else if (val == 128) bonusTime += 15;
            else if (val == 256) bonusTime += 20;
            else if (val == 512) bonusTime += 30;
            else if (val == 1024) bonusTime += 40;

            if (val >= _targetValue) {
              _isGameOver = true; // Win condition in timer mode
            }
          }

          // Important: Keep the ID of the 'leading' tile for smooth animation
          mergedLine.add(line[j].copyWith(
            value: val,
            isMerged: true,
          ));
          j++; // Skip the next tile as it was merged
          moved = true;
        } else {
          mergedLine.add(line[j]);
        }
      }

      // 4. Assign new positions within the line
      for (int j = 0; j < mergedLine.length; j++) {
        int targetIndex = (dx > 0 || dy > 0) ? (gridSize - 1 - j) : j;
        int nx = dx == 0 ? i : targetIndex;
        int ny = dy == 0 ? i : targetIndex;

        if (mergedLine[j].x != nx || mergedLine[j].y != ny) {
          moved = true;
        }
        nextTiles.add(mergedLine[j].copyWith(x: nx, y: ny));
      }
    }

    if (moved) {
      // Move was successful, commit state to history
      _tilesHistory.add(currentTiles);
      _scoreHistory.add(currentScore);
      _timerHistory.add(currentTimer);
      // Limit history to last 10 moves to save memory
      if (_tilesHistory.length > 10) {
        _tilesHistory.removeAt(0);
        _scoreHistory.removeAt(0);
        _timerHistory.removeAt(0);
      }

      _tiles = nextTiles;
      _remainingSeconds += bonusTime;
      _addNewTile();
      _isGameOver = _isGameOver || _calculateGameOver();
      notifyListeners();
    }
  }

  bool _calculateGameOver() {
    if (_tiles.length < gridSize * gridSize) return false;

    for (var tile in _tiles) {
      for (var dir in [const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
        int nx = tile.x + dir.x;
        int ny = tile.y + dir.y;
        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          if (_tiles.any((t) => t.x == nx && t.y == ny && t.value == tile.value)) {
            return false;
          }
        }
      }
    }
    return true;
  }
}
