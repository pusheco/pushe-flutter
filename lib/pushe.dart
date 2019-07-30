import 'dart:async';

import 'package:flutter/services.dart';

///
/// @author Mahdi Malvandi
class Pushe {
  static const MethodChannel _channel = const MethodChannel('Pushe');
  
  static Future<void> initialize({showDialog: true}) async => await _channel.invokeMethod('Pushe#initialize');

  static Future<String> getPusheId() async => await _channel.invokeMethod("Pushe#getPusheId");

  static Future<void> subscribe(String topic) async => await _channel.invokeMethod("Pushe#subscribe", {"topic":topic});

  static Future<void> unsubscribe(String topic) async => await _channel.invokeMethod("Pushe#unsubscribe", {"topic":topic});

  static Future<void> setNotificationOff() async => await _channel.invokeMethod("Pushe#setNotificationOff");

  static Future<void> setNotificationOn() async => await _channel.invokeMethod("Pushe#setNotificationOn");

  static Future<bool> isPusheInitialized() async => await _channel.invokeMethod("Pushe#isPusheInitialized");

  static Future<void> initializeNotificationListeners(bool enabled) async {
    print('Setting callback stuff');
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod("Pushe#initializeNotificationListeners", {"enabled":enabled});
  }

  static Future<Null> _handleMethod(MethodCall call) async {
    print('Handling called method, method: ${call.method}');

    if (call.method == 'Pushe#onNotificationReceived') {
      print('Notification received in flutter: ${call.arguments.toString()}');
    } else if (call.method == 'Pushe#onNotificationClicked') {
      print('Notification clicked in flutter: ${call.arguments}');
    }
    return null;
  }
}
