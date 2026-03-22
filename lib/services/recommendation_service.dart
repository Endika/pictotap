import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/data/pictogram_recommendations.dart';

class RecommendationService {
  const RecommendationService();

  List<String> suggest(List<String> selectedIconIds) {
    if (selectedIconIds.isEmpty) {
      return defaultSuggestions.take(maxRecommendationIcons).toList();
    }

    final lastIcon = _lastNonSpace(selectedIconIds);
    if (lastIcon == null) {
      return defaultSuggestions.take(maxRecommendationIcons).toList();
    }

    final alreadyOnBoard = selectedIconIds.toSet();

    final direct = nextWordSuggestions[lastIcon];
    if (direct != null && direct.isNotEmpty) {
      final filtered = _filterUsed(direct, alreadyOnBoard);
      if (filtered.length >= maxRecommendationIcons) {
        return filtered.take(maxRecommendationIcons).toList();
      }
      final result = List<String>.from(filtered);
      _fillFromCategory(lastIcon, alreadyOnBoard, result);
      return result.take(maxRecommendationIcons).toList();
    }

    final categoryResult = <String>[];
    _fillFromCategory(lastIcon, alreadyOnBoard, categoryResult);
    if (categoryResult.isNotEmpty) {
      return categoryResult.take(maxRecommendationIcons).toList();
    }

    return defaultSuggestions
        .where((c) => !alreadyOnBoard.contains(c))
        .take(maxRecommendationIcons)
        .toList();
  }

  String? _lastNonSpace(List<String> icons) {
    for (final icon in icons.reversed) {
      if (icon != spaceIcon) return icon;
    }
    return null;
  }

  List<String> _filterUsed(List<String> candidates, Set<String> used) =>
      candidates.where((c) => !used.contains(c)).toList();

  void _fillFromCategory(
    String icon,
    Set<String> alreadyOnBoard,
    List<String> result,
  ) {
    final category = _categoryOf(icon);
    if (category == null) return;
    final fallback = categoryFallbacks[category];
    if (fallback == null) return;
    for (final fb in fallback) {
      if (!alreadyOnBoard.contains(fb) && !result.contains(fb)) {
        result.add(fb);
      }
      if (result.length >= maxRecommendationIcons) break;
    }
  }

  static String? _categoryOf(String icon) {
    final idx = icon.indexOf(':');
    return idx > 0 ? icon.substring(0, idx) : null;
  }
}
