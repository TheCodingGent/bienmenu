import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:bienmenu/home.dart';
import 'package:bienmenu/model/menu.dart';
import 'package:bienmenu/model/menutile.dart';
import 'package:bienmenu/model/restaurant.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingPage extends StatefulWidget {
  // initialize a field to hold the qr code result from the home screen, represents the restaurant id
  final String barcode;
  final String serverUrl = 'http://192.168.1.66:3000';

  // on creation this screen requires a string qrCodeResult
  LoadingPage({Key key, @required this.barcode}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  AnimationController _rotationController;
  Restaurant _restaurant;

  @override
  void initState() {
    // set up breathing animation controller
    _rotationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );

    _rotationController.repeat();

    // fetch the restaurant data given its id
    _fetchRestaurant(widget.barcode).then((restaurant) {
      debugPrint(
          'Fetched: ' + restaurant.name + ' for restaurant: ' + widget.barcode);

      setState(() {
        _restaurant = restaurant;
      });

      if (restaurant.menus.length == 0) {
        // pop-up no menus found dialog and return to home screen after dialog is closed
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      _fetchAllMenuPdfs(restaurant.menus).then((menuTiles) {
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
                      restaurant: _restaurant,
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
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        color: Colors.teal,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 120,
              left: 0.0,
              right: 0.0,
              child: Container(
                child: Text("We are getting your menu ready",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lobsterTwo(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 24)),
              ),
            ),
            Positioned(
                child: Align(
                    alignment: Alignment.center,
                    child: Stack(children: <Widget>[
                      Container(
                          width: 250,
                          height: 250,
                          child: Image.asset(
                              'assets/images/bienmenu-logo-no-outter-shadow.png')),
                      AnimatedBuilder(
                        animation: _rotationController,
                        child: Container(
                            width: 250,
                            height: 250,
                            child: Image.asset(
                                'assets/images/spinner-gradient.png')),
                        builder: (BuildContext context, Widget _widget) {
                          return Transform.rotate(
                            angle: _rotationController.value * 30,
                            child: _widget,
                          );
                        },
                      )
                    ])))
          ],
        ),
      ),
    );
  }

  Future<Restaurant> _fetchRestaurant(String restaurantId) async {
    debugPrint('Fetching restaurant with id...' + restaurantId);

    final response =
        await http.get(widget.serverUrl + '/restaurants/' + restaurantId);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Restaurant restaurant = Restaurant.fromJson(json.decode(response.body));

      // wait 5 seconds before returning the result to simulate loading
      await new Future.delayed(const Duration(seconds: 3));
      return restaurant;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load menus');
    }
  }

// given a menu name fetch the pdf matching the pdf name from the server parse it into bytes then write it to a file
  Future<File> _fetchMenuPdf(String name) async {
    final url = widget.serverUrl + '/menu/pdf/' + _restaurant.id + '/' + name;
    final filename = _restaurant.id + name + '.pdf';
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
  final Restaurant restaurant;

  MenuListPage({Key key, @required this.menuTiles, @required this.restaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ),
              ),
              title: Text(restaurant.name + " Menus"),
              backgroundColor: hexToColor(restaurant.color),
            ),
            body: ListView.builder(
              itemCount: menuTiles.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(menuTiles[index].formatDisplayName()),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      OpenFile.open(menuTiles[index].filePath);
                    },
                  ),
                );
              },
            )));
  }

  /// Construct a color from a hex code string, of the format #RRGGBB.
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
