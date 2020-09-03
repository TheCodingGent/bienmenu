import 'dart:async';
import 'package:flutter/material.dart';

Future<void> showMessageDialog(String text, BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Oops!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(text)],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
