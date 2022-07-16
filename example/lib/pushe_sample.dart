import 'package:flutter/material.dart';
import 'package:pushe_example/utils.dart';
import 'package:pushe_flutter/pushe.dart';

/// The function is a top level which runs in another isolate.
/// This function must be top level or static, since it has to be independent of any class.
/// [message] is a map which has either 'data', 'json' or 'button' depending on event type.
///    if the type is 'receive', 'click' or 'dismiss', it will have data (which customContent is part of it).
///    if the type is 'customContent' it will have only 'json'.
///    if the type is 'buttonClick', it will contain 'data' and 'button'.
pusheBackgroundMessageHandler(String eventType, dynamic message) {
  switch (eventType) {
    case Pushe.notificationReceived:
      var notificationData = NotificationData.fromDynamic(message);
      print('Pushe - Notification received in background $notificationData');
      break;
    case Pushe.notificationClicked:
      var notificationData = NotificationData.fromDynamic(message);
      print('Pushe - Notification clicked in background $notificationData');
      break;
    case Pushe.notificationDismissed:
      var notificationData = NotificationData.fromDynamic(message);
      print('Pushe - Notification dismissed in background $notificationData');
      break;
    case Pushe.notificationButtonClicked:
      var notificationData = NotificationData.fromDynamic(message)!;
      print(
          'Pushe - Notification button clicked in background $notificationData & clicked button is ${notificationData.clickedButton}');
      break;
    case Pushe.customContentReceived:
      // Message is a map and can not be parsed
      print('Pushe - Custom content received in background $message');
      break;
  }
}

class PusheSampleWidget extends StatefulWidget {
  createState() => _PusheSampleState();
}

class _PusheSampleState extends State<PusheSampleWidget> {
  // Fields

