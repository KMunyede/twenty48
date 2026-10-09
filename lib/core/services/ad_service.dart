import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
  DateTime? _lastInterstitialTime;
  static const Duration _interstitialCooldown = Duration(minutes: 2);

  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  Future<void> init() async {
    if (!isSupported) return;
    try {
      await MobileAds.instance.initialize();
      loadInterstitial();
      loadRewarded();
    } catch (e) {
      debugPrint('AdService init error: $e');
    }
  }

  void loadInterstitial() {
    if (!isSupported || _isLoadingInterstitial || _interstitialAd != null) return;
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

  void showInterstitialIfReady() {
    if (!isSupported) return;

    final now = DateTime.now();
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < _interstitialCooldown) {
      debugPrint('Interstitial ad on cooldown');
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
        _lastInterstitialTime = DateTime.now();
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
    if (!isSupported || _isLoadingRewarded || _rewardedAd != null) return;
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
    if (!isSupported || _rewardedAd == null) {
      onUnavailable();
      loadRewarded();
      return;
    }

    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
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
        onReward();
      },
    );
  }

  BannerAd? createAdaptiveBanner(AdSize adSize, VoidCallback onLoaded, VoidCallback onFailed) {
    if (!isSupported) return null;

    final banner = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          onFailed();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && AdService.instance.isSupported) {
      _loadBanner();
    }
  }

  void _loadBanner() async {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width.truncate();
    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ??
        AdSize.banner;

    _bannerAd = AdService.instance.createAdaptiveBanner(
      adSize,
      () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      () {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _bannerAd = null;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
