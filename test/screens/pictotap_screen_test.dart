import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/l10n/app_localizations.dart';
import 'package:pictotap/screens/pictotap_screen.dart';
import 'package:pictotap/widgets/board_empty_hint.dart';
import 'package:pictotap/widgets/pictogram_keyboard.dart';

void main() {
  Widget buildApp() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: PictoTapScreen(),
    );
  }

  group('PictoTapScreen', () {
    testWidgets('initial state: hint visible, keyboard hidden, FAB visible',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('PictoTap'), findsOneWidget);
      expect(find.byType(BoardEmptyHint), findsOneWidget);
      expect(find.byType(PictogramKeyboard), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping board toggles keyboard and hides FAB', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(find.byType(PictogramKeyboard), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(find.byType(PictogramKeyboard), findsNothing);
    });

    testWidgets('add icon, then backspace removes it', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      final firstIcon = keyboardCategories.first.icons.first;
      await tester.tap(find.bySemanticsLabel(firstIcon.split(':').last).first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BoardEmptyHint), findsNothing);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BoardEmptyHint), findsOneWidget);
    });

    testWidgets('limit banner appears at max icons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      for (int i = 0; i < defaultBoardMaxIcons; i++) {
        await tester.tap(find.bySemanticsLabel('Add space'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Limit reached'), findsOneWidget);
    });
  });
}
