import 'package:flutter/material.dart';

Future<void> alert(BuildContext context, Function onOK,
    {String title: 'Pushe', String message: 'Do you accept?', String ok: 'OK', String no: 'Cancel', Function onNo}) async {
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
            child: Text(ok),
            onPressed: () {
              onOK();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
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

Future<void> getInfo(BuildContext context, Function(String) onOK,
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