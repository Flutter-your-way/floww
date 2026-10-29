import Flutter
import HealthKit
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: HealthKitChannel.name) {
      HealthKitChannel.register(with: registrar)
    }
  }
}

final class HealthKitChannel {
  static let name = "HealthKitChannel"
  private static let channelName = "floww/health_kit"
  private static let authorizeMethod = "requestAuthorization"
  private static let samplesMethod = "samples"
  private static let store = HKHealthStore()

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case authorizeMethod:
        requestAuthorization(result: result)
      case samplesMethod:
        guard
          let args = call.arguments as? [String: Any],
          let key = args["type"] as? String,
          let from = args["from"] as? NSNumber,
          let to = args["to"] as? NSNumber
        else {
          result([])
          return
        }
        samples(
          key: key,
          from: Date(timeIntervalSince1970: from.doubleValue / 1000),
          to: Date(timeIntervalSince1970: to.doubleValue / 1000),
          result: result
        )
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static var readTypes: Set<HKObjectType> {
    var types = Set<HKObjectType>()
    for key in ["vo2Max", "heartRateRecovery"] {
      if let type = quantity(for: key)?.type {
        types.insert(type)
      }
    }
    return types
  }

  private static func quantity(for key: String) -> (type: HKQuantityType, unit: HKUnit)? {
    switch key {
    case "vo2Max":
      guard let type = HKObjectType.quantityType(forIdentifier: .vo2Max) else { return nil }
      let unit = HKUnit.literUnit(with: .milli)
        .unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute()))
      return (type, unit)
    case "heartRateRecovery":
      if #available(iOS 16.0, *),
        let type = HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)
      {
        return (type, HKUnit.count().unitDivided(by: .minute()))
      }
      return nil
    default:
      return nil
    }
  }

  private static func requestAuthorization(result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable(), !readTypes.isEmpty else {
      result(false)
      return
    }
    store.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
      DispatchQueue.main.async { result(success) }
    }
  }

  private static func samples(key: String, from: Date, to: Date, result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable(), let quantity = quantity(for: key) else {
      result([])
      return
    }
    let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: [])
    let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
    let query = HKSampleQuery(
      sampleType: quantity.type,
      predicate: predicate,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: [sort]
    ) { _, samples, _ in
      let values: [[String: Any]] = (samples as? [HKQuantitySample] ?? []).map { sample in
        [
          "value": sample.quantity.doubleValue(for: quantity.unit),
          "date": Int(sample.endDate.timeIntervalSince1970 * 1000),
        ]
      }
      DispatchQueue.main.async { result(values) }
    }
    store.execute(query)
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
