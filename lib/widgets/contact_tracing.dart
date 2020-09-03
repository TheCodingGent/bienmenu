import 'dart:convert';

import 'package:bienmenu/locale/app_localization.dart';
import 'package:bienmenu/model/customer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:bienmenu/env.dart';
import 'package:url_launcher/url_launcher.dart';

class Consts {
  Consts._();

  static const double padding = 20.0;
  static const double avatarRadius = 80.0;
}

class ContactTracingDialog extends StatelessWidget {
  final String restaurantId;

  ContactTracingDialog({
    @required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(
              top: Consts.avatarRadius,
              bottom: Consts.padding,
              left: Consts.padding,
              right: Consts.padding,
            ),
            margin: EdgeInsets.only(top: Consts.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).contactTracingMessage,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ContactTracingForm(restaurantId: restaurantId),
                ],
              ),
            )),
        Positioned(
            left: Consts.padding,
            right: Consts.padding,
            child: Image.asset('assets/images/bienmenu-logo.png',
                height: 150, width: 150)),
        Positioned(
          right: 10,
          top: 90,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 14.0,
                backgroundColor: Colors.teal,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ContactTracingForm extends StatefulWidget {
  final String restaurantId;

  ContactTracingForm({Key key, @required this.restaurantId}) : super(key: key);

  @override
  _ContactTracingFormState createState() {
    return _ContactTracingFormState();
  }
}

class _ContactTracingFormState extends State<ContactTracingForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _cTFormKey = GlobalKey<FormState>();
  Customer customer = new Customer();
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _cTFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).formLabelName,
                prefixIcon: Icon(Icons.person)),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).nameRequired;
              }
              return null;
            },
            onSaved: (String value) {
              customer.fullname = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).formLabelEmail,
                prefixIcon: Icon(Icons.email)),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).emailRequired;
              }

              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value);
              if (!emailValid) {
                return AppLocalizations.of(context).emailInvalid;
              }

              return null;
            },
            onSaved: (String value) {
              customer.email = value;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).formLabelNumber,
                prefixIcon: Icon(Icons.phone)),
            validator: (value) {
              if (value.isNotEmpty && value.length != 10) {
                return AppLocalizations.of(context).phoneInvalid;
              }
              return null;
            },
            onSaved: (String value) {
              customer.phone = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: RichText(
                  text: new TextSpan(
                    children: [
                      new TextSpan(
                        text: AppLocalizations.of(context).termsAcceptMessage,
                        style: new TextStyle(color: Colors.black),
                      ),
                      new TextSpan(
                        text: ' terms & conditions',
                        style: new TextStyle(color: Colors.blue),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://www.bien-menu.com/terms');
                          },
                      ),
                    ],
                  ),
                )),
                Checkbox(
                  value: this._termsAccepted,
                  onChanged: (bool newValue) {
                    setState(() => {this._termsAccepted = newValue});
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Text(
                    AppLocalizations.of(context).submitButtonText,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.teal,
                  onPressed: !this._termsAccepted
                      ? null
                      : () {
                          // Validate returns true if the form is valid, or false
                          // otherwise.
                          if (_cTFormKey.currentState.validate() &&
                              this._termsAccepted) {
                            //save form and construct customer object
                            _cTFormKey.currentState.save();
                            customer.date = DateTime.now().toUtc().toString();
                            customer.restaurant = widget.restaurantId;

                            _saveCustomer(customer);
                            Navigator.of(context).pop();
                          }
                        },
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCustomer(Customer customer) async {
    http.post(environment['API_URL'] + 'customers/tracing/add',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(customer.toJson()));
  }
}
