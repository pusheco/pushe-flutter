import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushe_example/model/log_cubit.dart';
import 'package:pushe_example/model/log_item.dart';
import 'package:pushe_example/model/log_state.dart';
import 'package:tinycolor/tinycolor.dart';
import 'package:pushe_flutter/pushe.dart';

import '../constants.dart';
import '../utils.dart';

typedef Op = Future<LogItem> Function();

class PusheTest extends StatelessWidget {
  static final route = "/main";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pushe Sample', style: TextStyle(fontSize: 19)),
          Text('v0.0.1', style: TextStyle(fontSize: 10))
        ]),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: DrawerWidget(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Logs(),
      ),
    );
  }
}

class Logs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _logsAvailable(LogState pusheData) => pusheData.logs.length > 0;

    ///
    /// If there are no logs, return this.
    ///
    Widget _getNoLogWidget() {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/pushe.jpg'),
              maxRadius: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No logs. Use \u2630 to add some.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'SourceSansPro'),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    }

    ///
    /// If there ARE any logs available, return this
    ///
    Widget _getLogWidget(LogState logState) {
      return ListView(
        children: logState.logs.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: LogWidget(log: e),
          );
        }).toList(growable: false),
      );
    }

    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      child: BlocConsumer<LogCubit, LogState>(
        listener: (context, state) {
          print('Log state log size is: ${state.logs.length}');
        },
        builder: (context, state) {
          return _logsAvailable(state)
              ? _getLogWidget(state)
              : _getNoLogWidget();
        },
      ),
    );
  }
}

class LogWidget extends StatelessWidget {
  final LogItem log;

  LogWidget({this.log});

  Color _getLogColor() {
    switch (log.type) {
      case Type.option:
        return Colors.blue;
      case Type.result:
        return Colors.green[700];
      case Type.event:
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  Widget _colorizedDivider(TinyColor tinyLogColor) {
    return Divider(
        color: tinyLogColor.isDark()
            ? tinyLogColor.brighten(20).color
            : tinyLogColor.darken(20).color);
  }

  Widget _getData(LogItem logData, TinyColor tinyLogColor) {
    final data = logData.data;
    return data.isEmpty
        ? SizedBox.shrink()
        : Column(
            children: data.entries.map<Widget>((e) {
              final key = e.key;
              final value = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(key,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w300))),
                    Expanded(
                        child: Text(value,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w300))),
                  ],
                ),
              );
            }).toList(growable: true)
              ..insert(0, _colorizedDivider(tinyLogColor)),
          );
  }

  Widget _getTime(TinyColor tinyLogColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _colorizedDivider(tinyLogColor),
        Text(
          log.date?.toIso8601String(),
          style: TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w300),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final logColor = _getLogColor();
    final tinyLogColor = TinyColor(logColor);
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(title: Text(log.tag), content: Text(log.message)),
        );
      },
      child: ReusableCard(
        margin: EdgeInsets.all(0.0),
        color: logColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(log.tag, style: TextStyle(color: Colors.white, fontSize: 8)),
              _colorizedDivider(tinyLogColor),
              Text(
                log.message,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'SourceSansPro',
                    fontWeight: FontWeight.w400),
              ),
              _getData(log, tinyLogColor),
              _getTime(tinyLogColor)
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final Color color;

  DrawerWidget({this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final options = DrawerOption.options;
    final List<Widget> items = [
      DrawerHeader(
        padding: EdgeInsets.all(40),
        child: ReusableCard(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Command options', style: TextStyle(fontSize: 20, color: Colors.white)),
                Text('Click an item to execute', style: TextStyle(fontSize: 10, color: Colors.white)),
              ],
            )
          ),
        ),
        decoration: BoxDecoration(color: kBackgroundColor),
      )
    ]..addAll(
        options.map(
          (e) => ListTile(
            title: Text(e.name, style: TextStyle(color: kBackgroundColor)),
            onTap: () async {
              context.bloc<LogCubit>().addLog(await e.getLog());
              Navigator.pop(context);
            },
          ),
        ),
      );

    return Container(
      color: color,
      child: ListView(children: items),
    );
  }
}

class DrawerOption {
  final String name, module;
  final Op getLog;

  DrawerOption.create({this.name, this.module = 'All', this.getLog});

  static final List<DrawerOption> _options = [
    DrawerOption.create(
        name: 'IDs',
        module: 'Core',
        getLog: () async {
          return LogItem(
              tag: 'Identifier',
              message: 'IDs are phrases achieved from app and OS.',
              data: {
                'AndroidI(DeviceId)': await Pushe.getDeviceId(),
                'AdvertisingId': await Pushe.getGoogleAdvertisingId(),
                'CustomId': await Pushe.getCustomId() ?? "Not set",
                'Phone': await Pushe.getUserPhoneNumber() ?? "Not set",
                'Email': await Pushe.getUserEmail() ?? "Not set"
              },
              type: Type.option,
              date: DateTime.now());
        }),
    DrawerOption.create(
        name: 'Set CustomId',
        module: 'Core',
        getLog: () async {
          return LogItem(
              tag: 'Identifier',
              message: 'IDs are phrases achieved from app and OS.',
              data: {
                'AndroidI(DeviceId)': await Pushe.getDeviceId(),
                'AdvertisingId': await Pushe.getGoogleAdvertisingId(),
                'CustomId': await Pushe.getCustomId() ?? "Not set",
                'Phone': await Pushe.getUserPhoneNumber() ?? "Not set",
                'Email': await Pushe.getUserEmail() ?? "Not set"
              },
              type: Type.option,
              date: DateTime.now());
        }),
  ];

  static List<DrawerOption> get options => UnmodifiableListView(_options);
}
