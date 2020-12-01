import Flutter
import UIKit
import Pushe

public class SwiftPusheFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plus.pushe.co/pushe_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftPusheFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("<\(call.method)> requested")
    switch call.method {
    case "Pushe.initialize":
        PusheClient.shared.initialize()
    case "Pushe.getDeviceId":
        result(PusheClient.shared.getDeviceId())
    case "Pushe.getAdvertisingId":
        result(PusheClient.shared.getAdvertisingId())
    case "Pushe.setCustomId":
        let arguments = call.arguments as? [String: Any]
        let id = arguments?["id"] as? String
        PusheClient.shared.setCustomId(id: id)
    case "Pushe.getCustomId":
        result(PusheClient.shared.getCustomId())
    case "Pushe.setUserEmail":
        let arguments = call.arguments as? [String: Any]
        let email = arguments?["email"] as? String
        let _ = PusheClient.shared.setUserEmail(email: email)
    case "Pushe.getUserEmail":
        result(PusheClient.shared.getUserEmail())
    case "Pushe.setUserPhoneNumber":
        let arguments = call.arguments as? [String: Any]
        let phoneNumber = arguments?["phone"] as? String
        let _ = PusheClient.shared.setUserPhoneNumber(phoneNumber: phoneNumber)
    case "Pushe.getUserPhoneNumber":
        result(PusheClient.shared.getUserPhoneNumber())
    case "Pushe.addTags":
        guard let arguments = call.arguments as? [String: Any],
               let tags = arguments["tags"] as? [String: String] else { break }
        
        PusheClient.shared.addTags(with: tags)
    case "Pushe.removeTags":
        guard let arguments = call.arguments as? [String: Any],
              let tags = arguments["tags"] as? [String] else { break }
        
        PusheClient.shared.removeTags(with: tags)
    case "Pushe.getSubscribedTags":
        result(PusheClient.shared.getSubscribedTags())
    case "Pushe.subscribe":
        guard let arguments = call.arguments as? [String: Any],
              let topic = arguments["topic"] as? String else { break }
        
        PusheClient.shared.subscribe(to: topic)
    case "Pushe.unsubscribe":
        guard let arguments = call.arguments as? [String: Any],
              let topic = arguments["topic"] as? String else { break }
        
        PusheClient.shared.unsubscribe(from: topic)
    case "Pushe.getSubscribedTopics":
        result(PusheClient.shared.getSubscribedTopics())
    case "Pushe.isInitialized", "Pushe.isRegistered":
        result(PusheClient.shared.isRegistered())
    case "Pushe.sendEvent":
        guard let arguments = call.arguments as? [String: Any],
               let eventName = arguments["name"] as? String else { break }

        let action: EventAction
        switch arguments["action"] as? String {
        case "EventAction.sign_up":
            action = EventAction.signUp
        case "EventAction.login":
            action = EventAction.login
        case "EventAction.purchase":
            action = EventAction.purchase
        case "EventAction.achievement":
            action = EventAction.achievement
        case "EventAction.level":
            action = EventAction.level
        default:
            action = EventAction.custom
        }
        
        let data = arguments["data"] as? [String: Any]
        PusheClient.shared.sendEvent(event: Event(name: eventName, action: action, data: data))
    default:
        result("requested method <\(call.method)> not implemented")
    }
  }
}

