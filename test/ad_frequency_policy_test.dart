import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/core/services/ad_frequency_policy.dart';

void main() {
  group('AdFrequencyPolicy', () {
    test('no show before 3 qualifying games', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      expect(policy.shouldShowInterstitial(), isFalse);

      policy.onGameFinished(25); // 1st
      expect(policy.shouldShowInterstitial(), isFalse);

      policy.onGameFinished(25); // 2nd
      expect(policy.shouldShowInterstitial(), isFalse);
    });

    test('games under 20 moves do not count', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      policy.onGameFinished(10); // under 20
      policy.onGameFinished(15); // under 20
      policy.onGameFinished(25); // 1st qualifying
      expect(policy.shouldShowInterstitial(), isFalse);

      policy.onGameFinished(25); // 2nd qualifying
      expect(policy.shouldShowInterstitial(), isFalse);

      policy.onGameFinished(25); // 3rd qualifying
      expect(policy.shouldShowInterstitial(), isTrue);
    });

    test('shows on 3rd qualifying game and resets counter after show', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);

      expect(policy.shouldShowInterstitial(), isTrue);

      policy.onInterstitialShown();
      expect(policy.shouldShowInterstitial(), isFalse);
      expect(policy.gamesSinceLastAd, 0);
    });

    test('not again within 3 minutes even with 3 more games', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);
      expect(policy.shouldShowInterstitial(), isTrue);
      policy.onInterstitialShown();

      // Advance 2 minutes (less than 3 min gap)
      currentTime = currentTime.add(const Duration(minutes: 2));

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);
      expect(policy.shouldShowInterstitial(), isFalse);
    });

    test('shows again after 3 minutes and 3 more qualifying games', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onInterstitialShown();

      // Advance 3 minutes
      currentTime = currentTime.add(const Duration(minutes: 3));

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);
      expect(policy.shouldShowInterstitial(), isTrue);
    });

    test('blocked within 2 minutes after a rewarded ad and allowed after', () {
      DateTime currentTime = DateTime(2026, 1, 1, 12, 0);
      final policy = AdFrequencyPolicy(clock: () => currentTime);

      policy.onGameFinished(25);
      policy.onGameFinished(25);
      policy.onGameFinished(25);
      expect(policy.shouldShowInterstitial(), isTrue);

      // Rewarded ad shown
      policy.onRewardedShown();

      // Within 2 minutes -> blocked
      currentTime = currentTime.add(const Duration(minutes: 1));
      expect(policy.shouldShowInterstitial(), isFalse);

      // After 2 minutes -> allowed
      currentTime = currentTime.add(const Duration(minutes: 1));
      expect(policy.shouldShowInterstitial(), isTrue);
    });
  });
}
