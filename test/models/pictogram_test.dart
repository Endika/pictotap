import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/models/pictogram.dart';

void main() {
  group('Pictogram', () {
    test('fromId parses category and name', () {
      final p = Pictogram.fromId('verbs:comer');
      expect(p.category, 'verbs');
      expect(p.name, 'comer');
      expect(p.id, 'verbs:comer');
    });

    test('fromId handles space icon', () {
      final p = Pictogram.fromId(spaceIcon);
      expect(p.isSpace, true);
      expect(p.displayName, ' ');
    });

    test('fromId handles unknown prefix gracefully', () {
      final p = Pictogram.fromId('emoji_smile');
      expect(p.category, '');
      expect(p.name, 'emoji_smile');
      expect(p.isAsset, false);
    });

    test('isAsset is true for known categories', () {
      expect(Pictogram.fromId('descriptive:feliz').isAsset, true);
      expect(Pictogram.fromId('people:mama').isAsset, true);
      expect(Pictogram.fromId('verbs:comer').isAsset, true);
    });

    test('isAsset is false for unknown categories', () {
      expect(Pictogram.fromId('unknown:thing').isAsset, false);
      expect(Pictogram.fromId('emoji').isAsset, false);
    });

    test('displayName strips prefix', () {
      expect(Pictogram.fromId('verbs:comer').displayName, 'comer');
      expect(Pictogram.fromId('descriptive:feliz').displayName, 'feliz');
    });

    test('assetPath builds correct path', () {
      expect(
        Pictogram.fromId('substantive:agua').assetPath,
        'assets/keyboard/substantive/agua.png',
      );
    });

    test('assetPath is null for non-asset', () {
      expect(Pictogram.fromId('emoji').assetPath, isNull);
      expect(Pictogram.space.assetPath, isNull);
    });

    test('equality by id', () {
      final a = Pictogram.fromId('verbs:comer');
      final b = Pictogram.fromId('verbs:comer');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('space singleton identity', () {
      expect(Pictogram.fromId(spaceIcon), equals(Pictogram.space));
    });
  });
}
