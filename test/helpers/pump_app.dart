import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/l10n/app_localizations.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: widget),
      ),
    );
    await pump();
  }
}
