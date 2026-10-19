class AdFrequencyPolicy {
  final DateTime Function() _clock;

  static const int minMovesForCountedGame = 20;
  static const int gamesBetweenInterstitials = 3;
  static const Duration minGapBetweenInterstitials = Duration(minutes: 3);
  static const Duration minGapAfterRewarded = Duration(minutes: 2);

  int _gamesSinceLastAd = 0;
  DateTime? _lastInterstitialTime;
  DateTime? _lastRewardedTime;

  AdFrequencyPolicy({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  int get gamesSinceLastAd => _gamesSinceLastAd;
  DateTime? get lastInterstitialTime => _lastInterstitialTime;
  DateTime? get lastRewardedTime => _lastRewardedTime;

  void onGameFinished(int movesMade) {
    if (movesMade >= minMovesForCountedGame) {
      _gamesSinceLastAd++;
    }
  }

  bool shouldShowInterstitial() {
    final now = _clock();
    if (_gamesSinceLastAd < gamesBetweenInterstitials) {
      return false;
    }
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < minGapBetweenInterstitials) {
      return false;
    }
    if (_lastRewardedTime != null &&
        now.difference(_lastRewardedTime!) < minGapAfterRewarded) {
      return false;
    }
    return true;
  }

  void onInterstitialShown() {
    _gamesSinceLastAd = 0;
    _lastInterstitialTime = _clock();
  }

  void onRewardedShown() {
    _lastRewardedTime = _clock();
  }
}
