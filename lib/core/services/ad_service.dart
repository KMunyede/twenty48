import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_frequency_policy.dart';

class AdService {
  final AdFrequencyPolicy frequencyPolicy;

  AdService._({AdFrequencyPolicy? frequencyPolicy})
      : frequencyPolicy = frequencyPolicy ?? AdFrequencyPolicy();

  static final AdService instance = AdService._();

  bool _adsEnabled = false;
  final ValueNotifier<bool> _adsEnabledNotifier = ValueNotifier<bool>(false);

  bool get adsEnabled => _adsEnabled;
  ValueListenable<bool> get adsEnabledListenable => _adsEnabledNotifier;

  bool _hasInitialized = false;

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get ready => _initCompleter.future;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.environment.containsKey('FLUTTER_TEST'));

  // Test Ad Unit IDs - REPLACE BEFORE RELEASE
  String get _bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // REPLACE BEFORE RELEASE
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // REPLACE BEFORE RELEASE
    }
    return '';
  }

  String get _interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // REPLACE BEFORE RELEASE
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // REPLACE BEFORE RELEASE
    }
    return '';
  }

  String get _rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // REPLACE BEFORE RELEASE
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // REPLACE BEFORE RELEASE
    }
    return '';
  }

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;

  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  Future<void> enableAds() async {
    if (_adsEnabled || !isSupported) return;
    _adsEnabled = true;
    _adsEnabledNotifier.value = true;
    try {
      if (!_hasInitialized) {
        _hasInitialized = true;
        await init();
      } else {
        loadInterstitial();
        loadRewarded();
      }
    } catch (e) {
      debugPrint('AdService enableAds error: $e');
      _hasInitialized = false;
      _adsEnabled = false;
      _adsEnabledNotifier.value = false;
    }
  }

  void disableAds() {
    _adsEnabled = false;
    _adsEnabledNotifier.value = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoadingInterstitial = false;

    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoadingRewarded = false;
  }

  Future<void> init() async {
    if (!isSupported || Platform.environment.containsKey('FLUTTER_TEST')) {
      if (!_initCompleter.isCompleted) _initCompleter.complete();
      return;
    }
    try {
      await MobileAds.instance.initialize();
      if (_adsEnabled) {
        loadInterstitial();
        loadRewarded();
      }
    } catch (e) {
      debugPrint('AdService init error: $e');
      rethrow;
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  void loadInterstitial() {
    if (!_adsEnabled || !isSupported || _isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isLoadingInterstitial = false;
        },
      ),
    );
  }

  void showInterstitialIfReady({required int movesMade}) {
    frequencyPolicy.onGameFinished(movesMade);

    if (!_adsEnabled || !isSupported) return;

    if (!frequencyPolicy.shouldShowInterstitial()) {
      debugPrint('Interstitial ad blocked by frequency policy');
      return;
    }

    if (_interstitialAd == null) {
      loadInterstitial();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        frequencyPolicy.onInterstitialShown();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );

    _interstitialAd!.show();
  }

  void loadRewarded() {
    if (!_adsEnabled || !isSupported || _isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoadingRewarded = false;
        },
      ),
    );
  }

  void showRewarded({
    required VoidCallback onReward,
    required VoidCallback onUnavailable,
  }) {
    if (!_adsEnabled || !isSupported || _rewardedAd == null) {
      onUnavailable();
      if (_adsEnabled) {
        loadRewarded();
      }
      return;
    }

    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        frequencyPolicy.onRewardedShown();
        loadRewarded();
        if (!userEarnedReward) {
          onUnavailable();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onUnavailable();
        loadRewarded();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        userEarnedReward = true;
        frequencyPolicy.onRewardedShown();
        onReward();
      },
    );
  }

  BannerAd? createAdaptiveBanner(
    AdSize adSize,
    VoidCallback onLoaded,
    void Function(LoadAdError error) onFailed,
  ) {
    if (!_adsEnabled || !isSupported) return null;

    final banner = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: code ${error.code}, message: ${error.message}');
          ad.dispose();
          onFailed(error);
        },
      ),
    );

    banner.load();
    return banner;
  }
}

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Timer? _retryTimer;
  int _retryCount = 0;

  static const List<Duration> _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 45),
  ];

  @override
  void initState() {
    super.initState();
    AdService.instance.adsEnabledListenable.addListener(_onAdsEnabledChanged);
  }

  @override
  void dispose() {
    AdService.instance.adsEnabledListenable.removeListener(_onAdsEnabledChanged);
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onAdsEnabledChanged() {
    if (!mounted) return;
    if (!AdService.instance.adsEnabled) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _bannerAd?.dispose();
      _bannerAd = null;
      setState(() {
        _isAdLoaded = false;
      });
    } else {
      if (_bannerAd == null && _retryTimer == null) {
        _loadBanner();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null &&
        _retryTimer == null &&
        AdService.instance.isSupported &&
        AdService.instance.adsEnabled) {
      _loadBanner();
    }
  }

  void _loadBanner() async {
    if (!mounted ||
        !AdService.instance.isSupported ||
        !AdService.instance.adsEnabled) {
      return;
    }

    try {
      await AdService.instance.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );
    } catch (_) {}

    if (!mounted || !AdService.instance.adsEnabled) return;

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width.truncate();
    if (width <= 0) return;

    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ??
        AdSize.banner;

    if (!mounted || !AdService.instance.adsEnabled) return;

    _bannerAd?.dispose();
    _bannerAd = AdService.instance.createAdaptiveBanner(
      adSize,
      () {
        if (mounted) {
          _retryCount = 0;
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _bannerAd = null;
          });
          _scheduleRetry();
        }
      },
    );
  }

  void _scheduleRetry() {
    if (!mounted ||
        _retryCount >= _retryDelays.length ||
        !AdService.instance.adsEnabled) {
      return;
    }

    final delay = _retryDelays[_retryCount];
    _retryCount++;
    debugPrint('Scheduling banner retry #$_retryCount in ${delay.inSeconds}s');

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (mounted && AdService.instance.adsEnabled) {
        _retryTimer = null;
        _loadBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdService.instance.adsEnabledListenable,
      builder: (context, adsEnabled, child) {
        if (!adsEnabled || !_isAdLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
