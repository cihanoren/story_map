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
    GMSServices.provideAPIKey("AIzaSyBCCC6yeolve44xzBTrvd0Q_8RHYBoRehc")

    // ✅ Flutter pluginleri kaydet
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}