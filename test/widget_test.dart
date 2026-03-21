import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/main.dart';

void main() {
  testWidgets('PictoTapApp renders and shows title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PictoTapApp());
    await tester.pump();

    expect(find.text('PictoTap'), findsOneWidget);
  });
}
