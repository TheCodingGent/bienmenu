import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:bienmenu/model/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class LoadingPage extends StatefulWidget {
  // initialize a field to hold the qr code result from the home screen, represents the restaurant id
  final String barcode;

  // on creation this screen requires a string qrCodeResult
  LoadingPage({Key key, @required this.barcode}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    // fetch the first menu for a given restaurant
    _fetchMenu(widget.barcode).then((menu) {
      //print(data);
      //_launchURL(data);

      // retrieve pdf
      _fetchMenuPdf(menu.name).then((f) {
        debugPrint(f.path);
        OpenFile.open(f.path);
      });

      // Return to home screen after launching the browser
      Navigator.pop(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        color: Colors.teal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
                child: Image.asset('assets/images/bienmenu-logo.png',
                    height: 250, width: 250, fit: BoxFit.cover)),
          ],
        ),
      ),
    );
  }

// return the first menu for a given restaurant
  Future<Menu> _fetchMenu(String barcode) async {
    debugPrint('Fetching menus for...' + barcode);
    final menus = await _fetchMenus(barcode);

    if (menus == null || menus.length == 0) {
      return new Menu();
    }
    //await Future.delayed(Duration(seconds: 2));
    debugPrint(menus.toString());
    return menus.first;
  }

// fetch all menus for a given restaurant
  Future<List<Menu>> _fetchMenus(String restaurantId) async {
    List<Menu> menus;

    // get menus for given restaurant
    final response = await http
        .get('http://localhost:3000/menus?restaurantId=' + restaurantId);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var data = json.decode(response.body) as List;
      menus = data.map<Menu>((json) => Menu.fromJson(json)).toList();
      return menus;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load menus');
    }
  }

// given a menu name fetch the pdf matching the pdf name from the server parse it into bytes then write it to a file
  Future<File> _fetchMenuPdf(String name) async {
    final url = "http://localhost:3000/menus/pdf?name=" + name;
    final filename = name + '.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

// launches a url in a browser window
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
