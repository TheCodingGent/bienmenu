import 'package:flutter/material.dart';
import 'package:bienmenu/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'locale/app_localization.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  AppLocalizationDelegate _localeOverrideDelegate =
      AppLocalizationDelegate(Locale('en', 'US'));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        _localeOverrideDelegate
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('fr', ''),
        const Locale('es', '')
      ],
      theme: ThemeData(
          appBarTheme: AppBarTheme(
        color: Colors.teal,
      )),
      home: HomePage(),
    );
  }
}
