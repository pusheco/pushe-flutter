import 'dart:async';

import 'package:flutter/services.dart';

///
/// @author Mahdi Malvandi
///
class Pushe {

  // Callback handlers
  static void Function(String) _receiveCallback;
  static void Function(String) _clickCallback;
  static void Function(String) _dismissCallback;
  static void Function(String) _customContentCallback;
  static void Function(String, String) _buttonClickCallback;



  static const MethodChannel _channel = const MethodChannel('Pushe');
  
  static void initialize({showDialog: true}) => _channel.invokeMethod('Pushe#initialize', {"showDialog":showDialog});

  static Future<String> getPusheId() async => await _channel.invokeMethod("Pushe#getPusheId");

  static subscribe(String topic) => _channel.invokeMethod("Pushe#subscribe", {"topic":topic});

  static unsubscribe(String topic) => _channel.invokeMethod("Pushe#unsubscribe", {"topic":topic});

  static setNotificationOff() => _channel.invokeMethod("Pushe#setNotificationOff");

  static setNotificationOn() => _channel.invokeMethod("Pushe#setNotificationOn");

  static Future<bool> isPusheInitialized() async => await _channel.invokeMethod("Pushe#isPusheInitialized");

  static sendSimpleNotifToUser(String pusheId, String title, String content) => _channel.invokeMethod("Pushe#sendSimpleNotifToUser", {"pusheId":pusheId, "title":title, "content":content});

  static sendAdvancedNotifToUser(String pusheId, String notificationJson) => _channel.invokeMethod("Pushe#sendSimpleNotifToUser", {"pusheId":pusheId, "json":notificationJson});

  static initializeNotificationListeners() => _channel.setMethodCallHandler(_handleMethod);

  // callbacks
  static setOnNotificationReceived(Function(String) f) => _receiveCallback = f;
  static setOnNotificationClicked(Function(String) f) => _clickCallback = f;
  static setOnNotificationButtonClicked(Function(String, String) f) => _buttonClickCallback = f;
  static setOnNotificationCustomContentReceived(Function(String) f) => _customContentCallback = f;
  static setOnNotificationDismissed(Function(String) f) => _dismissCallback = f;



  ///
  /// If a method was called from native code through channel this will handle it.
  ///
  static Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'Pushe#onNotificationReceived') {
      print('Notification received in flutter: ${call.arguments.toString()}');
      _receiveCallback?.call(call.arguments);
    } else if (call.method == 'Pushe#onNotificationClicked') {
      print('Notification clicked in flutter: ${call.arguments}');
    _clickCallback?.call(call.arguments);
    } else if (call.method == 'Pushe#onNotificationButtonClicked') {
      print('Notification button clicked');
      _buttonClickCallback?.call(call.arguments, call.arguments);
    } else if (call.method == 'Pushe#onNotificationCustomContentReceived') {
      print('Notification custom content received: ${call.arguments}');
      _customContentCallback?.call(call.arguments);
    } else if (call.method == 'Pushe#onNotificationDismissed') {
      print('Notification was dismissed: ${call.arguments}');
      _dismissCallback?.call(call.arguments);
    }
    return null;
  }
}
