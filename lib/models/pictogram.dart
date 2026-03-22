import 'package:pictotap/data/pictogram_data.dart';

const List<String> _knownCategories = [
  'descriptive',
  'people',
  'prepositions',
  'some',
  'substantive',
  'verbs',
];

class Pictogram {
  final String category;
  final String name;

  const Pictogram._({required this.category, required this.name});

  static const Pictogram space = Pictogram._(category: '', name: spaceIcon);

  factory Pictogram.fromId(String id) {
    if (id == spaceIcon) return space;
    final sep = id.indexOf(':');
    if (sep <= 0) {
      return Pictogram._(category: '', name: id);
    }
    return Pictogram._(
      category: id.substring(0, sep),
      name: id.substring(sep + 1),
    );
  }

  String get id => isSpace ? spaceIcon : '$category:$name';

  bool get isSpace => identical(this, space) || name == spaceIcon;

  bool get isAsset =>
      category.isNotEmpty && _knownCategories.contains(category);

  String get displayName => isSpace ? ' ' : name;

  String? get assetPath =>
      isAsset ? 'assets/keyboard/$category/$name.png' : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Pictogram && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Pictogram($id)';
}
