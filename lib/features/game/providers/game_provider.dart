// lib/features/game/providers/game_provider.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twenty48/core/services/daily_challenge_service.dart';
import 'package:twenty48/core/services/stats_service.dart';
import 'package:twenty48/features/game/levels/level_ladder.dart';
import 'package:twenty48/features/game/levels/level_service.dart';
import '../models/tile.dart';

class GameProvider extends ChangeNotifier {
  static const int gridSize = 4;
  Random _rng = Random();
  List<Tile> _tiles = [];
  int _score = 0;
  int _highScore = 0;
  // Daily Challenge State
  final DailyChallengeService _dailyService;
  final StatsService _statsService;
  final LevelService _levelService;
  bool _hasRecordedGame = false;
  int _dailySeed = 0;
  bool _isDailyMode = false;
  bool _dailyCompletedThisGame = false;
  static const int _dailyTarget = 2048;
  int _moveCount = 0;

  // Timer Challenge State
  bool _isTimerMode = false;
  int _remainingSeconds = 300;
  int _targetValue = 1024;
  Timer? _timer;

  // Swap Tile State
  bool _isSwapMode = false;
  Tile? _firstSelectedTile;

  // Undo history
  static const int initialUndoCharges = 3;
  static const int maxUndoRefills = 3;
  int _undoCharges = initialUndoCharges;
  int _undoRefillsUsed = 0;
  final List<List<Tile>> _tilesHistory = [];
  final List<int> _scoreHistory = [];
  final List<int> _timerHistory = [];

  // Effects State
  int _lastBonusTime = 0;
  bool _shouldCelebrate = false;
  int _celebrationId = 0; // To trigger UI updates for the same target reached twice
  bool _hasUsedExtraTime = false;

  List<Tile> get tiles => _tiles;
  Iterable<Tile> get _liveTiles => _tiles.where((t) => !t.isDeleting);
  int get score => _score;
  int get highScore => _highScore;
  bool get isGameOver => (_isTimerMode && _remainingSeconds <= 0) || _hasNoLegalMove();
  bool get canUndo => _tilesHistory.isNotEmpty;
  int get undoCharges => _undoCharges;
  bool get needsUndoAd => _undoCharges == 0;
  int get undoRefillsUsed => _undoRefillsUsed;
  bool get canOfferUndoAd => _undoRefillsUsed < maxUndoRefills;
  bool get isSwapMode => _isSwapMode;
  Tile? get firstSelectedTile => _firstSelectedTile;
  bool get isTimerMode => _isTimerMode;
  int get remainingSeconds => _remainingSeconds;
  int get targetValue => _targetValue;
  int get currentGameTarget => _isDailyMode ? _dailyTarget : _targetValue;
  int get target => currentGameTarget;
  int get moveCount => _moveCount;
  int get highestTile {
    if (_tiles.isEmpty) return 0;
    return _tiles.fold<int>(0, (maxVal, tile) => tile.value > maxVal ? tile.value : maxVal);
  }
  int get lastBonusTime => _lastBonusTime;
  bool get shouldCelebrate => _shouldCelebrate;
  int get celebrationId => _celebrationId;
  bool get hasUsedExtraTime => _hasUsedExtraTime;
  bool get isDailyMode => _isDailyMode;
  bool get dailyCompletedThisGame => _dailyCompletedThisGame;
  StatsService get statsService => _statsService;
  LevelService get levelService => _levelService;
  Level get currentLevel => Level.byIndex(_levelService.currentLevel);

  String _logSummary() {
    final tilesStr = _tiles.map((t) => '${t.x},${t.y}=${t.value}').join(' ');
    return 'score=$_score tiles=${_tiles.length} gameOver=$isGameOver tiles=[$tilesStr]';
  }

  String get logSummary => _logSummary();

