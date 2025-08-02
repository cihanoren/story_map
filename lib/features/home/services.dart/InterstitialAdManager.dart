import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;

  Future<void> loadAndShowAd(VoidCallback onAdClosed) async {
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-9479192831415354/5701357503',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdClosed();
            },
          );
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (error) {
          print("Interstitial ad failed to load: $error");
          onAdClosed(); // Reklam yüklenemezse bile devam et
        },
      ),
    );
  }
}
