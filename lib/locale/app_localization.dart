import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/messages_all.dart';

class AppLocalizations {
  AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  final String localeName;

  // list of locales
  String get tapToScan {
    return Intl.message(
      'Tap to Scan',
      name: 'tapToScan',
      desc: 'Homepage instruction ',
      locale: localeName,
    );
  }

  String get loadingMessage {
    return Intl.message(
      'Sit tight! We are getting your menu ready!',
      name: 'loadingMessage',
      desc: 'Loading page message ',
      locale: localeName,
    );
  }

  String get tapToViewMenu {
    return Intl.message(
      'Tap to view menu',
      name: 'tapToViewMenu',
      desc: 'Menu tile instruction ',
      locale: localeName,
    );
  }

  String get cameraError {
    return Intl.message(
      'Access to camera permission is required for the app to work. Please check your settings and try again',
      name: 'cameraError',
      desc: 'Camera access error message ',
      locale: localeName,
    );
  }

  String get backButtonError {
    return Intl.message(
      'Kindly wait for scan to finish before pressing back button.',
      name: 'backButtonError',
      desc: 'Back button error message ',
      locale: localeName,
    );
  }

  String get menuPdfError {
    return Intl.message(
      'We encountered a problem while fetching the menus for restaurant. If problem persists kindly report the problem at www.bienmenuapp.com/report.',
      name: 'menuPdfError',
      desc: 'Failed to fetch pdf menus error ',
      locale: localeName,
    );
  }

  String get restaurantDataError {
    return Intl.message(
      'We were unable to fetch data for the barcode. Either this barcode does not belong to one of our partner restaurants or the server may be temporarily unavailable please try again or if problem persists kindly report the problem at www.bienmenuapp.com/report.',
      name: 'restaurantDataError',
      desc: 'Failed to fetch restaurant data error ',
      locale: localeName,
    );
  }

  String get unknownError {
    return Intl.message(
      'Unknown error occurred: we apologize for the inconvenience. If problem persists kindly report the problem at www.bienmenuapp.com/report.',
      name: 'unknownError',
      desc: 'Unknown error message ',
      locale: localeName,
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
