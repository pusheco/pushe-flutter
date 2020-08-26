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

Future<void> getInfo(BuildContext context, Function(String) onPositive,
    {String title: 'Pushe',
      String message: 'Do you accept?',
      String positive: 'OK',
      String negative: 'Cancel',
      Function(String) onNegative}) async {
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
            child: Text(positive),
            onPressed: () async {
              Navigator.of(context).pop();
              await onPositive(result);
            },
          ),
          FlatButton(
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

///
/// CoolCard is a widget for BMI sub app.
/// CoolCard is simply a card which takes a child and a background color.
///
class ReusableCard extends StatelessWidget {

  final Widget child;
  final Color color;
  final Function onPress;
  final EdgeInsets margin;

  const ReusableCard(
      {Key key, @required this.child, this.color: const Color(0xFF1D1E33), this.onPress, this.margin = const EdgeInsets.all(8.0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
        ),
        child: child,
      ),
    );
  }
}