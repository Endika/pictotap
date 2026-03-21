import 'package:flutter/material.dart';
import 'package:pictotap/l10n/app_localizations.dart';
import 'package:pictotap/screens/pictotap_screen.dart';

void main() => runApp(const PictoTapApp());

class PictoTapApp extends StatelessWidget {
  const PictoTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const PictoTapScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return const Locale('en');
        final languageCode = deviceLocale.languageCode;
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
    );
  }
}
