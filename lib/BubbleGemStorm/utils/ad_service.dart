import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// TEST AD UNITS
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String rewardedInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/5354046379';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadInterstitial();
    loadRewarded();
    loadRewardedInterstitial();
  }

  BannerAd createBannerAd({AdSize size = AdSize.banner}) {
    _bannerAd = BannerAd(
      size: size,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();

    return _bannerAd!;
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void loadInterstitial() {
    print('LOADING INTERSTITIAL');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('INTERSTITIAL LOADED');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('INTERSTITIAL FAILED $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitial({
    //   void Function()? onAdShown,
    required void Function() onAdDismissed,
  }) {
    print('TRY SHOW INTERSTITIAL');
    print('INTERSTITIAL INSTANCE :$_interstitialAd');
    if (_interstitialAd == null) {
      print(' INTERSTITIAL IS NULL--SKIPPING');
      onAdDismissed();
      return;
    }
    // onAdShown?.call();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('INTERSTITIAL DISMISSED');
        ad.dispose();
        loadInterstitial();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print(' FAILED TO SHOW: $error');
        ad.dispose();
        loadInterstitial();
        onAdDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void showRewarded({required void Function() onAdClosedAfterReward}) {
    if (_rewardedAd == null) return;

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();

        if (rewardEarned) {
          onAdClosedAfterReward();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewarded();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    _rewardedAd = null;
  }

  void loadRewardedInterstitial() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewardedInterstitialAd = ad,
        onAdFailedToLoad: (error) => _rewardedInterstitialAd = null,
      ),
    );
  }

  void showRewardedInterstitial({required Function(int reward) onReward}) {
    if (_rewardedInterstitialAd == null) return;

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            loadRewardedInterstitial();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            loadRewardedInterstitial();
          },
        );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        onReward(reward.amount.toInt());
      },
    );

    _rewardedInterstitialAd = null;
  }
}
