import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/recap_session.dart';

Entry _entry(int i, {List<String> translations = const ['x']}) => Entry(
  id: 'entry-$i',
  ownerId: 'user-1',
  packId: 'pack-1',
  wordType: WordType.adverb,
  term: 'term$i',
  translations: translations,
  schemaVersion: 1,
  createdAt: DateTime.utc(2026, 10, 15),
  updatedAt: DateTime.utc(2026, 10, 15),
);

final _entries = [for (var i = 0; i < 20; i++) _entry(i)];

List<String> _order(RecapSession session) {
  final ids = <String>[];
  while (!session.isFinished) {
    ids.add(session.current!.entry.id);
    session
      ..reveal()
      ..answer(knewIt: true);
  }
  return ids;
}

List<CardSide> _fronts(RecapSession session) {
  final fronts = <CardSide>[];
  while (!session.isFinished) {
    fronts.add(session.current!.front);
    session
      ..reveal()
      ..answer(knewIt: true);
  }
  return fronts;
}

RecapSession _session(
  List<Entry> entries, {
  RecapDirection direction = RecapDirection.foreignFirst,
  int seed = 1,
}) =>
    RecapSession(entries: entries, direction: direction, random: Random(seed));

void main() {
  group('order', () {
    test('shuffles every entry exactly once', () {
      final order = _order(_session(_entries));

      expect(order, unorderedEquals([for (final e in _entries) e.id]));
      expect(order, isNot([for (final e in _entries) e.id]));
    });

    test('is deterministic for a seeded Random', () {
      expect(_order(_session(_entries)), _order(_session(_entries)));
      expect(
        _order(_session(_entries, seed: 1)),
        isNot(_order(_session(_entries, seed: 2))),
      );
    });

    test('does not change the given list', () {
      final entries = [..._entries];
      _session(entries);

      expect(entries, _entries);
    });
  });

  group('direction', () {
    test('foreignFirst shows the foreign side first', () {
      expect(_fronts(_session(_entries)), everyElement(CardSide.foreign));
    });

    test('translationFirst shows the translation first', () {
      expect(
        _fronts(_session(_entries, direction: RecapDirection.translationFirst)),
        everyElement(CardSide.translation),
      );
    });

    test('mixed picks a side per card, deterministically when seeded', () {
      final fronts = _fronts(
        _session(_entries, direction: RecapDirection.mixed),
      );

      expect(fronts, containsAll(CardSide.values));
      expect(
        _fronts(_session(_entries, direction: RecapDirection.mixed)),
        fronts,
      );
    });

    for (final direction in RecapDirection.values) {
      test('entries without translations show the foreign side '
          '(${direction.name})', () {
        final entries = [
          for (var i = 0; i < 10; i++) _entry(i, translations: const []),
        ];

        expect(
          _fronts(_session(entries, direction: direction)),
          everyElement(CardSide.foreign),
        );
      });
    }
  });

  group('answering', () {
    test('starts at the first card, hidden', () {
      final session = _session(_entries);

      expect(session.total, 20);
      expect(session.position, 0);
      expect(session.isFinished, isFalse);
      expect(session.current, isNotNull);
      expect(session.revealed, isFalse);
      expect(session.knownCount, 0);
      expect(session.unknownCount, 0);
      expect(session.missed, isEmpty);
    });

    test('answering before revealing is not allowed', () {
      final session = _session(_entries);

      expect(() => session.answer(knewIt: true), throwsStateError);
      expect(session.position, 0);
    });

    test('reveal shows the card; an answer moves on and hides it', () {
      final session = _session(_entries);
      final first = session.current!;

      session.reveal();
      expect(session.revealed, isTrue);
      expect(session.current, same(first));

      session.answer(knewIt: true);
      expect(session.position, 1);
      expect(session.revealed, isFalse);
      expect(session.current, isNot(same(first)));
    });

    test('counts answers and lists missed entries in session order', () {
      final session = _session(_entries.take(4).toList());
      final missed = <Entry>[];

      for (final knewIt in [false, true, false, true]) {
        if (!knewIt) missed.add(session.current!.entry);
        session
          ..reveal()
          ..answer(knewIt: knewIt);
      }

      expect(session.knownCount, 2);
      expect(session.unknownCount, 2);
      expect(session.missed, missed);
      expect(() => session.missed.add(_entry(99)), throwsUnsupportedError);
    });

    test('finishes after the last card', () {
      final session = _session(_entries.take(2).toList());
      _order(session);

      expect(session.isFinished, isTrue);
      expect(session.position, session.total);
      expect(session.current, isNull);
      expect(session.knownCount, 2);

      session.reveal();
      expect(session.revealed, isFalse);
      expect(() => session.answer(knewIt: true), throwsStateError);
    });

    test('an empty session is finished from the start', () {
      final session = _session(const []);

      expect(session.total, 0);
      expect(session.isFinished, isTrue);
      expect(session.current, isNull);
    });
  });
}
