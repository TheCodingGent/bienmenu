import 'package:bienmenu/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String barcode = "Not Yet Scanned";
  bool scanSuccessful = false;

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
            Text(
              "Tap to Scan",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(height: 20),
            Center(
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
                                      "restaurant1")), // to send result returned from QR Code scan
                        );
                      }
                    },
                    child: Image.asset('assets/images/bienmenu-logo.png',
                        height: 250, width: 250, fit: BoxFit.cover))),
            const SizedBox(height: 20),
            // Text(
            //   barcode,
            //   style: TextStyle(
            //     fontSize: 20.0,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

// scan a barcode and set the result into the state
  scan() async {
    try {
      ScanResult codeSanner = await BarcodeScanner.scan(); //barcode scanner
      setState(() {
        barcode = codeSanner.rawContent;
        scanSuccessful = true;
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
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
