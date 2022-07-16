import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

///
/// Enum: Notification id type
/// @author Mahdi Malvandi
///
enum IdType { DeviceId, AdvertisingId, CustomId }
enum EventAction { custom, sign_up, login, purchase, achievement, level }

void _pusheSetupBackgroundChannel() async {
  MethodChannel backgroundChannel =
      const MethodChannel('plus.pushe.co/pushe_flutter_background');
  // Setup Flutter state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // This is where the magic happens and we handle background events from the
  // native portion of the plugin.
  backgroundChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'handleBackgroundMessage') {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments['handle']);
      final Function? handlerFunction =
          PluginUtilities.getCallbackFromHandle(handle);
      try {
        var dataArg = call.arguments['message'];
        if (dataArg == null) {
          return;
        }
        Map wholeData = jsonDecode(dataArg);
        String? eventType = wholeData['type'];
        Map messageContent = (eventType == "custom_content"
            ? wholeData['json']
            : wholeData['data']) ?? {};

        await handlerFunction?.call(eventType, messageContent);
      } catch (e) {
        print('Pushe: Unable to handle incoming background message.\n$e');
      }
    }
    return Future.value();
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling handling messages.
  backgroundChannel.invokeMethod<void>('Pushe.platformInitialized');
}

///
/// @author Mahdi Malvandi
/// Main plugin class handling most of SDK's works.
///
class Pushe {
  // Static fields
  static const String notificationReceived = 'receive';
  static const String notificationClicked = 'click';
  static const String notificationDismissed = 'dismiss';
  static const String notificationButtonClicked = 'button_click';
  static const String customContentReceived = 'custom_content';

  // Notification Callback handlers
  static void Function(NotificationData?)? _receiveCallback;
  static void Function(NotificationData?)? _clickCallback;
  static void Function(NotificationData?)? _dismissCallback;
  static void Function(dynamic)? _customContentCallback;
  static void Function(NotificationData?)? _buttonClickCallback;


  static const MethodChannel _channel =
      const MethodChannel('plus.pushe.co/pushe_flutter');

  /// GDPR related
  /// You can use this function after getting user consent to initialize pushe lib
  /// for ios only: you must call this function in order to pushe to start working
  static Future<void> initialize() async {
    if(!Platform.isAndroid) return;
    await _channel.invokeMethod("Pushe.initialize");
  }

  /// GDPR related
  /// If user gave consent for collecting necessary extra data for Analytics.
  /// Simply call this function with True parameter
  /// the related task will be scheduled right away and will collect when needed.
  /// If for any reason user decided to undo his dialog action, or for some other reason, you wanted to cancel consent,
  /// Simply call this function with False parameter
  /// [enabled] enable or disable user consent for collecting extra data
  ///
  static Future<void> setUserConsentGiven(bool enabled) async {
    if(!Platform.isAndroid) return;
    return await _channel
        .invokeMethod("Pushe.setUserConsentGiven", {"enabled": enabled});
  }

