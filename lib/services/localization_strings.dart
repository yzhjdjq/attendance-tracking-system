import 'dart:ui' show Locale;
import 'package:ats/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart' show LocalizationsDelegate;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalMaterialLocalizations, GlobalWidgetsLocalizations;

class S {
  static const locale = Locale('ru');

  static const supportedLocales = [Locale('ru')];

  static const localizationDelegates = <LocalizationsDelegate>[
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);
}