import 'package:bienmenu/loading.dart';
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
  bool scanSuccessful = false;
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
    //final size = 250.0;
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
                Positioned(
                  top: 120,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    child: Text("Tap to Scan",
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
                          debugPrint('Button clicked in page 1 clicked');

                          await scan();

                          if (scanSuccessful) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadingPage(
                                      barcode:
                                          barcode)), // to send result returned from QR Code scan
                            );
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
  scan() async {
    try {
      ScanResult codeSanner = await BarcodeScanner.scan(); //barcode scanner
      setState(() {
        barcode = codeSanner.rawContent;

        if (barcode != '') {
          // no error occured and user did not cancel action
          scanSuccessful = true;
        }
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'Camera Permission Required';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back" button before scanning anything)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
