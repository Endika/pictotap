import 'package:pictotap/models/pictogram.dart';
import 'package:pictotap/services/recommendation_service.dart';

const RecommendationService _recommendations = RecommendationService();

String displayNameForIcon(String icon) => Pictogram.fromId(icon).displayName;

bool isAssetIcon(String icon) => Pictogram.fromId(icon).isAsset;

String? assetPathForIcon(String icon) => Pictogram.fromId(icon).assetPath;

List<String> buildRecommendations(List<String> selectedIcons) =>
    _recommendations.suggest(selectedIcons);
