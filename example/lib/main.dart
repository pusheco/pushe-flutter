import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushe_example/model/log_cubit.dart';
import 'package:pushe_example/screens/pushe.dart';
import 'package:pushe_example/screens/splash.dart';

void main() => runApp(
      BlocProvider(
        create: (context) => LogCubit(),
        child: PusheSampleApp(),
      ),
    );

class PusheSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushe Flutter - Remake',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        SplashScreen.route: (context) => SplashScreen(),
        PusheTest.route: (context) => PusheTest()
      },
      initialRoute: SplashScreen.route,
    );
  }
}

///
/// 1. Add BlocProvider as ancestor of PusheSampleWidget
/// 2. Create LogItem and LogState class (which holds LogItems as list and stuff) + LogEvent (Read what it was)
/// 3. Change Ui to use a list of logs instead of a status text
/// 4. Change Ui to a different one
/// 5. Attach Ui to BlocBuilder and BlocConsumer
/// 6. Test
/// 7. Add ability to save logs on insert to a database. (Learn database here)
/// 8. Apply db to app
