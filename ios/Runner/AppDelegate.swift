import UIKit
import Flutter
import GoogleMaps  // ✅ Google Maps için gerekli

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // ✅ Google Maps API Key ekleme
    GMSServices.provideAPIKey("AIzaSyDR0bAousHaywqfYkv1YF6jEFSSrEwAeDc")

    // ✅ Flutter pluginleri kaydet
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}