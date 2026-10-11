import 'package:flutter_test/flutter_test.dart';
import 'package:twenty48/core/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AdService.instance.disableAds();
  });

  test('adsEnabled is false by default', () {
    expect(AdService.instance.adsEnabled, isFalse);
    expect(AdService.instance.adsEnabledListenable.value, isFalse);
  });

  test('showRewarded calls onUnavailable when disabled', () {
    bool rewardCalled = false;
    bool unavailableCalled = false;

    AdService.instance.showRewarded(
      onReward: () => rewardCalled = true,
      onUnavailable: () => unavailableCalled = true,
    );

    expect(rewardCalled, isFalse);
    expect(unavailableCalled, isTrue);
  });

  test('disableAds is safe to call when never enabled', () {
    expect(() => AdService.instance.disableAds(), returnsNormally);
    expect(AdService.instance.adsEnabled, isFalse);
  });
}
