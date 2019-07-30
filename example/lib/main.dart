import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pushe/pushe.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pusheId = 'Not loaded';
  bool _isPusheInited;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String pusheId;
    bool isPusheInited;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Pushe.initialize();
      pusheId = await Pushe.getPusheId();
      isPusheInited = await Pushe.isPusheInitialized();
      Pushe.initializeNotificationListeners(true);
    } on Exception {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _pusheId = pusheId;
      _isPusheInited = isPusheInited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text('PusheId is: $_pusheId\n'),
            Text('PusheId is: $_isPusheInited\n'),
          ],
        )),
      ),
    );
  }
}
