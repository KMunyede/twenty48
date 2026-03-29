// lib/features/game/providers/game_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile.dart';

class GameProvider extends ChangeNotifier {
  static const int gridSize = 4;
  List<Tile> _tiles = [];
  int _score = 0;
  int _highScore = 0;
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

  // Effects State
  int _lastBonusTime = 0;
  bool _shouldCelebrate = false;
  int _celebrationId = 0; // To trigger UI updates for the same target reached twice

  List<Tile> get tiles => _tiles;
  int get score => _score;
  int get highScore => _highScore;
  bool get isGameOver => _isGameOver;
  bool get canUndo => _tilesHistory.isNotEmpty;
  bool get isSwapMode => _isSwapMode;
  Tile? get firstSelectedTile => _firstSelectedTile;
  bool get isTimerMode => _isTimerMode;
  int get remainingSeconds => _remainingSeconds;
  int get targetValue => _targetValue;
  int get lastBonusTime => _lastBonusTime;
  bool get shouldCelebrate => _shouldCelebrate;
  int get celebrationId => _celebrationId;

  GameProvider() {
    _loadSettings().then((_) => initGame());
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isTimerMode = prefs.getBool('isTimerMode') ?? false;
    _targetValue = prefs.getInt('targetValue') ?? 1024;
    _highScore = prefs.getInt('highScore') ?? 0;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTimerMode', _isTimerMode);
    await prefs.setInt('targetValue', _targetValue);
    await prefs.setInt('highScore', _highScore);
  }

  void startTimerChallenge(int target) {
    _isTimerMode = true;
    _targetValue = target;
    _saveSettings();
    initGame();
  }

  void setStandardMode() {
    _isTimerMode = false;
    _saveSettings();
    initGame();
  }

  void initGame() {
    _tiles = [];
    _score = 0;
    _isGameOver = false;
    _isSwapMode = false;
    _firstSelectedTile = null;
    _tilesHistory.clear();
    _scoreHistory.clear();
    _timerHistory.clear();
    
    _timer?.cancel();
    if (_isTimerMode) {
      _remainingSeconds = _targetValue == 2048 ? 360 : 300;
      _startTimer();
    }
    
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 50), () {
      _addNewTile();
      _addNewTile();
      notifyListeners();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_isGameOver) {
        _remainingSeconds--;
        notifyListeners();
      } else if (_remainingSeconds <= 0 && !_isGameOver) {
        _isGameOver = true;
        _timer?.cancel();
        notifyListeners();
      }
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
            else if (val >= 1024) bonusTime += 40;

            if (val >= _targetValue) {
              _isGameOver = true; // Win condition in timer mode
            }
          }

          if (_score > _highScore) {
            _highScore = _score;
            _saveSettings();
          }

          // Check for celebration (1024, 2048, 4096, 8192)
          if (val >= 1024 && [1024, 2048, 4096, 8192].contains(val)) {
            _shouldCelebrate = true;
            _celebrationId++;
          }

          // First tile stays and becomes the new merged tile
          mergedLine.add(line[j].copyWith(
            value: val,
            isMerged: true,
          ));
          
          // Second tile is marked as deleting but moves to the same target position
          mergedLine.add(line[j + 1].copyWith(
            isDeleting: true,
          ));
          
          j++; // Skip the next tile as it was processed
          moved = true;
        } else {
          mergedLine.add(line[j]);
        }
      }

      // 4. Assign new positions within the line
      int targetOffset = 0;
      for (int j = 0; j < mergedLine.length; j++) {
        int targetIndex = (dx > 0 || dy > 0) ? (gridSize - 1 - targetOffset) : targetOffset;
        int nx = dx == 0 ? i : targetIndex;
        int ny = dy == 0 ? i : targetIndex;

        if (mergedLine[j].x != nx || mergedLine[j].y != ny) {
          moved = true;
        }
        nextTiles.add(mergedLine[j].copyWith(x: nx, y: ny));
        
        // Only increment the target offset if the tile is NOT deleting
        // (Deleting tiles move to the same position as their merge partner)
        if (!mergedLine[j].isDeleting) {
          targetOffset++;
        }
      }
    }

    if (moved) {
      // Logic for 2048.co style animation:
      // Non-merging tiles move instantly to their target.
      // Merging tiles move to the same target, then one disappears and the other "pops".
      
      _tilesHistory.add(currentTiles);
      _scoreHistory.add(currentScore);
      _timerHistory.add(currentTimer);
      if (_tilesHistory.length > 10) {
        _tilesHistory.removeAt(0);
        _scoreHistory.removeAt(0);
        _timerHistory.removeAt(0);
      }

      _tiles = nextTiles;
      _remainingSeconds += bonusTime;
      _lastBonusTime = bonusTime; 
      _addNewTile();
      _isGameOver = _isGameOver || _calculateGameOver();
      notifyListeners();
      
      // Clean up deleting tiles after animation finishes
      Future.delayed(const Duration(milliseconds: 100), () {
        _tiles.removeWhere((t) => t.isDeleting);
        _tiles = _tiles.map((t) => t.copyWith(isMerged: false, isNew: false)).toList();
        _lastBonusTime = 0;
        _shouldCelebrate = false;
        notifyListeners();
      });
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