  /// Get the user consent status
  static Future<bool> getUserConsentStatus() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.getUserConsentStatus");
  }

  ///
  /// Get the unique id of the devices
  /// Returns empty if native returned null
  ///
  static Future<String> getDeviceId() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getDeviceId") ?? "";
  }

  @Deprecated('Use `getDeviceId` instead')
  static Future<String> getAndroidId() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getAndroidId") ?? "";
  }

  // android only
  /// Get google advertising id
  ///
  /// **NOTE**: Since late 2021, if the user opted out of Ad personalization this id will be a bunch of zeros
  @Deprecated("Use `getAdvertisingId` instead")
  static Future<String> getGoogleAdvertisingId() async {
    if(!Platform.isAndroid) return "";

    return await _channel.invokeMethod("Pushe.getGoogleAdvertisingId") ?? "";
  }

  ///
  /// Return GoogleAdvertisingId (if using FCM) or AOID (if using HMS)
  ///
  /// **NOTE**: Since late 2021, if user opts out of Ad personalization, FCM ad_id will return bunch of zeros or empty
  static Future<String> getAdvertisingId() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getAdvertisingId") ?? "";
  }

  /// Get custom id
  static Future<String> getCustomId() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getCustomId") ?? "";
  }

  /// Set custom id
  static Future<void> setCustomId(String id) async {
    if(!Platform.isAndroid) return;
    return await _channel.invokeMethod("Pushe.setCustomId", {"id": id});
  }

  /// Get email
  static Future<String> getUserEmail() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getUserEmail") ?? "";
  }

  /// Set email
  static Future<void> setUserEmail(String email) async {
    if(!Platform.isAndroid) return;
    return await _channel.invokeMethod("Pushe.setUserEmail", {"email": email});
  }

  /// Get user phone number
  static Future<String> getUserPhoneNumber() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getUserPhoneNumber") ?? "";
  }

  /// Set user phone number
  static Future<void> setUserPhoneNumber(String phone) async {
    if(!Platform.isAndroid) return;
    return await _channel.invokeMethod("Pushe.setUserPhoneNumber", {"phone": phone});
  }

  /// Add tags.
  /// [tags] key-value pairs
  /// [callback] is an optional function that will be called with result of adding tags.
  static Future<void> addTags(Map<String, String> tags,
      {Function? callback}) async {
    if(!Platform.isAndroid) return;
    if (await (_channel.invokeMethod("Pushe.addTags", {"tags": tags}))) {
      callback?.call();
    }
    return;
  }

  /// Remove tags.
  /// [tags] list of tag keys to remove
  /// [callback] is an optional function that will be called with result of removing tags.
  static Future<void> removeTags(List<String> tags, {Function? callback}) async {
    if(!Platform.isAndroid) return;
    try {
      if (await (_channel.invokeMethod("Pushe.removeTags", {"tags": tags}))) {
        callback?.call();
      }
    } catch(ignored) {}
    return;
  }

  /// Get subscribed tags
  static Future<Map> getSubscribedTags() async {
    if(!Platform.isAndroid) return {};
    return await _channel.invokeMethod("Pushe.getSubscribedTags") ?? {};
  }

  /// Get subscribed topics
  static Future<List> getSubscribedTopics() async {
    if(!Platform.isAndroid) return [];
    return await _channel.invokeMethod("Pushe.getSubscribedTopics") ?? [];
  }

  /// Subscribe to a topic.
  /// [topic] is the name of that topic. The naming rules must follow FCM topic naming standards.
  /// [callback] is an optional function that will be called with result of subscription.
  static Future<void> subscribe(String topic, {Function? callback}) async {
    if(!Platform.isAndroid) return;
    try {
      if (await (_channel.invokeMethod("Pushe.subscribe", {"topic": topic}))) {
        callback?.call();
      }
    } catch (ignored) {
      return;
    }
    return;
  }

  /// Unsubscribe from a topic already subscribed.
  /// [topic] is the name of that topic. The naming rules must follow FCM topic naming standards.
  /// [callback] is an optional function that will be called with result of Unsubscription.
  static Future<void> unsubscribe(String topic, {Function? callback}) async {
    if(!Platform.isAndroid) return;
    try {
      if (await (_channel.invokeMethod("Pushe.unsubscribe", {"topic": topic}))) {
        callback?.call();
      }
    } catch(ignored) {
    }
    return;
  }

  /// If this function is called, notification will not be shown.
  static Future<void> setNotificationOff() async {
    if(!Platform.isAndroid) return;
    await _channel.invokeMethod("Pushe.disableNotifications");
  }

  /// Default of notification is set to On, if you have set it off, you can revert it using this function.
  static Future<void> setNotificationOn() async {
    if(!Platform.isAndroid) return;
    await _channel.invokeMethod("Pushe.enableNotifications");
  }

  /// To check whether notification will publish or not (default is true of course)
  static Future<bool> isNotificationOn() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.isNotificationEnable") ?? true;
  }

  /// Custom sound is enabled by default. If you wanted to disable it and use the default sound (like for avoiding downloading sound) you can disable it.
  static Future<void> disableCustomSound() async {
    if(!Platform.isAndroid) return;
    await _channel.invokeMethod("Pushe.disableCustomSound");
  }

  /// Custom sound is enabled by default. However, if you have turned it off, you can revert it using this function
  static Future<void> enableCustomSound() async {
    if(!Platform.isAndroid) return;
    await _channel.invokeMethod("Pushe.enableCustomSound");
  }

  /// To check whether custom sound is already enabled or not
  static Future<bool> isCustomSoundEnabled() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.isCustomSoundEnabled") ?? true;
  }

  /// Enables force to avoid displaying notification when the app is open
  /// Instead only listeners will be called
  static Future<bool> enableNotificationForceForegroundAware() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.enableForceForegroundAware") ?? false;
  }

  /// Disables the behaviour set by `enableNotificationForceForegroundAware`
  static Future<bool> disableNotificationForceForegroundAware() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.disableForceForegroundAware") ?? false;
  }

  /// Returns true if foreground notification are published by force, false otherwise
  static Future<bool> isForceForegroundAware() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.isForceForegroundAware") ?? false;
  }

  // region FCM and HMS

  /// @return either `hms` or `fcm` or empty result if none of them were available.
  /// **NOTE**: If anything was wrong in initialization, this may never return result
  static Future<String> getActiveService() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod('Pushe.getActiveCourier') ?? "";
  }

  /// @return Token of Firebase cloud messaging used by Pushe
  /// and empty if anything was wrong or active service wasn't FCM
  static Future<String> getFcmToken() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getFcmToken") ?? "";
  }

  /// @return Token of Huawei PushKit used by Pushe
  /// and empty if anything was wrong or active service wasn't HMS
  ///
  /// **NOTE**: HMS is an optional instance and you need to enable it by adding
  /// `implementation("co.pushe.plus:hms:$latest")` in `dependencies {}` of `android/build.gradle`
  static Future<String> getHmsToken() async {
    if(!Platform.isAndroid) return "";
    return await _channel.invokeMethod("Pushe.getHmsToken") ?? "";
  }

  // endregion

  /// Creates a channel using native API. Read more about channel at https://developer.android.com/training/notify-user/channels
  /// You can send notifications through only one channel, so users that have created that channel in their devices, can receive it,
  ///    while rest of them can not.
  /// For android versions lower than 8.0 (API 26), this method has no function
  static Future<void> createNotificationChannel(
      String channelId, String channelName,
      {String? description,
      int? importance,
      bool? enableLight,
      bool? enableVibration,
      bool? showBadge,
      int? ledColor,
      List<int>? vibrationPattern}) async {
    if(!Platform.isAndroid) return;
    var args = {};
    args['channelId'] = channelId;
    args['channelName'] = channelName;
    args['description'] = description;
    args['importance'] = importance;
    args['enableLight'] = enableLight;
    args['enableVibration'] = enableVibration;
    args['showBadge'] = showBadge;
    args['ledColor'] = ledColor;
    args['vibrationPattern'] = vibrationPattern;

    return _channel.invokeMethod("Pushe.createNotificationChannel", args);
  }

  /// Remove the channel Id that was created
  /// For android versions lower than 8.0 (API 26), this method has no function
  static Future<void> removeNotificationChannel(String channelId) async {
    if(!Platform.isAndroid) return;
    return await _channel.invokeMethod(
        "Pushe.removeNotificationChannel", {"channelId": channelId});
  }

  /// Check if Pushe is initialized to server or not.
  static Future<bool> isInitialized() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.isInitialized") ?? false;
  }

  /// Check if Pushe is registered to server or not.
  static Future<bool> isRegistered() async {
    if(!Platform.isAndroid) return false;
    return await _channel.invokeMethod("Pushe.isRegistered") ?? false;
  }

  /// Call it's callback when registration is completed
  static Future<void> setRegistrationCompleteListener(Function callback) async {
    if(!Platform.isAndroid) return;
    dynamic result =
        await _channel.invokeMethod("Pushe.setRegistrationCompleteListener") ?? false;
    if (result) callback.call();
    return;
  }

  /// Call it's callback when initialization is completed
  static Future<void> setInitializationCompleteListener(
      Function callback) async {
    if(!Platform.isAndroid) return;
    dynamic result =
        await _channel.invokeMethod("Pushe.setInitializationCompleteListener");
    if (result) callback.call();
    return;
  }

  ///
  /// Sending notification from this device to another device which is registered as a user of this app.
  /// [type] is the type of unique id which you are passing
  /// [id] is the id of the type [type]
  /// [title] is the title of the notification
  /// [content] is the content of the notification
  /// [bigTitle] is the complete title of the notification
  /// [bigContent] is the complete content of the notification
  /// [imageUrl] is the url of the image which notification can contain
  /// [iconUrl] is the url of the notification icon
  /// [customContent] is the custom json you send along with the notification message which can be received as the notification customContent in the target device
  static Future<void> sendNotificationToUser(
      IdType type, String id, String title, String content,
      {String? bigTitle,
      String? bigContent,
      String? imageUrl,
      String? iconUrl,
      String? notificationIcon,
      dynamic customContent}) async {
    if(!Platform.isAndroid) return;
    String idType = type.toString();
    await _channel.invokeMethod('Pushe.sendUserNotification', {
      "type": idType,
      "id": id,
      "title": title,
      "content": content,
      "bigTitle": bigTitle,
      "bigContent": bigContent,
      "imageUrl": imageUrl,
      "iconUrl": iconUrl,
      "notifIcon": notificationIcon,
      "customContent": jsonEncode(customContent)
    });
    return;
  }

  static Future<void> sendAdvancedNotificationToUser(
      IdType type, String id, String json) async {
    if(!Platform.isAndroid) return;
    String idType = type.toString();
    await _channel.invokeMethod('Pushe.sendAdvancedUserNotification',
        {"type": idType, "id": id, "advancedJson": jsonEncode(json)});
    return;
  }

  ///Send an event
  ///[name] is the name of event that wants to send
  /// Possible option: SendEvent
  static Future<void> sendEvent(String name,
      {EventAction action: EventAction.custom, dynamic data}) async {
    if(!Platform.isAndroid) return;
    var arguments = {};
    arguments['name'] = name;
    arguments['action'] = action.toString();
    if (data != null) {
      arguments['data'] = data;
    }

    return await _channel.invokeMethod("Pushe.sendEvent", arguments);
  }

  /// Send ecommerce data.
  /// [name] is the name of ecommerce data
  /// [price] is the value of ecommerce name
  static Future<void> sendEcommerceData(String name, double price,
      {String? category, int? quantity}) async {
    if(!Platform.isAndroid) return;
    var args = {};
    args['name'] = name;
    args['price'] = price;
    if (category != null) {
      args['category'] = category;
    }
    if (quantity != null) {
      args['quantity'] = quantity;
    }
    return await _channel.invokeMethod("Pushe.sendEcommerceData", args);
  }

  /// Set callbacks for different types of events for notifications (in foreground or when app is open in the background)
  /// [onReceived] is called when notification was received.
  /// [onClicked] is called when notification was clicked.
  /// [onDismissed] is called when notification was swiped away.
  /// [onButtonClicked] is called when notification contains button and a button was clicked.
  /// [onCustomContentReceived] is called when notification includes custom json. It will a json in string format.
  /// [onBackgroundNotificationReceived] is the function that will be called when notification is received in the background,
  ///   this would be a **TopLevel** or **Static** function will be passed and saved for later usage.
  ///   Function will take a dynamic value which is a dictionary (aka Map), which contains 'type' (one of receive, click, button_click, custom_content, dismiss),
  ///   and the 'data' either a custom map (provided as customContent), the notification, or the notification and the button (in case of button click)
  ///   In addition, the Isolate of the top level function is different and it will not have access to any widget (if app is in foreground, this does not get called and instead
  ///   foreground function will take place). So be aware of the isolate difference.
  static Future<void> setNotificationListener({
    Function(NotificationData?)? onReceived,
    Function(NotificationData?)? onClicked,
    Function(NotificationData?)? onDismissed,
    Function(NotificationData?)? onButtonClicked,
    Function(dynamic)? onCustomContentReceived,
    Function(String, dynamic)? onBackgroundNotificationReceived,
  }) async {
    if(!Platform.isAndroid) return;
    _receiveCallback = onReceived;
    _clickCallback = onClicked;
    _dismissCallback = onDismissed;
    _buttonClickCallback = onButtonClicked;
    _customContentCallback = onCustomContentReceived;
    _channel.setMethodCallHandler(_handleMethod);

    // In case that application was not overrode and background was not used, this will be helpful (sets the listener after app is started which will not trigger background)
    _channel.invokeMethod("Pushe.initNotificationListenerManually");
    if (onBackgroundNotificationReceived != null) {
      // If background was set, get the handles to save
      final CallbackHandle? backgroundSetupHandle =
          PluginUtilities.getCallbackHandle(_pusheSetupBackgroundChannel);
      final CallbackHandle? backgroundMessageHandle =
          PluginUtilities.getCallbackHandle(onBackgroundNotificationReceived);
      // Callback must be exactly a top level or static and should be dependent to any inner scopes
      if (backgroundMessageHandle == null) {
        throw ArgumentError(
            '''Failed to setup background handle. `backgroundNotificationListener` must be a TOPLEVEL or a STATIC method.
       Checkout Flutter FAQ at https://docs.pushe.co for more information.
       ''');
      }
      _channel.invokeMethod<bool>(
        'Pushe.notificationListener',
        <String, dynamic>{
          'setupHandle': backgroundSetupHandle?.toRawHandle(),
          'backgroundHandle': backgroundMessageHandle.toRawHandle()
        },
      );
    }
    return;
  }

  ///
  /// For foreground notification, a broadcast receiver will send the stuff using channel to dart side,
  ///    thus, the channel in dart side must handle the messages which are received. This function will handle this job.
  /// If a method was called from native code through channel this will handle it.
  ///
  static Future<Null> _handleMethod(MethodCall call) async {
    if(!Platform.isAndroid) return;
    dynamic arg = jsonDecode(call.arguments);
    var callMethod = call.method;
    switch (callMethod) {
      case 'Pushe.onNotificationReceived':
        _receiveCallback?.call(NotificationData.fromDynamic(arg['data']));
        break;
      case 'Pushe.onNotificationClicked':
        _clickCallback?.call(NotificationData.fromDynamic(arg['data']));
        break;
      case 'Pushe.onNotificationButtonClicked':
        try {
          _buttonClickCallback?.call(NotificationData.fromDynamic(arg['data']));
        } catch (e) {
          print(
              'Pushe: Error passing notification data to callback ${e.toString()}');
        }
        break;
      case 'Pushe.onCustomContentReceived':
        try {
          var customContent = arg['json'];
          _customContentCallback?.call(customContent);
        } catch (e) {
          print('Pushe: Error passing customContent to callback');
        }
        break;
      case 'Pushe.onNotificationDismissed':
        _dismissCallback?.call(NotificationData.fromDynamic(arg['data']));
        break;
    }

    return null;
  }
}

