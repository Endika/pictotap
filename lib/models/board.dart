import 'package:flutter/foundation.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/models/pictogram.dart';

class Board extends ChangeNotifier {
  final List<Pictogram> _icons = [];
  final int maxIcons;

  Board({this.maxIcons = defaultBoardMaxIcons});

  List<Pictogram> get icons => List.unmodifiable(_icons);
  int get length => _icons.length;
  bool get isEmpty => _icons.isEmpty;
  bool get isFull => _icons.length >= maxIcons;

  List<String> get iconIds => _icons.map((p) => p.id).toList();

  String get shareText => _icons.map((p) => p.displayName).join(' ');

  bool add(Pictogram pictogram) {
    if (isFull) return true;
    _icons.add(pictogram);
    notifyListeners();
    return _icons.length >= maxIcons;
  }

  bool addSpace() => add(Pictogram.space);

  Pictogram? removeLast() {
    if (_icons.isEmpty) return null;
    final removed = _icons.removeLast();
    notifyListeners();
    return removed;
  }

  void clear() {
    if (_icons.isEmpty) return;
    _icons.clear();
    notifyListeners();
  }
}
