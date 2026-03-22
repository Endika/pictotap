import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/data/pictogram_recommendations.dart';
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
    test('empty board returns default suggestions', () {
      final result = buildRecommendations([]);
      expect(result, isNotEmpty);
      expect(result.length, lessThanOrEqualTo(maxRecommendationIcons));
      expect(result.first, defaultSuggestions.first);
    });

    test('board with only spaces returns default suggestions', () {
      final result = buildRecommendations([spaceIcon, spaceIcon]);
      expect(result.first, defaultSuggestions.first);
    });

    test('returns contextual suggestions based on last icon', () {
      final result = buildRecommendations(['some:hola']);
      expect(result, isNotEmpty);
      expect(result.length, lessThanOrEqualTo(maxRecommendationIcons));

      final withTrailingSpace = buildRecommendations(['some:hola', spaceIcon]);
      expect(result, withTrailingSpace);
    });

    test('filters out icons already on the board', () {
      final result = buildRecommendations(['people:yo', 'verbs:querer']);
      expect(result, isNot(contains('people:yo')));
      expect(result, isNot(contains('verbs:querer')));
    });

    test('falls back to category suggestions for unknown icon', () {
      final result = buildRecommendations(['verbs:icon_unknown']);
      expect(result, isNotEmpty);
    });

    test('all recommendation data references valid pictograms', () {
      final allIcons = <String>{
        ...descriptiveIcons,
        ...peopleIcons,
        ...prepositionsIcons,
        ...someIcons,
        ...substantiveIcons,
        ...verbsIcons,
      };

      final invalid = <String>[];
      for (final entry in nextWordSuggestions.entries) {
        if (!allIcons.contains(entry.key)) {
          invalid.add('key: ${entry.key}');
        }
        for (final suggestion in entry.value) {
          if (!allIcons.contains(suggestion)) {
            invalid.add('value: $suggestion (in ${entry.key})');
          }
        }
      }
      for (final icon in defaultSuggestions) {
        if (!allIcons.contains(icon)) {
          invalid.add('default: $icon');
        }
      }
      for (final entry in categoryFallbacks.entries) {
        for (final icon in entry.value) {
          if (!allIcons.contains(icon)) {
            invalid.add('fallback: $icon (category ${entry.key})');
          }
        }
      }
      expect(invalid, isEmpty,
          reason: 'Invalid icon references in recommendation data: $invalid');
    });
  });
}
