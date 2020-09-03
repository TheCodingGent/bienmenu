// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "backButtonError" : MessageLookupByLibrary.simpleMessage("Kindly wait for scan to finish before pressing back button."),
    "cameraError" : MessageLookupByLibrary.simpleMessage("Access to camera permission is required for the app to work. Please check your settings and try again"),
    "closeButtonText" : MessageLookupByLibrary.simpleMessage("Close"),
    "contactTracingMessage" : MessageLookupByLibrary.simpleMessage("For your safety and the safety of our employees please take the time to fill in our form for contact tracing due to COVID-19. Your information will be kept strictly confidential and used only for contact tracing. Thank you in helping us all stay safe."),
    "emailInvalid" : MessageLookupByLibrary.simpleMessage("Please enter a valid email"),
    "emailRequired" : MessageLookupByLibrary.simpleMessage("Email is required"),
    "formLabelEmail" : MessageLookupByLibrary.simpleMessage("Email"),
    "formLabelName" : MessageLookupByLibrary.simpleMessage("Name"),
    "formLabelNumber" : MessageLookupByLibrary.simpleMessage("Telephone"),
    "loadingMessage" : MessageLookupByLibrary.simpleMessage("Sit tight! We are getting your menu ready!"),
    "menuPdfError" : MessageLookupByLibrary.simpleMessage("We encountered a problem while fetching the menus for restaurant. If problem persists, we would appreciate any feedback at info@bienmenuapp.com"),
    "nameRequired" : MessageLookupByLibrary.simpleMessage("Name is required"),
    "phoneInvalid" : MessageLookupByLibrary.simpleMessage("Please enter a valid phone number"),
    "restaurantDataError" : MessageLookupByLibrary.simpleMessage("We were unable to fetch data for the barcode. Either this barcode does not belong to one of our partner restaurants or the server may be temporarily unavailable please try again or if problem persists, we would appreciate any feedback at info@bienmenuapp.com"),
    "submitButtonText" : MessageLookupByLibrary.simpleMessage("Submit"),
    "tapToScan" : MessageLookupByLibrary.simpleMessage("Tap to Scan"),
    "tapToViewMenu" : MessageLookupByLibrary.simpleMessage("Tap to view menu"),
    "termsAcceptMessage" : MessageLookupByLibrary.simpleMessage("By clicking this box I agree to the"),
    "unknownError" : MessageLookupByLibrary.simpleMessage("Unknown error occurred: we apologize for the inconvenience. If problem persists, we would appreciate any feedback at info@bienmenuapp.com")
  };
}
