import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/widgets/board_empty_hint.dart';

import '../helpers/pump_app.dart';

void main() {
  group('BoardEmptyHint', () {
    testWidgets('shows correct hint based on keyboard visibility',
        (tester) async {
      await tester.pumpApp(
        const BoardEmptyHint(isKeyboardVisible: false),
      );
      expect(find.text('Tap here to open the keyboard'), findsOneWidget);

      await tester.pumpApp(
        const BoardEmptyHint(isKeyboardVisible: true),
      );
      expect(find.text('Choose a pictogram'), findsOneWidget);
    });
  });
}
