import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  static int _counter = 0;

  Future<void> loadAndShowAd({
    required String adUnitId,
    required VoidCallback onAdClosed,
    bool showEveryTwo = false,
  }) async {
    _counter++;

    // Eğer showEveryTwo true ise sadece 2'de 1 reklam göster
    if (showEveryTwo && _counter % 2 != 0) {
      onAdClosed();
      return;
    }

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
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
