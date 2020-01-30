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
    var result = "";

    switch (actions.indexOf(text)) {
      case 0:
        result = 'Pushe id: ${await Pushe.getAndroidId()}';
        break;
      case 1:
        result = "Is Pushe initialized: " +
            (await Pushe.isInitialized()).toString();
        break;
      case 2:
        result = "Is Pushe registered: " +
            (await Pushe.isRegistered()).toString();
        break;
      case 3:
        result = "Subscribe to topic: sport";
        Pushe.subscribe('sport',callback:(output) {
          if (output) setState(() {
            statusText =
            '$statusText \n --------------- \n Successfully subscribed to topic sport \n ${DateTime
                .now()}';
          });
        });

        break;
      case 4:
        result = "Unsubscribe from topic: sport";
        Pushe.unsubscribe('sport',callback:(output) {
          if (output) setState(() {
            statusText =
            '$statusText \n --------------- \n Successfully unsubscribed from topic sport \n ${DateTime
                .now()}';
          });
        });


        break;
      case 5:
        result = 'Sending simple notification with title:"title1",content:"content1"';
        Pushe.sendNotificationToUser(
            await Pushe.getAndroidId(), 'title1', 'content1');
        break;
      case 6:
        result = 'Sending event with name:"name1"';
        Pushe.sendEvent('name 1');
        break;
      case 7:
        result = 'Sending ecomment with name:"product1",price:"100"';
        Pushe.sendEcommerceData('product1',100);
        break;

      case 8:
        result = 'Add user type tag to premium';
        Pushe.addTags({'type':'premium'},callback:(output) {
          if (output) setState(() {
            statusText =
            '$statusText \n --------------- \n Successfully user type tag set to premium \n ${DateTime
                .now()}';
          });
        });
        break;

      case 9:
        result = 'Remove user type tag from user';
        Pushe.removeTags(['type'],callback:(output) {
          if (output) setState(() {
            statusText =
            '$statusText \n --------------- \n Successfully user type tag removed \n ${DateTime
                .now()}';
          });
        });
        break;

      case 10:
        result = 'Subscribed tags are as follow';

        var tags = await Pushe.getSubscribedTags();
        tags.forEach((k,v) => result = '$result \n --------------- \n key = $k and value = $v');

        break;

      case 11:
        result = 'Subscribed topics are as follow';

        var topics = await Pushe.getSubscribedTopics();
        topics.forEach((v) => result = '$result \n --------------- \n topic name is = $v');
        break;

      case 12:
        result = 'Google advertising id : ${await Pushe.getGoogleAdvertisingId()}';
        break;

      case 13:
        result = 'Custom id : ${await Pushe.getCustomId()}';
        break;

      case 14:
        result = 'Set custom id to id123 ';
        Pushe.setCustomId('id123');

        break;

      case 15:
        result = 'Email is : ${await Pushe.getUserEmail()}';
        break;

      case 16:
        result = 'Set Email to support@pushe.co';
        Pushe.setUserEmail('support@pushe.co');

        break;

      case 17:
        result = 'user phone number is : ${await Pushe.getUserPhoneNumber()}';
        break;

      case 18:
        result = 'Set user phone number to 09121234567';
        Pushe.setUserPhoneNumber('09121234567');
        break;

      default:
        result = text;
        break;
    }

    setState(() {
      statusText = '$statusText \n --------------- \n $result \n ${DateTime.now()}';
    });
  }

  void _implementListeners() {
    Pushe.setNotificationListener(
      onReceived: (notificationData) => _updateStatus('Notification received: $notificationData'),
      onClicked: (notificationData) => _updateStatus('Notification clicked: $notificationData'),
      onDismissed: (notificationData) => _updateStatus('Notification dismissed: $notificationData'),
      onButtonClicked: (notificationData, clickedButton) => _updateStatus('Notification button clicked: $notificationData, $clickedButton'),
      onCustomContentReceived: (customContent) => _updateStatus('Notification custom content received: $customContent'),
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

  List<String> actions = [
    "Get Pushe ID",
    "Check initialization",
    "Check registeration",
    "Subscribe to topic",
    "Unsubscribe from topic",
    "Send notification",
    "Send Event",
    "Send Ecommerce Data",
    "Add user type tag and set it's value to premium",
     "Remove user type tag",
    "Get subscribed tags",
    "Get subscribed topics",
    "Get google advertising id",
    "Get custom id",
    "Set custom id to id123",
    "Get user email",
    "Set user email to support@pushe.co",
    "Get user phone",
    "Set user phone number to 09121234567"

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
                child: Text('Flutter plugin: 2.0.2 | native version: 2.0.4',
                    style: TextStyle(color: Colors.white)),
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
                    decoration:
                        BoxDecoration(color:Colors.white),
                    child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: GestureDetector(
                            onDoubleTap: _clearStatus,
                            child: Text(statusText,
                                style: TextStyle(color: Colors.blue))))),
              ),
              flex: 6,
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
                                color: Theme.of(context).primaryColor,
                                fontSize: 15.0)
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
