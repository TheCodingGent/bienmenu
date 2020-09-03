import 'package:bienmenu/loading.dart';
import 'package:bienmenu/locale/app_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String barcode = "Not Yet Scanned";
  List<bool> isSelected = [true, false];
  String _errorMessage = "";
  bool _scanSuccessful = false;
  AnimationController _breathingController;
  var _breathe = 0.0;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 250.0 - 20.0 * _breathe;
    return new WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            color: Colors.teal,
            child: Stack(
              children: <Widget>[
                // Language toggle widget
                // Positioned(
                //   child: Align(
                //       alignment: Alignment.topRight,
                //       child: Container(
                //           child: LayoutBuilder(builder: (context, constraints) {
                //         return ToggleButtons(
                //             color: Colors.white,
                //             selectedColor: Colors.teal[700],
                //             fillColor: Colors.white,
                //             borderColor: Colors.white,
                //             borderWidth: 3,
                //             selectedBorderColor: Colors.teal[700],
                //             renderBorder: true,
                //             borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(25),
                //                 bottomRight: Radius.circular(25)),
                //             children: <Widget>[
                //               Padding(
                //                   padding: EdgeInsets.only(left: 0, right: 0),
                //                   child: Text('EN',
                //                       style: GoogleFonts.openSans(
                //                           fontStyle: FontStyle.normal,
                //                           fontSize: 12,
                //                           fontWeight: FontWeight.bold))),
                //               Text('FR',
                //                   style: GoogleFonts.openSans(
                //                       fontStyle: FontStyle.normal,
                //                       fontSize: 12,
                //                       fontWeight: FontWeight.bold))
                //             ],
                //             onPressed: (int index) {
                //               setState(() {
                //                 for (int buttonIndex = 0;
                //                     buttonIndex < isSelected.length;
                //                     buttonIndex++) {
                //                   if (buttonIndex == index) {
                //                     isSelected[buttonIndex] = true;
                //                   } else {
                //                     isSelected[buttonIndex] = false;
                //                   }
                //                 }
                //                 if (index == 0)
                //                   AppLocalizations.load(Locale('en', 'US'));
                //                 else if (index == 1)
                //                   AppLocalizations.load(Locale('fr', ''));
                //               });
                //             },
                //             isSelected: isSelected);
                //       }))),
                // ),
                Positioned(
                  top:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 120
                          : 12,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    child: Text(AppLocalizations.of(context).tapToScan,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lobsterTwo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 36)),
                  ),
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                        onTap: () async {
                          await _scan();

                          if (_scanSuccessful) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadingPage(
                                      barcode: this
                                          .barcode)), // to send result returned from QR Code scan //5f1b1d664f17a784e368e9a2 5f0b6ea3742bcba040ce4102 5ef6df8bac275f69875e7dab
                            );
                          } else {
                            if (_errorMessage != "") {
                              _showDialog(this._errorMessage);
                            }
                          }
                        },
                        child: Container(
                            width: size,
                            height: size,
                            child: Image.asset(
                                'assets/images/bienmenu-logo.png'))),
                  ),
                )
              ],
            ),
          ),
        ));
  }

// scan a barcode and set the result into the state
  _scan() async {
    try {
      ScanResult codeSanner = await BarcodeScanner.scan(); //barcode scanner
      setState(() {
        var barcodeContent = codeSanner.rawContent;
        barcode = barcodeContent.substring(barcodeContent.lastIndexOf('/') +
            1); // trims the url and keeps the restaurant ID

        if (barcode != '') {
          // no error occured and user did not cancel action
          _scanSuccessful = true;
        }
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this._errorMessage = AppLocalizations.of(context).cameraError;
        });
      } else {
        setState(() => this._errorMessage =
            AppLocalizations.of(context).unknownError + ' ' + e.toString());
      }
    } on FormatException {
      setState(() =>
          this._errorMessage = AppLocalizations.of(context).backButtonError);
    } catch (e) {
      setState(() => this._errorMessage =
          AppLocalizations.of(context).unknownError + ' ' + e.toString());
    }
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