  GameProvider({
    DailyChallengeService? dailyService,
    StatsService? statsService,
    LevelService? levelService,
  })  : _dailyService = dailyService ?? DailyChallengeService(),
        _statsService = statsService ?? StatsService(),
        _levelService = levelService ?? LevelService() {
    _loadSettings().then((_) => initGame());
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isTimerMode = prefs.getBool('isTimerMode') ?? false;
    _targetValue = prefs.getInt('targetValue') ?? 1024;
    _highScore = prefs.getInt('highScore') ?? 0;
    await _statsService.load();
    await _levelService.load();
    if (!_isTimerMode && !_isDailyMode) {
      _targetValue = Level.byIndex(_levelService.currentLevel).target;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTimerMode', _isTimerMode);
    await prefs.setInt('targetValue', _targetValue);
    await prefs.setInt('highScore', _highScore);
  }

  void useSeededRandom(int seed) {
    _rng = Random(seed);
  }

  void useDefaultRandom() {
    _rng = Random();
  }

  void startDaily() {
    _isDailyMode = true;
    _isTimerMode = false;
    _dailySeed = _dailyService.todaySeed();
    useSeededRandom(_dailySeed);
    _dailyCompletedThisGame = false;
    initGame();
  }

  void startTimerChallenge(int target) {
    _isDailyMode = false;
    useDefaultRandom();
    _isTimerMode = true;
    _targetValue = target;
    _saveSettings();
    initGame();
  }

  void setStandardMode() {
    _isDailyMode = false;
    useDefaultRandom();
    _isTimerMode = false;
    _targetValue = Level.byIndex(_levelService.currentLevel).target;
    _saveSettings();
    initGame();
  }

  void _checkAndRecordGameEnd() {
    if (_hasRecordedGame) return;
    if (isGameOver) {
      _hasRecordedGame = true;
      final int maxTile = _tiles.fold<int>(
          0, (maxVal, tile) => tile.value > maxVal ? tile.value : maxVal);
      _statsService.recordGameEnd(won: false, highestTile: maxTile);
      if (_isDailyMode && !_dailyCompletedThisGame) {
        _dailyCompletedThisGame = true;
        _dailyService.markCompleted().catchError((_) => 0);
      }
    }
  }

  void initGame() {
    if (_isDailyMode) {
      useSeededRandom(_dailySeed);
    }
    if (!_isTimerMode && !_isDailyMode) {
      _targetValue = Level.byIndex(_levelService.currentLevel).target;
    }
    final beforeInitCount = _tiles.length;
    _tiles = [];
    final afterInitCount = _tiles.length;
    if (kDebugMode) {
      debugPrint('G78 initGame tile count before=$beforeInitCount after=$afterInitCount ${_logSummary()}');
    }
    _score = 0;
    _moveCount = 0;
    _hasRecordedGame = false;
    _isSwapMode = false;
    _firstSelectedTile = null;
    _hasUsedExtraTime = false;
    _undoCharges = initialUndoCharges;
    _undoRefillsUsed = 0;
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
      if (!_isTimerMode && !_isDailyMode) {
        final level = Level.byIndex(_levelService.currentLevel);
        if (level.headStart > 0) {
          _addSpecificTile(level.headStart);
        }
      }
      notifyListeners();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !isGameOver) {
        _remainingSeconds--;
        notifyListeners();
      } else if (_remainingSeconds <= 0) {
        _checkAndRecordGameEnd();
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
        if (!_liveTiles.any((t) => t.x == x && t.y == y)) {
          emptyPositions.add(Point(x, y));
        }
      }
    }

