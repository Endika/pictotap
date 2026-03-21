import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/widgets/pictogram_keyboard.dart';

import '../helpers/pump_app.dart';

void main() {
  group('PictogramKeyboard', () {
    late List<String> tappedIcons;
    late int spaceCount;
    late int backspaceCount;

    setUp(() {
      tappedIcons = [];
      spaceCount = 0;
      backspaceCount = 0;
    });

    Widget buildKeyboard({
      List<String> recommendations = const [],
      bool showLimitBanner = false,
    }) {
      return PictogramKeyboard(
        onIconSelected: (icon) => tappedIcons.add(icon),
        onSpace: () => spaceCount++,
        onBackspace: () => backspaceCount++,
        recommendations: recommendations,
        showLimitBanner: showLimitBanner,
      );
    }

    testWidgets('renders category tabs', (tester) async {
      await tester.pumpApp(buildKeyboard());

      for (final cat in keyboardCategories) {
        expect(find.text(cat.label), findsOneWidget);
      }
    });

    testWidgets('callbacks fire on space and backspace taps', (tester) async {
      await tester.pumpApp(buildKeyboard());

      await tester.tap(find.bySemanticsLabel('Add space'));
      await tester.pump();
      expect(spaceCount, 1);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(backspaceCount, 1);
    });

    testWidgets('limit banner visibility follows showLimitBanner',
        (tester) async {
      await tester.pumpApp(buildKeyboard(showLimitBanner: true));
      expect(find.text('Limit reached'), findsOneWidget);
    });

    testWidgets('tapping recommendation calls onIconSelected', (tester) async {
      await tester.pumpApp(
        buildKeyboard(recommendations: ['people:mama']),
      );

      await tester.tap(find.bySemanticsLabel('mama').first);
      await tester.pump();
      expect(tappedIcons, ['people:mama']);
    });
  });
}
