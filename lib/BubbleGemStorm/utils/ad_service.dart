import 'package:google_mobile_ads/google_mobile_ads.dart';


import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// TEST AD UNITS
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String rewardedInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/5354046379';

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewarded();
    loadRewardedInterstitial();
  }

  // REWARDED ADS
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

  // REWARDED INTERSTITIAL ADS
  void loadRewardedInterstitial() {
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback:
          RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewardedInterstitialAd = ad,
        onAdFailedToLoad: (error) => _rewardedInterstitialAd = null,
      ),
    );
  }

  void showRewardedInterstitial({
    required Function(int reward) onReward,
  }) {
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

