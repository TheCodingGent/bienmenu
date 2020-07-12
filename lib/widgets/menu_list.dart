import 'package:bienmenu/home.dart';
import 'package:bienmenu/model/menutile.dart';
import 'package:bienmenu/model/restaurant.dart';
import 'package:bienmenu/locale/app_localization.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';

// A list view that displays all available menus in a restaurant using a MenuTile that has a display name and a path to the pdf of the menu
class MenuListPage extends StatefulWidget {
  final List<MenuTile> menuTiles;
  final Restaurant restaurant;

  MenuListPage({Key key, @required this.menuTiles, @required this.restaurant})
      : super(key: key);

  @override
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  MaterialColor _restaurantColor;
  Color _textColor;

  @override
  void initState() {
    _restaurantColor = hexToColor(widget.restaurant.color);
    _textColor = contrastColor(_restaurantColor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.home, color: _textColor),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ),
            ),
            title: Text(widget.restaurant.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontStyle: FontStyle.normal,
                    color: _textColor,
                    fontSize: 24)),
            backgroundColor: hexToColor(widget.restaurant.color),
          ),
          body: Container(
            color: _restaurantColor.shade200,
            child: ListView.builder(
              itemCount: widget.menuTiles.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 8.0,
                  margin:
                      new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(color: _restaurantColor),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      title: Text(widget.menuTiles[index].displayName,
                          style: GoogleFonts.openSans(
                              fontStyle: FontStyle.normal,
                              color: _textColor,
                              fontSize: 22)),
                      subtitle: Row(
                        children: <Widget>[
                          Icon(Icons.touch_app, color: _textColor),
                          Text(AppLocalizations.of(context).tapToViewMenu,
                              style: TextStyle(color: _textColor))
                        ],
                      ),
                      trailing: Icon(Icons.picture_as_pdf, color: _textColor),
                      onTap: () {
                        OpenFile.open(widget.menuTiles[index].filePath);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  /// Construct a color from a hex code string, of the format #RRGGBB.
  MaterialColor hexToColor(String code) {
    Color c =
        new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

    Map<int, Color> color = {
      50: Color.fromRGBO(c.red, c.green, c.blue, .1),
      100: Color.fromRGBO(c.red, c.green, c.blue, .2),
      200: Color.fromRGBO(c.red, c.green, c.blue, .3),
      300: Color.fromRGBO(c.red, c.green, c.blue, .4),
      400: Color.fromRGBO(c.red, c.green, c.blue, .5),
      500: Color.fromRGBO(c.red, c.green, c.blue, .6),
      600: Color.fromRGBO(c.red, c.green, c.blue, .7),
      700: Color.fromRGBO(c.red, c.green, c.blue, .8),
      800: Color.fromRGBO(c.red, c.green, c.blue, .9),
      900: Color.fromRGBO(c.red, c.green, c.blue, 1),
    };

    MaterialColor colorCustom = MaterialColor(c.value, color);
    return colorCustom;
  }

  Color contrastColor(Color color) {
    int d = 0;

    // Counting the perceptive luminance - human eye favors green color...
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5)
      d = 0; // bright colors - black font
    else
      d = 255; // dark colors - white font

    return Color.fromARGB(255, d, d, d);
  }
}