// region Notification

///
/// Notification data class as an interface between native callback data classes and Flutter dart code.
/// When a notification event happens (like Receive), callbacks will hold instances of this class.
///
class NotificationData {
  String? _title,
      _content,
      _bigTitle,
      _bigContent,
      _summary,
      _imageUrl,
      _iconUrl;
  dynamic _customContent;
  List<NotificationButtonData>? _buttons;
  NotificationButtonData? _clickedButton;

  NotificationData.create(
      this._title,
      this._content,
      this._bigTitle,
      this._bigContent,
      this._summary,
      this._imageUrl,
      this._iconUrl,
      this._customContent,
      this._buttons,
      this._clickedButton);

  static NotificationData? fromDynamic(dynamic data) {
    try {
      List<NotificationButtonData>? notificationButtons;
      try {
        notificationButtons = NotificationButtonData.fromList(data['buttons']);
      } catch (e) {
        notificationButtons = null;
      }
      NotificationButtonData? clickedButton;
      try {
        clickedButton = NotificationButtonData.fromMap(data['clickedButton']);
      } catch (e) {
        clickedButton = null;
      }
      return NotificationData.create(
          data['title'],
          data['content'],
          data['bigTitle'],
          data['bigContent'],
          data['summary'],
          data['imageUrl'],
          data['iconUrl'],
          data['json'],
          notificationButtons,
          clickedButton);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() =>
      'NotificationData{_title: $_title, _content: $_content, _bigTitle: $_bigTitle, _bigContent: $_bigContent, _summary: $_summary, _imageUrl: $_imageUrl, _iconUrl: $_iconUrl, _customContent: $_customContent, buttons: $_buttons, clickedButton: $_clickedButton}';

  get customContent => _customContent;

  get iconUrl => _iconUrl;

  get imageUrl => _imageUrl;

  get summary => _summary;

  get bigContent => _bigContent;

  get bigTitle => _bigTitle;

  get content => _content;

  get title => _title;

  get buttons => _buttons;

  get clickedButton => _clickedButton;
}

///
/// When there are buttons in the notification they are accessible through callbacks.
/// For every button there would be an object in the callback notification data object.
/// And also when a button is clicked, it's id and text will be passes separately in `onNotificationButtonClicked` callback.

class NotificationButtonData {
  String? _title;
  String? _icon;

  NotificationButtonData.create(this._title, this._icon);

  String? get title => _title;

  String? get icon => _icon;

  @override
  String toString() => 'NotificationButtonData{_title: $_title, _icon: $_icon}';

  static NotificationButtonData? fromMap(dynamic data) {
    try {
      return NotificationButtonData.create(data['title'], data['icon']);
    } catch (e) {
      return null;
    }
  }

  static List<NotificationButtonData> fromList(dynamic buttons) {
    List<dynamic> list = buttons;
    List<NotificationButtonData> buttonDataList = [];
    for (var i in list) {
      buttonDataList.add(NotificationButtonData.create(i['title'], i['icon']));
    }
    return buttonDataList;
  }
}

// endregion
