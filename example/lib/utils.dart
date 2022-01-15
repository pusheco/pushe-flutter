import 'package:flutter/material.dart';

Future<void> alert(BuildContext context, Function onOK,
    {String title: 'Pushe', String message: 'Do you accept?', String ok: 'OK', String no: 'Cancel', Function? onNo}) async {
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
          ElevatedButton(
            child: Text(ok),
            onPressed: () {
              onOK();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(no),
            onPressed: () {
              onNo?.call();
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

Future<void> getInfo(BuildContext context, Function(String) onPositive,
    {String title: 'Pushe',
      String message: 'Do you accept?',
      String positive: 'OK',
      String negative: 'Cancel',
      Function(String)? onNegative}) async {
  return showDialog<void>(
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
          ElevatedButton(
            child: Text(positive),
            onPressed: () async {
              Navigator.of(context).pop();
              await onPositive(result);
            },
          ),
          ElevatedButton(
            child: Text(negative),
            onPressed: () async {
              Navigator.of(context).pop();
              await onNegative?.call(result);
            },
          )
        ],
      );
    },
  );
}