    if (emptyPositions.isNotEmpty) {
      final pos = emptyPositions[_rng.nextInt(emptyPositions.length)];
      final beforeAddCount = _tiles.length;
      _tiles.add(Tile(
        x: pos.x,
        y: pos.y,
        value: _rng.nextInt(10) == 0 ? 4 : 2,
        isNew: true,
      ));
      final afterAddCount = _tiles.length;
      if (kDebugMode) {
        debugPrint('G78 _addNewTile tile count before=$beforeAddCount after=$afterAddCount ${_logSummary()}');
      }
    }
  }

  void _addSpecificTile(int val) {
    final emptyPositions = <Point<int>>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if (!_liveTiles.any((t) => t.x == x && t.y == y)) {
          emptyPositions.add(Point(x, y));
        }
      }
    }

    if (emptyPositions.isNotEmpty) {
      final pos = emptyPositions[_rng.nextInt(emptyPositions.length)];
      final beforeSpecificCount = _tiles.length;
      _tiles.add(Tile(
        x: pos.x,
        y: pos.y,
        value: val,
        isNew: true,
      ));
      final afterSpecificCount = _tiles.length;
      if (kDebugMode) {
        debugPrint('G78 _addSpecificTile tile count before=$beforeSpecificCount after=$afterSpecificCount ${_logSummary()}');
      }
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
    if (_isTimerMode && _remainingSeconds <= 0) return;
    if (t1.isDeleting || t2.isDeleting) return;

    if (kDebugMode) {
      debugPrint('G78 swap start ${_logSummary()}');
    }

    // Save state for undo
    _tilesHistory.add(_liveTiles.map((t) => t.copyWith()).toList());
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
      
      if (isGameOver) {
        _checkAndRecordGameEnd();
      }
    }

    if (kDebugMode) {
      debugPrint('G78 swap end ${_logSummary()}');
    }
  }

  bool moveLeft() => _move(0, -1);
  bool moveRight() => _move(0, 1);
  bool moveUp() => _move(-1, 0);
  bool moveDown() => _move(1, 0);

  void undo() {
    if (!canUndo || _undoCharges <= 0) return;

    if (kDebugMode) {
      debugPrint('G78 undo start ${_logSummary()}');
    }

    final beforeUndoCount = _tiles.length;
    _tiles = _tilesHistory.removeLast();
    final afterUndoCount = _tiles.length;
    if (kDebugMode) {
      debugPrint('G78 undo tile count before=$beforeUndoCount after=$afterUndoCount ${_logSummary()}');
    }

    _score = _scoreHistory.removeLast();
    _remainingSeconds = _timerHistory.removeLast();
    if (_moveCount > 0) _moveCount--;
    _undoCharges--;

    if (kDebugMode) {
      debugPrint('G78 undo end ${_logSummary()}');
    }
    notifyListeners();
  }

  void grantBonusUndos(int n) {
    _undoCharges = min(_undoCharges + n, 10);
    _undoRefillsUsed++;
    notifyListeners();
  }

  void addBonusTime(int seconds) {
    final wasGameOver = isGameOver;
    _remainingSeconds += seconds;
    _hasUsedExtraTime = true;
    if (wasGameOver && _remainingSeconds > 0) {
      if (_isTimerMode) {
        _startTimer();
      }
    }
    notifyListeners();
  }

  bool _move(int dx, int dy) {
    if (isGameOver || _isSwapMode) return false; // Disable moves while swapping

    _tiles.removeWhere((t) => t.isDeleting);

    if (kDebugMode) {
      debugPrint('G78 move start ${_logSummary()}');
    }

    // Save current state for undo
    final currentTiles = _liveTiles.map((t) => t.copyWith()).toList();
    final currentScore = _score;
    final currentTimer = _remainingSeconds;

    bool moved = false;
    List<Tile> nextTiles = [];
    int bonusTime = 0;

    // Reset merged/new flags from previous turn
    final beforeResetCount = _tiles.length;
    _tiles = _tiles.map((t) => t.copyWith(isMerged: false, isNew: false)).toList();
    final afterResetCount = _tiles.length;
    if (kDebugMode) {
      debugPrint('G78 _move tile count before=$beforeResetCount after=$afterResetCount ${_logSummary()}');
    }

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
            if (val == 64) {bonusTime += 10;}
            else if (val == 128) {bonusTime += 15;}
            else if (val == 256) {bonusTime += 20;}
            else if (val == 512) {bonusTime += 30;}
            else if (val >= 1024) {bonusTime += 40;}
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
        
        // Logical fix: If the next tile is deleting, it belongs to this merge
        // and should use the SAME targetOffset. If the current tile is deleting,
        // it means we just finished a merge pair and should increment.
        if (j + 1 < mergedLine.length && mergedLine[j+1].isDeleting) {
          // Stay at current targetOffset for the partner
        } else if (mergedLine[j].isDeleting) {
          targetOffset++;
        } else if (!mergedLine[j].isDeleting) {
          // Single tile, move to next
          targetOffset++;
        }
      }
    }

    if (moved) {
      // Logic for 2048.co style animation:
      // Non-merging tiles move instantly to their target.
      // Merging tiles move to the same target, then one disappears and the other "pops".
      
      _moveCount++;
      _tilesHistory.add(currentTiles);
      _scoreHistory.add(currentScore);
      _timerHistory.add(currentTimer);
      if (_tilesHistory.length > 10) {
        _tilesHistory.removeAt(0);
        _scoreHistory.removeAt(0);
        _timerHistory.removeAt(0);
      }

      final beforeNextTilesCount = _tiles.length;
      _tiles = nextTiles;
      final afterNextTilesCount = _tiles.length;
      if (kDebugMode) {
        debugPrint('G78 _move tile count before=$beforeNextTilesCount after=$afterNextTilesCount ${_logSummary()}');
      }

      _remainingSeconds += bonusTime;
      _lastBonusTime = bonusTime; 
      _addNewTile();
      if (isGameOver) {
        _checkAndRecordGameEnd();
      }
      if (kDebugMode) {
        debugPrint('G78 move end ${_logSummary()}');
      }
      notifyListeners();
      
      // Clean up deleting tiles after animation finishes
      // Increased to 250ms to allow "pop" animations to complete
      Future.delayed(const Duration(milliseconds: 250), () {
        final beforeCleanupCount = _tiles.length;
        _tiles.removeWhere((t) => t.isDeleting);
        _tiles = _tiles.map((t) => t.copyWith(isMerged: false, isNew: false)).toList();
        final afterCleanupCount = _tiles.length;
        if (kDebugMode) {
          debugPrint('G78 _move tile count before=$beforeCleanupCount after=$afterCleanupCount ${_logSummary()}');
        }
        _lastBonusTime = 0;
        _shouldCelebrate = false;
        notifyListeners();
      });
      return true;
    }
    if (kDebugMode) {
      debugPrint('G78 move end ${_logSummary()}');
    }
    return false;
  }

  bool _hasNoLegalMove() {
    final occupiedSquares = _liveTiles.map((t) => Point(t.x, t.y)).toSet();
    if (occupiedSquares.length < gridSize * gridSize) return false;

    for (var tile in _liveTiles) {
      for (var dir in [const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
        int nx = tile.x + dir.x;
        int ny = tile.y + dir.y;
        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize) {
          if (_liveTiles.any((t) => t.x == nx && t.y == ny && t.value == tile.value)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  @visibleForTesting
  void setTilesForTesting(List<Tile> tiles) {
    final beforeTestingCount = _tiles.length;
    _tiles = tiles;
    final afterTestingCount = _tiles.length;
    if (kDebugMode) {
      debugPrint('G78 setTilesForTesting tile count before=$beforeTestingCount after=$afterTestingCount ${_logSummary()}');
    }
    notifyListeners();
  }

  @visibleForTesting
  void setRemainingSecondsForTesting(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }
}
