import 'package:flutter/material.dart';
import 'package:pushe/pushe.dart';

class PusheSampleWidget extends StatefulWidget {
  createState() => _PusheSampleState();
}

class _PusheSampleState extends State<PusheSampleWidget> {
  // Fields

  String statusText = "";

  @override
  void initState() {
    _implementListeners();
    super.initState();
  }

  void _updateStatus(String text) async {
    var result = "";

    switch (actions.indexOf(text)) {
      case 0:
        result = "Initializing";
        Pushe.initialize(showDialog: true);
        break;
      case 1:
        result = await Pushe.getPusheId();
        break;
      case 2:
        result = "Is Pushe initialized: " + (await Pushe.isPusheInitialized()).toString();
        break;
      case 3:
        result = "Subscribing to topic: sport";
        Pushe.subscribe('sport');
        break;
      case 4:
        result = "Unsubscribing from topic: sport";
        Pushe.unsubscribe('sport');
        break;
      case 5:
        result = 'Sending simple notif {"title":"title1","content":"content1"}';
        Pushe.sendSimpleNotifToUser(await Pushe.getPusheId(), 'title1', 'content1');
        break;
      case 6:
        result = 'Sending advanced notif {"title":"title1","content":"content1"}';
        Pushe.sendAdvancedNotifToUser(await Pushe.getPusheId(), '{"title":"title1","content":"content1"}');
        break;
      case 7:
        result = "Initializing notification listeners";
        Pushe.initializeNotificationListeners();
        break;
      default:
        result = text;
        break;
    }

    setState(() {
      statusText = '$statusText \n -------- \n $result';
    });
  }

  void _implementListeners() {
    Pushe.setOnNotificationClicked((notificationData) {
      _updateStatus('Notification clicked: $notificationData');
    });

    Pushe.setOnNotificationDismissed((notificationData) {
      _updateStatus('Notification dismissed: $notificationData');
    });

    Pushe.setOnNotificationReceived((notificationData) {
      _updateStatus('Notification received: $notificationData');
    });

    Pushe.setOnNotificationButtonClicked((notificationData, button) {
      _updateStatus('Notification button clicked: $notificationData, $button');
    });

    Pushe.setOnNotificationCustomContentReceived((content) {
      _updateStatus('Notification custom content received: $content');
    });
  }

  void _clearStatus() {
    setState(() {
      statusText = "";
    });
  }


  List<String> actions = [
    "Initialize manually",
    "Get Pushe ID",
    "Check initialization",
    "Subscribe to topic",
    "Unsubscribe from topic",
    "Send simple notification",
    "Send advanced notification",
    "Initialize listeners"
  ];

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
                child: Text('Flutter plugin: 0.3.0| native version: 1.6.3', style: TextStyle(color: Colors.white)),
              ),
              preferredSize: null),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: _getList(actions, (status) => _updateStatus(status)),
              ),
              flex: 8,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: GestureDetector(onDoubleTap: _clearStatus,child: Text(statusText, style: TextStyle(color: Colors.white))))
                ),
              ),
              flex: 2,
            )
          ],
        ));
  }

  Widget _getList(List<String> items, void Function(String) tap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.map((itemText) {
        return Padding(
          padding: EdgeInsets.all(4.0),
          child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: InkWell(
                onTap: () => tap(itemText),
                child: Card(
                    elevation: 2,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                        child: Text(itemText,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor ,
                                fontSize: 15.0
                            )
                        )
                    )
                ),
              )
          ),
        );
      }).toList(),
    );
  }
}
