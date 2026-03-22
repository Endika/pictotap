import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/data/pictogram_recommendations.dart';

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

String? _categoryOf(String icon) {
  final idx = icon.indexOf(':');
  return idx > 0 ? icon.substring(0, idx) : null;
}

List<String> buildRecommendations(List<String> selectedIcons) {
  if (selectedIcons.isEmpty) {
    return defaultSuggestions.take(maxRecommendationIcons).toList();
  }

  String? lastIcon;
  for (final icon in selectedIcons.reversed) {
    if (icon != spaceIcon) {
      lastIcon = icon;
      break;
    }
  }
  if (lastIcon == null) {
    return defaultSuggestions.take(maxRecommendationIcons).toList();
  }

  final alreadyOnBoard = selectedIcons.toSet();
  List<String> filterUsed(List<String> candidates) =>
      candidates.where((c) => !alreadyOnBoard.contains(c)).toList();

  final direct = nextWordSuggestions[lastIcon];
  if (direct != null && direct.isNotEmpty) {
    final filtered = filterUsed(direct);
    if (filtered.length >= maxRecommendationIcons) {
      return filtered.take(maxRecommendationIcons).toList();
    }
    final result = List<String>.from(filtered);
    final category = _categoryOf(lastIcon);
    if (category != null) {
      final fallback = categoryFallbacks[category];
      if (fallback != null) {
        for (final icon in fallback) {
          if (!alreadyOnBoard.contains(icon) && !result.contains(icon)) {
            result.add(icon);
          }
          if (result.length >= maxRecommendationIcons) break;
        }
      }
    }
    return result.take(maxRecommendationIcons).toList();
  }

  final category = _categoryOf(lastIcon);
  if (category != null) {
    final fallback = categoryFallbacks[category];
    if (fallback != null) {
      final filtered = filterUsed(fallback);
      if (filtered.isNotEmpty) {
        return filtered.take(maxRecommendationIcons).toList();
      }
    }
  }

  return defaultSuggestions
      .where((c) => !alreadyOnBoard.contains(c))
      .take(maxRecommendationIcons)
      .toList();
}
