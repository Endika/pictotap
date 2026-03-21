import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/utils/pictogram_utils.dart';

void main() {
  group('displayNameForIcon', () {
    test('returns space for spaceIcon', () {
      expect(displayNameForIcon(spaceIcon), ' ');
    });

    test('strips known prefix and returns name', () {
      expect(displayNameForIcon('descriptive:feliz'), 'feliz');
      expect(displayNameForIcon('verbs:comer'), 'comer');
    });

    test('returns unchanged for unknown prefix', () {
      expect(displayNameForIcon('emoji_smile'), 'emoji_smile');
    });
  });

  group('isAssetIcon', () {
    test('recognises known prefixes', () {
      expect(isAssetIcon('people:papa'), true);
    });

    test('rejects plain text and spaceIcon', () {
      expect(isAssetIcon('hello'), false);
      expect(isAssetIcon(spaceIcon), false);
    });
  });

  group('assetPathForIcon', () {
    test('builds correct asset path', () {
      expect(
        assetPathForIcon('substantive:agua'),
        'assets/keyboard/substantive/agua.png',
      );
    });

    test('returns null for non-asset icon', () {
      expect(assetPathForIcon(spaceIcon), isNull);
    });
  });

  group('buildRecommendations', () {
    test('empty input returns empty list', () {
      expect(buildRecommendations([]), isEmpty);
    });

    test('deduplicates and returns most recent first', () {
      final result = buildRecommendations([
        'people:mama',
        'verbs:comer',
        'people:mama',
      ]);
      expect(result, ['people:mama', 'verbs:comer']);
    });

    test('caps at maxRecommendationIcons', () {
      final icons = List.generate(20, (i) => 'verbs:icon$i');
      expect(buildRecommendations(icons).length, maxRecommendationIcons);
    });
  });
}
