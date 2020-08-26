import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pushe_example/constants.dart';
import 'package:pushe_example/screens/pushe.dart';

class SplashScreen extends StatefulWidget {
  static final route = "/";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

//  Animation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _preloadData();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  _preloadData() async {
    await Future.delayed(Duration(seconds: 5));
    print('Preload successful');
    Navigator.pushReplacementNamed(context, PusheTest.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 20),
              child: Lottie.asset('assets/animations/lottie_splash.json',
                  controller: controller,
                  repeat: true,
                  reverse: true, onLoaded: (composition) {
                controller
//                  ..duration = composition.duration
                  ..forward();
              }),
            ),
            Text('Preloading data...', style: kLabelStyle, textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
