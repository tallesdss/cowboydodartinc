import UIKit
import Flutter
import flutter_local_notifications
import AdSupport
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
      GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

      let advertisingChannel = FlutterMethodChannel(
          name: "kasy_kit/advertising_id",
          binaryMessenger: engineBridge.applicationRegistrar.messenger()
      )

      advertisingChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "getAdvertisingId" {
          if #available(iOS 14.5, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .authorized {
              let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
              if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                result(idfa)
              } else {
                result("")
              }
            } else {
              result("")
            }
          } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
              let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
              result(idfa)
            } else {
              result("")
            }
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      })

      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
      }

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
  }
}
