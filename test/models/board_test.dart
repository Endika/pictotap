import 'package:flutter_test/flutter_test.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/models/board.dart';
import 'package:pictotap/models/pictogram.dart';

void main() {
  group('Board', () {
    late Board board;

    setUp(() => board = Board());

    tearDown(() => board.dispose());

    test('starts empty', () {
      expect(board.isEmpty, true);
      expect(board.length, 0);
      expect(board.icons, isEmpty);
    });

    test('add puts pictogram on board', () {
      board.add(Pictogram.fromId('verbs:comer'));
      expect(board.length, 1);
      expect(board.icons.first.id, 'verbs:comer');
    });

    test('add returns true when limit reached', () {
      for (var i = 0; i < defaultBoardMaxIcons - 1; i++) {
        expect(board.add(Pictogram.fromId('verbs:comer')), false);
      }
      expect(board.add(Pictogram.fromId('verbs:beber')), true);
    });

    test('add on full board returns true without adding', () {
      for (var i = 0; i < defaultBoardMaxIcons; i++) {
        board.add(Pictogram.fromId('verbs:comer'));
      }
      final previousLength = board.length;
      expect(board.add(Pictogram.fromId('verbs:bailar')), true);
      expect(board.length, previousLength);
    });

    test('isFull reports correctly', () {
      expect(board.isFull, false);
      for (var i = 0; i < defaultBoardMaxIcons; i++) {
        board.add(Pictogram.fromId('verbs:comer'));
      }
      expect(board.isFull, true);
    });

    test('addSpace adds a space pictogram', () {
      board.addSpace();
      expect(board.icons.first.isSpace, true);
    });

    test('removeLast removes and returns last icon', () {
      board.add(Pictogram.fromId('people:mama'));
      board.add(Pictogram.fromId('verbs:comer'));
      final removed = board.removeLast();
      expect(removed?.id, 'verbs:comer');
      expect(board.length, 1);
    });

    test('removeLast on empty board returns null', () {
      expect(board.removeLast(), isNull);
    });

    test('clear empties the board', () {
      board.add(Pictogram.fromId('people:mama'));
      board.add(Pictogram.fromId('verbs:comer'));
      board.clear();
      expect(board.isEmpty, true);
    });

    test('shareText joins display names', () {
      board.add(Pictogram.fromId('people:yo'));
      board.add(Pictogram.fromId('verbs:querer'));
      expect(board.shareText, 'yo querer');
    });

    test('iconIds returns string ids', () {
      board.add(Pictogram.fromId('people:yo'));
      board.addSpace();
      expect(board.iconIds, ['people:yo', spaceIcon]);
    });

    test('notifies listeners on mutations', () {
      var count = 0;
      board.addListener(() => count++);
      board.add(Pictogram.fromId('verbs:comer'));
      expect(count, 1);
      board.removeLast();
      expect(count, 2);
    });

    test('icons list is unmodifiable', () {
      board.add(Pictogram.fromId('verbs:comer'));
      expect(() => board.icons.add(Pictogram.space), throwsUnsupportedError);
    });
  });
}
