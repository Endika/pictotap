import 'package:pictotap/data/pictogram_data.dart';

const List<String> _iconPrefixes = [
  'descriptive:',
  'people:',
  'prepositions:',
  'some:',
  'substantive:',
  'verbs:',
];

String displayNameForIcon(String icon) {
  if (icon == spaceIcon) return ' ';
  for (final prefix in _iconPrefixes) {
    if (icon.startsWith(prefix)) {
      return icon.substring(prefix.length);
    }
  }
  return icon;
}

bool isAssetIcon(String icon) {
  for (final prefix in _iconPrefixes) {
    if (icon.startsWith(prefix)) return true;
  }
  return false;
}

String? assetPathForIcon(String icon) {
  for (final prefix in _iconPrefixes) {
    if (icon.startsWith(prefix)) {
      final name = icon.substring(prefix.length);
      final folder = prefix.substring(0, prefix.length - 1);
      return 'assets/keyboard/$folder/$name.png';
    }
  }
  return null;
}

List<String> buildRecommendations(List<String> selectedIcons) {
  final recentUnique = <String>[];
  for (final icon in selectedIcons.reversed) {
    if (!recentUnique.contains(icon)) {
      recentUnique.add(icon);
    }
    if (recentUnique.length >= maxRecommendationIcons) break;
  }
  return recentUnique;
}
