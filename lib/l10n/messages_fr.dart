// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "backButtonError" : MessageLookupByLibrary.simpleMessage("Veuillez attendre que la numérisation se termine avant d\'appuyer sur le bouton retour."),
    "cameraError" : MessageLookupByLibrary.simpleMessage("BienMenu requiert l\'accès à votre caméra. Veuillez ajuster vos réglages et réessayer."),
    "loadingMessage" : MessageLookupByLibrary.simpleMessage("Nous préparons votre menu"),
    "menuPdfError" : MessageLookupByLibrary.simpleMessage("Nous faisons face à un problème pour récupérer le menu. Veuillez essayer de nouveau ou nous faire part du problème à www.bienmenuapp.com/report s\'il persiste."),
    "restaurantDataError" : MessageLookupByLibrary.simpleMessage("Impossible de récupérer l\'information pour ce Code QR. Soit ce code QR n\'appartient à aucun de nos restaurants partenaires ou notre serveur est temporairement indisponible. Veuillez essayer de nouveau ou nous faire part du problème à www.bienmenuapp.com/report s\'il persiste."),
    "tapToScan" : MessageLookupByLibrary.simpleMessage("Tapez pour Scanner"),
    "tapToViewMenu" : MessageLookupByLibrary.simpleMessage("Tapez ici pour voir le menu"),
    "unknownError" : MessageLookupByLibrary.simpleMessage("Erreur inconnue: Veuillez essayer de nouveau ou nous faire part du problème à bienmenuapp.com/report s\'il persiste. Nous apprécions vos commentaires et nous excusons de tout inconvénient.")
  };
}
