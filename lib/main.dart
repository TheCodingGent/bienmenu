import 'package:flutter/material.dart';
import 'package:bienmenu/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme: AppBarTheme(
        color: Colors.teal,
      )),
      home: HomePage(),
    );
  }
}
