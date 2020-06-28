import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:bienmenu/home.dart';
import 'package:bienmenu/model/menu.dart';
import 'package:bienmenu/model/menutile.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class LoadingPage extends StatefulWidget {
  // initialize a field to hold the qr code result from the home screen, represents the restaurant id
  final String barcode;
  final String serverUrl = 'http://localhost:3000';

  // on creation this screen requires a string qrCodeResult
  LoadingPage({Key key, @required this.barcode}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  AnimationController _breathingController;
  var _breathe = 0.0;

  @override
  void initState() {
    // set up breathing animation controller
    _breathingController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });
    _breathingController.addListener(() {
      setState(() {
        _breathe = _breathingController.value;
      });
    });
    _breathingController.forward();

    // fetch the menus for a given restaurant
    _fetchMenus(widget.barcode).then((menus) {
      debugPrint('Fetched: ' +
          menus.toString() +
          ' for restaurant: ' +
          widget.barcode);
      if (menus.length == 0) {
        // pop-up no menus found dialog and return to home screen after dialog is closed
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      _fetchAllMenuPdfs(menus).then((menuTiles) {
        debugPrint(menuTiles.toString());
        if (menuTiles.length == 1) {
          // if there's only one pdf open it right away
          OpenFile.open(menuTiles.first.filePath);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          // more than one menu display them in a list
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuListPage(
                      menuTiles: menuTiles,
                    )),
          );
        }
      }).catchError((onError) {
        print('An error occured while fetching PDFs for menus in restaurant: ' +
            widget.barcode +
            '. Error: ' +
            onError.toString());
        // need to pop-up a message and return home
        _showDialog('Failed to fetch PDF file for menus...').then((value) =>
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())));
      });
    }).catchError((onError) {
      print('An error occured while fetching menus for restaurant: ' +
          widget.barcode +
          '. Error: ' +
          onError.toString());
      // need to pop-up a message and return home
      _showDialog('Failed to fetch menus for restaurant...').then((value) =>
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage())));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = 250.0 - 20.0 * _breathe;
    debugPrint(_breathe.toString());
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
              child: Container(
                  width: size,
                  height: size,
                  child: Image.asset('assets/images/bienmenu-logo.png')),
            ),
          ],
        ),
      ),
    );
  }

// fetch all menus for a given restaurant
  Future<List<Menu>> _fetchMenus(String restaurantId) async {
    debugPrint('Fetching menus for...' + restaurantId);

    List<Menu> menus;
    final url = widget.serverUrl + '/restaurants/menus/' + restaurantId;
    debugPrint(url);
    // get menus for given restaurant
    final response =
        await http.get(widget.serverUrl + '/restaurants/menus/' + restaurantId);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var data = json.decode(response.body) as List;
      menus = data.map<Menu>((json) => Menu.fromJson(json)).toList();
      //return menus;
      // wait 2 seconds before returning the result to simulate loading
      await new Future.delayed(const Duration(seconds: 3));
      return menus;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load menus');
    }
  }

// given a menu name fetch the pdf matching the pdf name from the server parse it into bytes then write it to a file
  Future<File> _fetchMenuPdf(String name) async {
    final url = widget.serverUrl + "/menus/pdf/" + name;
    final filename = name + '.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load menus');
    }
  }

// fetches all the pdfs for all menus passed as a parameter and builds a list of MenuTile to display on the menu list view
  Future<List<MenuTile>> _fetchAllMenuPdfs(List<Menu> menus) async {
    List<MenuTile> menuTiles = new List<MenuTile>();

    //retrieve all pdfs
    for (final m in menus) {
      final f = await _fetchMenuPdf(m.name);
      debugPrint(f.path);
      menuTiles.add(new MenuTile(m.name, f.path));
    }
    return menuTiles;
  }

  Future<void> _showDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
                Text('Please try again or ask someone for assistance'),
              ],
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
}

// A list view that displays all available menus in a restaurant using a MenuTile that has a display name and a path to the pdf of the menu
class MenuListPage extends StatelessWidget {
  final List<MenuTile> menuTiles;
  MenuListPage({Key key, @required this.menuTiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
          ),
          title: Text("Menus"),
        ),
        body: ListView.builder(
          itemCount: menuTiles.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text(menuTiles[index].formatDisplayName()),
                onTap: () {
                  OpenFile.open(menuTiles[index].filePath);
                },
              ),
            );
          },
        ));
  }
}
