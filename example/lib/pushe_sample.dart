import 'package:flutter/material.dart';
import 'package:pushe/pushe.dart';


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
        result = "Subscribe to topic: sport";
        Pushe.subscribe('sport');
        break;
      case 3:
        result = "Unsubscribe from topic: sport";
        Pushe.unsubscribe('sport');
        break;
      case 4:
        result = 'Sending simple notification with title:"title1",content:"content1"';
        Pushe.sendNotificationToUser(
            await Pushe.getAndroidId(), 'title1', 'content1');
        break;
      case 5:
        result = 'Sending event with name:"name1"';
        Pushe.sendEvent('name 1');
        break;
      case 6:
        result = 'Sending ecomment with name:"product1",price:"100"';
        Pushe.sendEcommerceData('product1',100);
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
    "Subscribe to topic",
    "Unsubscribe from topic",
    "Send notification",
    "Send Event",
    "Send Ecommerce Data"
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
                child: Text('Flutter plugin: 1.0.0 | native version: 1.6.3',
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
                color: Colors.blueGrey,
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
