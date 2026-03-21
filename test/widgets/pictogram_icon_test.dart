import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/widgets/pictogram_icon.dart';

void main() {
  group('PictogramIcon', () {
    testWidgets('shows text fallback for non-asset icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PictogramIcon(icon: 'hello')),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders Image for asset-prefixed icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PictogramIcon(icon: 'verbs:comer')),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PictogramIcon(icon: 'hello', size: 80)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });
  });
}