  String statusText = "";
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _implementListeners();
  }

  void _updateStatus(String text) async {
    setState(() {
      statusText = '$statusText \n  \n $text \n ${DateTime.now()}';
    });
  }

  void _implementListeners() {
    Pushe.setNotificationListener(
        onReceived: (notificationData) =>
            _updateStatus('Notification received: $notificationData'),
        onClicked: (notificationData) =>
            _updateStatus('Notification clicked: $notificationData'),
        onDismissed: (notificationData) =>
            _updateStatus('Notification dismissed: $notificationData'),
        onButtonClicked: (notificationData) => _updateStatus(
            'Notification button clicked: $notificationData, ${notificationData!.clickedButton}'),
        onCustomContentReceived: (customContent) => _updateStatus(
            'Notification custom content received: $customContent'),
        // This function only works in background
        onBackgroundNotificationReceived: pusheBackgroundMessageHandler);
  }

  void _clearStatus() {
    setState(() {
      statusText = "";
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  // All managing functions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pushe flutter'),
          centerTitle: true,
          bottom: PreferredSize(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Text('Flutter plugin: 2.5.2',
                    style: TextStyle(color: Colors.white)),
              ),
              preferredSize: Size.fromHeight(0)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: _getList(_getActions()),
              ),
              flex: 8,
            ),
            Flexible(
              child: Divider(
                height: 16.0,
                color: Colors.blueGrey,
              ),
              flex: 1,
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: GestureDetector(
                            onDoubleTap: _clearStatus,
                            child: Text(statusText,
                                style: TextStyle(color: Colors.blueGrey))))),
              ),
              flex: 6,
            )
          ],
        ));
  }

  Widget _getList(Map<String, Function> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: values.keys.map((itemText) {
        return Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: InkWell(
                onTap: () => values[itemText]!(), // call it's action
                child: Card(
                    elevation: 2,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                        child: Text(itemText,
                            style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0)))),
              )),
        );
      }).toList(),
    );
  }

  ///
  /// All possible actions which come into the list
  ///
  Map<String, Function> _getActions() {
    return {
      "IDs": () async {
        alert(context, () {},
            title: 'IDs',
            message:
                "DeviceId:\n${await Pushe.getDeviceId()}\n\nGoogleAdId:\n${await Pushe.getAdvertisingId()}");
      },
      "Custom ID": () async {
        await getInfo(context, (text) {
          Pushe.setCustomId(text);
          _updateStatus('CustomId is $text');
        },
            title: 'New customId',
            message: 'Current customId: ${await Pushe.getCustomId()}');
      },
      "PhoneNumber": () async {
        await getInfo(context, (text) {
          Pushe.setUserPhoneNumber(text);
          _updateStatus('PhoneNumber is $text');
        },
            title: 'New PhoneNumber',
            message:
                'Current PhoneNumber: ${await Pushe.getUserPhoneNumber()}');
      },
      "Email": () async {
        await getInfo(context, (text) {
          Pushe.setUserEmail(text);
          _updateStatus('Email is $text');
        },
            title: 'New Email',
            message: 'Current Email: ${await Pushe.getUserEmail()}');
      },
      "Module intiatization status": () async {
        _updateStatus('Modules initialzed: ${await Pushe.isInitialized()}');
      },
      "Module Registration status": () async {
        _updateStatus('Device Registered: ${await Pushe.isRegistered()}');
      },
      "Topic": () async {
        await getInfo(
            context,
            (text) {
              Pushe.subscribe(text, callback: () {
                _updateStatus('Subscribed to $text');
              });
            },
            title: 'Topic',
            message: """
Topics: ${(await Pushe.getSubscribedTopics()).toString()}\n
Enter topic name to subscribe or unsubscribe:
        """,
            positive: 'Subscribe',
            negative: 'Unsubscribe',
            onNegative: (text) {
              Pushe.unsubscribe(text, callback: () {
                _updateStatus('Unsubscribed from $text');
              });
            });
      },
      "Notification channel": () async {
        await getInfo(
            context,
            (text) {
              // Create (only name and Id)
              var parts = text.split(":");
              if (parts.length != 2) {
                _updateStatus("Enter id and name in id:name format");
                return;
              }

              var id = parts[0];
              var name = parts[1];
              Pushe.createNotificationChannel(id, name);
              _updateStatus("Create notification channel $name");
            },
            title: "Channel",
            message:
                'Enter channel id and name in id:name format and tap create to create a channel\nOr enter channel id and tap remove to remove a channel',
            positive: 'Create',
            negative: "Remove",
            onNegative: (text) {
              var id = text;
              Pushe.removeNotificationChannel(id);
              _updateStatus('Remove notification channel with id $id');
            });
      },
      "Tag (name:value)": () async {
        await getInfo(
            context,
            (text) {
              var parts = text.split(":");
              if (parts.length != 2) return;
              Pushe.addTags({parts[0]: parts[1]}, callback: () {
                _updateStatus('Tag ${parts[0]} added');
              });
            },
            title: 'Tag',
            message: """
        Tags:
        ${(await Pushe.getSubscribedTags()).toString()}
        Tag in name:value format (add)
        Tag in name1,name2 format (remove)
        """,
            positive: 'Add',
            negative: 'Remove',
            onNegative: (text) {
              var parts = text.split(",");
              if (parts.isEmpty) return;
              Pushe.removeTags(parts, callback: () {
                _updateStatus('Tags $parts removed');
              });
            });
      },
      "Analytics: Event": () async {
        await getInfo(context, (text) {
          Pushe.sendEvent(text);
          _updateStatus('Sending event: $text');
        }, title: 'Event', message: 'Type event name to send');
      },
      "Analytics: Ecommerce": () async {
        await getInfo(context, (text) {
          var parts = text.split(":");
          if (parts.length != 2) return;
          try {
            Pushe.sendEcommerceData(parts[0], double.parse(parts[1]));
            _updateStatus(
                'Sending Ecommerce data with name ${parts[0]} and price ${parts[1]}');
          } catch (e) {
            _updateStatus('Enter valid price (price is double)');
          }
        },
            title: 'Ecommerce',
            message: 'Enter value in name:price format to send data');
      },
      "Notification: DeviceId": () async {
        await getInfo(
            context,
            (text) async {
              Pushe.sendNotificationToUser(IdType.DeviceId,
                  await Pushe.getDeviceId(), 'Title for me', 'Content for me');
              _updateStatus('Sending notification to this device');
            },
            title: 'Notification',
            message:
                'Enter androidId to send a simple notification to the user',
            positive: 'Send to me',
            negative: 'Send to ...',
            onNegative: (text) {
              Pushe.sendNotificationToUser(
                  IdType.DeviceId, text, 'Test title', 'Test content');
              _updateStatus('Sending notification to AndroidId: $text');
            });
      },
      "Notification: GoogleAdId": () async {
        await getInfo(
            context,
            (text) async {
              Pushe.sendNotificationToUser(
                  IdType.AdvertisingId,
                  await Pushe.getAdvertisingId(),
                  'Title for me',
                  'Content for me');
              _updateStatus('Sending notification to this device');
            },
            title: 'Notification',
            message:
                'Enter GoogleAdID to send a simple notification to the user',
            positive: 'Send to me',
            negative: 'Send to ...',
            onNegative: (text) {
              Pushe.sendNotificationToUser(IdType.AdvertisingId, text,
                  'Test title', 'Test content');
              _updateStatus('Sending notification to Advertising ID: $text');
            });
      },
      "Notification: CustomId": () async {
        await getInfo(
            context,
            (text) {
              Pushe.getCustomId().then((value) {
                if (value.isEmpty) {
                  _updateStatus("Can not send by CustomID when there's none");
                  return;
                }
                Pushe.sendNotificationToUser(
                    IdType.CustomId, value, 'Title for me', 'Content for me');
                _updateStatus('Sending notification to this device');
              });
            },
            title: 'Notification',
            message: 'Enter CustomId to send a simple notification to the user',
            positive: 'Send to me',
            negative: 'Send to ...',
            onNegative: (text) {
              Pushe.sendNotificationToUser(
                  IdType.CustomId, text, 'Test title', 'Test content');
              _updateStatus('Sending notification to CustomId: $text');
            });
      },
      "Enable/Disable notification": () async {
        await alert(
            context,
            () {
              Pushe.setNotificationOn();
              _updateStatus("Notifications will be shown");
            },
            title: 'Notification',
            message:
                'Current status: ${await Pushe.isNotificationOn() ? "Enabled" : "Disabled"}\nDo you want to enable or disable notification publishing?',
            ok: 'Enable',
            no: 'Disable',
            onNo: () {
              Pushe.setNotificationOff();
              _updateStatus("Notifications won't be shown if received");
            });
      },
      "Enable/Disable custom sound": () async {
        await alert(
            context,
            () {
              Pushe.enableCustomSound();
              _updateStatus('Custom sound will be played if received');
            },
            title: 'Custom sound',
            message:
                'Current status: ${await Pushe.isCustomSoundEnabled() ? "Enabled" : "Disabled"}\nDo you want to enable or disable custom sound for notification?',
            ok: 'Enable',
            no: 'Disable',
            onNo: () {
              Pushe.disableCustomSound();
              _updateStatus("Custom sound won't be played if received");
            });
      },
      "Fcm Token": () async {
        var fcm = await Pushe.getFcmToken();
        var activeService = await Pushe.getActiveService();
        alert(context, () {}, title: 'Tokens', message: '''
Fcm: $fcm
Active: $activeService
        ''');
      },
      "Hms Token": () async {
        var hms = await Pushe.getHmsToken();
        var activeService = await Pushe.getActiveService();
        alert(context, () {}, title: 'Tokens', message: '''
Hms: $hms
Active: $activeService
        ''');
      },
      "Notification: Toggle foreground awareness": () async {
        if(await Pushe.isForceForegroundAware()) {
          await Pushe.disableNotificationForceForegroundAware();
        } else {
          await Pushe.enableNotificationForceForegroundAware();
        }
        _updateStatus("Forced awareness to ${await Pushe.isForceForegroundAware()}");
      },
      "ReImplement listeners": () {
        _updateStatus('Listeners re-implemented');
        _implementListeners();
      }
    };
  }
}
