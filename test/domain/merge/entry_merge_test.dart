import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/merge/entry_merge.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/word_type.dart';

final _base = DateTime.utc(2026, 10, 1);

Entry _entry(
  String term, {
  int created = 0,
  int updated = 0,
  Map<String, String> forms = const {'article': 'das'},
  List<String> translations = const [],
  List<Example> examples = const [],
  List<String> tags = const [],
  String? notes,
  WordType wordType = WordType.noun,
}) => Entry(
  id: '$term-$created-$updated',
  ownerId: 'user-1',
  packId: 'pack',
  wordType: wordType,
  term: term,
  forms: forms,
  translations: translations,
  examples: examples,
  tags: tags,
  notes: notes,
  schemaVersion: 1,
  createdAt: _base.add(Duration(days: created)),
  updatedAt: _base.add(Duration(days: updated)),
);

MergeSource _from(Entry entry, String pack, [int order = 0]) =>
    (entry: entry, packName: pack, packOrder: order);

String _describe(FormClash clash) =>
    '${clash.formKey} (from ${clash.packName}): ${clash.value}';

Entry _merge(List<MergeSource> group) => mergeEntries(
  group,
  id: 'merged',
  ownerId: 'user-1',
  packId: 'new-pack',
  schemaVersion: 1,
  updatedAt: DateTime.utc(2026, 10, 17),
  describeClash: _describe,
);

void main() {
  test('mergeKey matches the duplicate rule', () {
    expect(mergeKey(_entry('Haus')), mergeKey(_entry(' haus ')));
    expect(mergeKey(_entry('schon')), isNot(mergeKey(_entry('schön'))));
    expect(
      mergeKey(_entry('laufen', wordType: WordType.verb)),
      isNot(mergeKey(_entry('laufen'))),
    );
  });

  test('a single entry is copied with the new identity', () {
    final entry = _entry(
      'Haus',
      created: 2,
      updated: 5,
      translations: ['house'],
      tags: ['A1'],
      notes: 'neuter',
    );

    final merged = _merge([_from(entry, 'A')]);

    expect(
      merged,
      entry.copyWith(
        id: 'merged',
        packId: 'new-pack',
        updatedAt: DateTime.utc(2026, 10, 17),
      ),
    );
  });

  test('keeps every unique translation, oldest entry first', () {
    final merged = _merge([
      _from(_entry('Haus', created: 3, translations: ['home', 'ház']), 'B'),
      _from(_entry('Haus', created: 1, translations: ['house', 'Home ']), 'A'),
    ]);

    expect(merged.translations, ['house', 'Home', 'ház']);
  });

  test('tags combine ignoring case and spaces, but not umlauts', () {
    final merged = _merge([
      _from(_entry('Haus', created: 1, tags: ['A1', 'Möbel']), 'A'),
      _from(_entry('Haus', created: 2, tags: [' a1', 'Mobel', 'möbel']), 'B'),
    ]);

    expect(merged.tags, ['A1', 'Möbel', 'Mobel']);
  });

  test('keeps unique examples and drops untranslated repeats', () {
    final merged = _merge([
      _from(
        _entry(
          'Haus',
          created: 1,
          examples: [
            const Example(text: 'Das Haus ist groß.'),
            const Example(text: 'Ein Haus.', translation: 'A house.'),
          ],
        ),
        'A',
      ),
      _from(
        _entry(
          'Haus',
          created: 2,
          examples: [
            const Example(
              text: 'das haus ist groß.',
              translation: 'The house is big.',
            ),
            const Example(text: 'Ein Haus.', translation: 'a house.'),
            const Example(text: 'Ein Haus.', translation: 'One house.'),
          ],
        ),
        'B',
      ),
    ]);

    expect(merged.examples, [
      const Example(text: 'Ein Haus.', translation: 'A house.'),
      const Example(
        text: 'das haus ist groß.',
        translation: 'The house is big.',
      ),
      const Example(text: 'Ein Haus.', translation: 'One house.'),
    ]);
  });

  test('the newest entry wins the forms and the term spelling', () {
    final merged = _merge([
      _from(
        _entry(
          'haus',
          updated: 5,
          forms: {'article': 'das', 'plural': 'Häuser'},
        ),
        'A',
      ),
      _from(
        _entry(
          'Haus',
          updated: 1,
          forms: {'article': 'der', 'plural': 'Häuser'},
        ),
        'B',
      ),
    ]);

    expect(merged.term, 'haus');
    expect(merged.forms, {'article': 'das', 'plural': 'Häuser'});
    expect(merged.notes, 'article (from B): der');
  });

  test('forms only an older entry has are kept without a note', () {
    final merged = _merge([
      _from(_entry('Haus', updated: 5), 'A'),
      _from(
        _entry(
          'Haus',
          updated: 1,
          forms: {'article': 'das', 'plural': 'Häuser'},
        ),
        'B',
      ),
    ]);

    expect(merged.forms, {'article': 'das', 'plural': 'Häuser'});
    expect(merged.notes, isNull);
  });

  test('equal edit times go to the later pack in the selection', () {
    final merged = _merge([
      _from(_entry('Haus', forms: {'article': 'der'}), 'A', 0),
      _from(_entry('Haus', forms: {'article': 'das'}), 'B', 1),
    ]);

    expect(merged.forms['article'], 'das');
    expect(merged.notes, 'article (from A): der');
  });

  test('notes keep unique ones in order, then the clashes', () {
    final merged = _merge([
      _from(_entry('Haus', created: 1, updated: 1, notes: 'neuter'), 'A'),
      _from(
        _entry(
          'Haus',
          created: 2,
          updated: 9,
          forms: {'article': 'das', 'plural': 'Häuser'},
          notes: ' Neuter',
        ),
        'B',
      ),
      _from(
        _entry(
          'Haus',
          created: 3,
          updated: 2,
          forms: {'article': 'der', 'plural': 'Hause'},
          notes: 'irregular plural',
        ),
        'C',
      ),
    ]);

    expect(
      merged.notes,
      'neuter\n\nirregular plural\n\n'
      'article (from C): der\nplural (from C): Hause',
    );
  });

  test('the same losing value from two packs is noted once', () {
    final merged = _merge([
      _from(_entry('Haus', updated: 9), 'A'),
      _from(_entry('Haus', updated: 2, forms: {'article': 'der'}), 'B'),
      _from(_entry('Haus', updated: 1, forms: {'article': 'Der'}), 'C'),
    ]);

    expect(merged.notes, 'article (from B): der');
  });

  test('keeps the earliest creation time', () {
    final merged = _merge([
      _from(_entry('Haus', created: 4), 'A'),
      _from(_entry('Haus', created: 2), 'B'),
      _from(_entry('Haus', created: 7), 'C'),
    ]);

    expect(merged.createdAt, _base.add(const Duration(days: 2)));
  });

  test('cleans the source entries first', () {
    final merged = _merge([
      _from(_entry('Haus', translations: [' house ', ''], tags: ['  ']), 'A'),
    ]);

    expect(merged.translations, ['house']);
    expect(merged.tags, isEmpty);
  });
}
