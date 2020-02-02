import 'package:flutter/material.dart';
import 'package:pushe_flutter/pushe.dart';

class PusheSampleWidget extends StatefulWidget {
  createState() => _PusheSampleState();
}

class _PusheSampleState extends State<PusheSampleWidget> {
  // Fields

  String statusText = "";
  var _scrollController = ScrollController();

  @override
  void initState() {
    _implementListeners();
    super.initState();
  }

  void _updateStatus(String text) async {
    setState(() {
      statusText =
          '$statusText \n --------------- \n $text \n ${DateTime.now()}';
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
      onButtonClicked: (notificationData, clickedButton) => _updateStatus(
          'Notification button clicked: $notificationData, $clickedButton'),
      onCustomContentReceived: (customContent) =>
          _updateStatus('Notification custom content received: $customContent'),
    );
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
          title: Text('Pushe sample'),
          centerTitle: true,
          bottom: PreferredSize(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Text('Flutter plugin: 2.0.3 | native version: 2.0.4',
                    style: TextStyle(color: Colors.white)),
              ),
              preferredSize: null),
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
                color: Colors.blue,
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
                                style: TextStyle(color: Colors.black))))),
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
                onTap: () => values[itemText](), // call it's action
                child: Card(
                    elevation: 2,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                        child: Text(itemText,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15.0)))),
              )),
        );
      }).toList(),
    );
  }

  Future<void> alert(Function onOK,
      {String title: 'Pushe', String message: 'Do you accept?'}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                onOK();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Nope'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> getInfo(Function(String) onOK,
      {String title: 'Pushe',
      String message: 'Do you accept?',
      String ok: 'OK',
      String no: 'Nope',
      Function(String) onNo}) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        var result = "";
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                TextFormField(
                  decoration: InputDecoration(hintText: title),
                  onChanged: (text) {
                    result = text;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(ok),
              onPressed: () async {
                Navigator.of(context).pop();
                await onOK(result);
              },
            ),
            FlatButton(
              child: Text(no),
              onPressed: () async {
                Navigator.of(context).pop();
                await onNo?.call(result);
              },
            )
          ],
        );
      },
    );
  }

  ///
  /// All possible actions which come into the list
  Map<String, Function> _getActions() {
    return {
      "IDs": () async {
        alert(() {}, title: 'IDs', message: """
      AndroidId:
      ${await Pushe.getAndroidId()},
      GoogleAdId:
      ${await Pushe.getGoogleAdvertisingId()},
      """);
      },
      "Custom ID": () async {
        await getInfo((text) {
          Pushe.setCustomId(text);
          _updateStatus('CustomId is $text');
        },
            title: 'New customId',
            message: 'Current customId: ${await Pushe.getCustomId()}');
      },
      "PhoneNumber": () async {
        await getInfo((text) {
          Pushe.setUserPhoneNumber(text);
          _updateStatus('PhoneNumber is $text');
        },
            title: 'New PhoneNumber',
            message:
                'Current PhoneNumber: ${await Pushe.getUserPhoneNumber()}');
      },
      "Email": () async {
        await getInfo((text) {
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
            (text) {
              Pushe.subscribe(text, callback: () {
                _updateStatus('Subscribed to $text');
              });
            },
            title: 'Topic',
            message: """
        Topics: ${(await Pushe.getSubscribedTopics()).toString()}
        Enter topic name to subscribe or unsubscribe:
        """,
            ok: 'Subscribe',
            no: 'Unsubscribe',
            onNo: (text) {
              Pushe.unsubscribe(text, callback: () {
                _updateStatus('Unsubscribed from $text');
              });
            });
      },
      "Tag (name:value)": () async {
        await getInfo(
            (text) {
              var parts = text.split(":");
              if (parts.length != 2) return;
              Pushe.addTags({parts[0]: parts[1]}, callback: () {
                _updateStatus('Tag ${parts[0]} added');
              });
            },
            title: 'Topic',
            message: """
        Tags:
        ${(await Pushe.getSubscribedTags()).toString()}
        Tag in name:value format (add)
        Tag in name1,name2 format (remove)
        """,
            ok: 'Add',
            no: 'Remove',
            onNo: (text) {
              var parts = text.split(",");
              if (parts == null || parts.isEmpty) return;
              Pushe.removeTags(parts, callback: () {
                _updateStatus('Tags $parts removed');
              });
            });
      },
      "Analytics: Event": () async {
        await getInfo((text) {
          Pushe.sendEvent(text);
          _updateStatus('Sending event: $text');
        }, title: 'Event', message: 'Type event name to send');
      },
      "Analytics: Ecommerce": () async {
        await getInfo((text) {
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
      "Notification: AndroidId": () async {
        await getInfo(
            (text) async {
              Pushe.sendNotificationToUser(IdType.AndroidId,
                  await Pushe.getAndroidId(), 'Title for me', 'Content for me');
              _updateStatus('Sending notification to this device');
            },
            title: 'Notification',
            message:
                'Enter androidId to send a simple notification to the user',
            ok: 'Send to me',
            no: 'Send to ...',
            onNo: (text) {
              Pushe.sendNotificationToUser(
                  IdType.AndroidId, text, 'Test title', 'Test content');
              _updateStatus('Sending notification to AndroidId: $text');
            });
      },
      "Notification: GoogleAdId": () async {
        await getInfo(
            (text) async {
              Pushe.sendNotificationToUser(
                  IdType.GoogleAdvertisingId,
                  await Pushe.getGoogleAdvertisingId(),
                  'Title for me',
                  'Content for me');
              _updateStatus('Sending notification to this device');
            },
            title: 'Notification',
            message:
                'Enter GoogleAdID to send a simple notification to the user',
            ok: 'Send to me',
            no: 'Send to ...',
            onNo: (text) {
              Pushe.sendNotificationToUser(IdType.GoogleAdvertisingId, text,
                  'Test title', 'Test content');
              _updateStatus('Sending notification to GoogleAdID: $text');
            });
      },
      "Notification: CustomId": () async {
        await getInfo(
            (text) {
              Pushe.getCustomId().then((value) {
                if (value == null || value.isEmpty) {
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
            ok: 'Send to me',
            no: 'Send to ...',
            onNo: (text) {
              Pushe.sendNotificationToUser(
                  IdType.CustomId, text, 'Test title', 'Test content');
              _updateStatus('Sending notification to CustomId: $text');
            });
      }
    };
  }
}
