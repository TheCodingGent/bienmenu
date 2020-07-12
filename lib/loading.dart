import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:bienmenu/home.dart';
import 'package:bienmenu/menu_list.dart';
import 'package:bienmenu/model/menu.dart';
import 'package:bienmenu/model/menutile.dart';
import 'package:bienmenu/model/restaurant.dart';
import 'package:bienmenu/locale/app_localization.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingPage extends StatefulWidget {
  // initialize a field to hold the qr code result from the home screen, represents the restaurant id
  final String barcode;
  final String _serverUrl = "https://cryptic-dawn-36054.herokuapp.com";

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
      setState(() {
        _restaurant = restaurant;
      });

      if (restaurant.menus.length == 0) {
        // pop-up no menus found dialog and return to home screen after dialog is closed
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      _fetchAllMenuPdfs(restaurant.menus).then((menuTiles) {
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
        // print('An error occured while fetching PDFs for menus in restaurant: ' +
        //     widget.barcode +
        //     '. Error: ' +
        //     onError.toString());
        // need to pop-up a message and return home
        _showDialog(AppLocalization.of(context).menuPdfError +
                ' ID: ' +
                restaurant.name)
            .then((value) => Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())));
      });
    }).catchError((onError) {
      // print('An error occured while fetching menus for restaurant: ' +
      //     widget.barcode +
      //     '. Error: ' +
      //     onError.toString());
      // need to pop-up a message and return home
      _showDialog(AppLocalization.of(context).restaurantDataError +
              ' ID: ' +
              widget.barcode)
          .then((value) => Navigator.push(
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
              top: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 120
                  : 12,
              left: 0.0,
              right: 0.0,
              child: Container(
                child: Text(AppLocalization.of(context).loadingMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 24)),
              ),
            ),
            Positioned(
              child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      width: 250,
                      height: 250,
                      child: Image.asset('assets/images/bienmenu-logo.png'))),
            ),
            Positioned(
              child: Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    child: Container(
                        width: 210,
                        height: 210,
                        child:
                            Image.asset('assets/images/spinner-gradient.png')),
                    builder: (BuildContext context, Widget _widget) {
                      return Transform.rotate(
                        angle: _rotationController.value * 30,
                        child: _widget,
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }

  Future<Restaurant> _fetchRestaurant(String restaurantId) async {
    final response =
        await http.get(widget._serverUrl + '/restaurants/' + restaurantId);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Restaurant restaurant = Restaurant.fromJson(json.decode(response.body));

      // wait 3 seconds before returning the result to simulate loading
      await new Future.delayed(const Duration(seconds: 3));
      return restaurant;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load menus');
    }
  }

// given a menu name fetch the pdf matching the pdf name from the server parse it into bytes then write it to a file
  Future<File> _fetchMenuPdf(String filename) async {
    final url =
        widget._serverUrl + '/menu/pdf/' + _restaurant.id + '/' + filename;
    final localFilename = _restaurant.id + '_' + filename + '.pdf';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$localFilename');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch menu ' + filename);
    }
  }

// fetches all the pdfs for all menus passed as a parameter and builds a list of MenuTile to display on the menu list view
  Future<List<MenuTile>> _fetchAllMenuPdfs(List<Menu> menus) async {
    List<MenuTile> menuTiles = new List<MenuTile>();
    // get path to Documents folder
    String dir = (await getApplicationDocumentsDirectory()).path;

    //retrieve all pdfs
    for (final m in menus) {
      // check if file exists then do not fetch
      final menuPdfFilePath =
          '$dir/' + _restaurant.id + '_' + m.filename + '.pdf';
      if (!await File(menuPdfFilePath).exists()) {
        await _fetchMenuPdf(m.filename);
      }
      menuTiles.add(new MenuTile(m.name, menuPdfFilePath));
    }
    return menuTiles;
  }

  Future<void> _showDialog(String text) async {
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
}
