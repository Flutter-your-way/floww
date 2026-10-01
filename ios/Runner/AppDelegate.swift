import Flutter
import UIKit

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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: InstagramStoriesChannel.name) {
      InstagramStoriesChannel.register(with: registrar)
    }
  }
}

final class InstagramStoriesChannel {
  static let name = "InstagramStoriesChannel"
  private static let channelName = "floww/instagram_stories"
  private static let shareMethod = "shareToStory"
  private static let stickerKey = "com.instagram.sharedSticker.stickerImage"
  private static let pasteboardLifetime: TimeInterval = 300

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == shareMethod else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let image = args["image"] as? FlutterStandardTypedData
      else {
        result(false)
        return
      }
      shareToStory(image.data, appId: args["appId"] as? String ?? "", result: result)
    }
  }

  private static func shareToStory(_ image: Data, appId: String, result: @escaping FlutterResult) {
    var components = URLComponents(string: "instagram-stories://share")
    if !appId.isEmpty {
      components?.queryItems = [URLQueryItem(name: "source_application", value: appId)]
    }
    guard let url = components?.url, UIApplication.shared.canOpenURL(url) else {
      result(false)
      return
    }
    UIPasteboard.general.setItems(
      [[stickerKey: image]],
      options: [.expirationDate: Date().addingTimeInterval(pasteboardLifetime)]
    )
    UIApplication.shared.open(url, options: [:]) { opened in
      result(opened)
    }
  }
}
