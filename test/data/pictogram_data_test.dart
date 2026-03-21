import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';

void main() {
  test('all icon lists use correct prefix and have no duplicates', () {
    final expected = {
      'descriptive:': descriptiveIcons,
      'people:': peopleIcons,
      'prepositions:': prepositionsIcons,
      'some:': someIcons,
      'substantive:': substantiveIcons,
      'verbs:': verbsIcons,
    };

    final allIcons = <String>[];
    for (final entry in expected.entries) {
      expect(entry.value, isNotEmpty, reason: '${entry.key} list is empty');
      for (final icon in entry.value) {
        expect(icon, startsWith(entry.key));
      }
      allIcons.addAll(entry.value);
    }

    expect(allIcons.toSet().length, allIcons.length,
        reason: 'Found duplicate icons');
  });

  test('keyboardCategories maps all icon lists', () {
    expect(keyboardCategories.length, 6);
    expect(keyboardCategories[0].icons, descriptiveIcons);
    expect(keyboardCategories[5].icons, verbsIcons);
  });
}
