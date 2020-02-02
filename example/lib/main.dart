import 'pushe_sample.dart';
import 'package:flutter/material.dart';

void main() => runApp(PusheSampleApp());

class PusheSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushe sample',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: PusheSampleWidget()
    );
  }
}
