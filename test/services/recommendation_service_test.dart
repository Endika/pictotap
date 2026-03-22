import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/data/pictogram_recommendations.dart';
import 'package:pictotap/services/recommendation_service.dart';

void main() {
  const service = RecommendationService();

  group('RecommendationService', () {
    test('empty board returns default suggestions', () {
      final result = service.suggest([]);
      expect(result, isNotEmpty);
      expect(result.length, lessThanOrEqualTo(maxRecommendationIcons));
      expect(result.first, defaultSuggestions.first);
    });

    test('board with only spaces returns default suggestions', () {
      final result = service.suggest([spaceIcon, spaceIcon]);
      expect(result.first, defaultSuggestions.first);
    });

    test('returns contextual suggestions based on last icon', () {
      final result = service.suggest(['some:hola']);
      expect(result, isNotEmpty);
      expect(result.length, lessThanOrEqualTo(maxRecommendationIcons));

      final withTrailingSpace = service.suggest(['some:hola', spaceIcon]);
      expect(result, withTrailingSpace);
    });

    test('filters out icons already on the board', () {
      final result = service.suggest(['people:yo', 'verbs:querer']);
      expect(result, isNot(contains('people:yo')));
      expect(result, isNot(contains('verbs:querer')));
    });

    test('falls back to category suggestions for unknown icon', () {
      final result = service.suggest(['verbs:icon_unknown']);
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
