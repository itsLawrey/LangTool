import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/deck.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/domain/recap/deck_filter.dart';
import 'package:langtool/ui/features/recap/deck_editor/view_models/deck_editor_view_model.dart';
import 'package:langtool/ui/features/recap/deck_editor/view_models/filters/added_filter_editor.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late DeckEditorViewModel viewModel;

  /// Today, as seen by the editor's date presets.
  final today = DateTime(2026, 10, 15);

  Future<DeckEditorViewModel> create({String? deckId}) async {
    viewModel = DeckEditorViewModel(
      deckRepository: repos.decks,
      packRepository: repos.packs,
      packId: pack.id,
      deckId: deckId,
      now: () => DateTime(2026, 10, 15, 12),
    );
    while (viewModel.loading) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return viewModel;
  }

  /// Waits until [condition] holds after the view model notifies.
  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  /// Adds a noun at local noon of [day].
  Future<void> addNounOn(DateTime day, String term) async {
    repos.now = DateTime(day.year, day.month, day.day, 12).toUtc();
    await repos.addNoun(pack, term);
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    await addNounOn(DateTime(2026, 10, 1), 'Haus');
    await addNounOn(today, 'Baum');
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('starts without filters and counts the whole pack', () async {
    await create();

    expect(viewModel.isEditing, isFalse);
    expect(viewModel.added.mode, AddedMode.anyTime);
    expect(viewModel.wordTypes.types, contains(WordType.noun));
    expect(viewModel.filters, isEmpty);
    await settle(() => viewModel.count == 2);
  });

  test('word type chips filter and recount', () async {
    await create();
    await settle(() => viewModel.count == 2);

    viewModel.wordTypes.setSelected(WordType.verb, true);
    expect(viewModel.filters, const [
      DeckFilter.wordTypes({WordType.verb}),
    ]);
    await settle(() => viewModel.count == 0);

    viewModel.wordTypes.setSelected(WordType.noun, true);
    await settle(() => viewModel.count == 2);

    viewModel.wordTypes
      ..setSelected(WordType.verb, false)
      ..setSelected(WordType.noun, false);
    expect(viewModel.filters, isEmpty);
    await settle(() => viewModel.count == 2);
  });

  test('presets fill the dates of a range ending today', () async {
    await create();
    final added = viewModel.added;

    added.applyPreset(AddedPreset.today);
    expect(added.mode, AddedMode.between);
    expect((added.from, added.to), (today, today));
    await settle(() => viewModel.count == 1);

    added.applyPreset(AddedPreset.last7Days);
    expect(added.from, DateTime(2026, 10, 9));
    await settle(() => viewModel.count == 1);

    added.applyPreset(AddedPreset.last30Days);
    expect(added.from, DateTime(2026, 9, 16));
    expect(added.to, today);
    await settle(() => viewModel.count == 2);
  });

  test('a range may be open on either side', () async {
    await create();
    final added = viewModel.added..setMode(AddedMode.between);
    expect(viewModel.filters, isEmpty);

    added.setFrom(DateTime(2026, 10, 10, 18, 30));
    expect(viewModel.filters, [
      DeckFilter.addedBetween(from: DateTime(2026, 10, 10)),
    ]);
    await settle(() => viewModel.count == 1);

    added
      ..setFrom(null)
      ..setTo(DateTime(2026, 10, 10));
    await settle(() => viewModel.count == 1);
    expect(viewModel.filters.single, isA<AddedBetween>());

    added.setMode(AddedMode.anyTime);
    expect(viewModel.filters, isEmpty);
    await settle(() => viewModel.count == 2);
  });

  test('last N days needs at least one day', () async {
    await create();
    final added = viewModel.added..setMode(AddedMode.lastDays);
    expect(added.lastDays, 7);
    expect(viewModel.filters, const [DeckFilter.addedInLastDays(7)]);
    await settle(() => viewModel.count == 1);

    added.setLastDays(0);
    expect(viewModel.filtersValid, isFalse);
    expect(viewModel.canSave, isFalse);
    expect(viewModel.count, isNull);

    added.setLastDays(null);
    expect(viewModel.canSave, isFalse);

    added.setLastDays(30);
    expect(viewModel.canSave, isTrue);
    await settle(() => viewModel.count == 2);
  });

  test('creates a deck with the filters', () async {
    await create();
    viewModel.wordTypes.setSelected(WordType.noun, true);

    final result = await viewModel.save('  Nouns ');

    final deck = (result as Ok<Deck>).value;
    expect(deck.name, 'Nouns');
    expect(deck.packId, pack.id);
    expect(deck.filters, const [
      DeckFilter.wordTypes({WordType.noun}),
    ]);
  });

  test('a blank name is rejected', () async {
    await create();

    final result = await viewModel.save(' ');

    expect(
      result,
      isA<Err<Deck>>().having(
        (e) => e.error,
        'error',
        isA<InvalidDeckNameException>(),
      ),
    );
  });

  test('editing loads the filters and keeps unknown ones', () async {
    const unknown = DeckFilter.unknown({
      'type': 'tags',
      'values': ['a'],
    });
    final filters = [
      DeckFilter.addedBetween(
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 10),
      ),
      const DeckFilter.wordTypes({WordType.noun, WordType.verb}),
      unknown,
    ];
    final deck = await repos.createDeck(pack, 'Old', filters);
    await create(deckId: deck.id);

    expect(viewModel.isEditing, isTrue);
    expect(viewModel.initial!.name, 'Old');
    expect(viewModel.added.mode, AddedMode.between);
    expect(viewModel.added.from, DateTime(2026, 10, 1));
    expect(viewModel.added.to, DateTime(2026, 10, 10));
    expect(viewModel.wordTypes.isSelected(WordType.verb), isTrue);
    expect(viewModel.keptFilters, [unknown]);
    // The unknown filter matches nothing.
    await settle(() => viewModel.count == 0);

    final result = await viewModel.save('Renamed');

    final saved = (result as Ok<Deck>).value;
    expect(saved.id, deck.id);
    expect(saved.name, 'Renamed');
    expect(saved.filters, filters);
  });

  test('editing loads last N days', () async {
    final deck = await repos.createDeck(pack, 'Recent', const [
      DeckFilter.addedInLastDays(3),
    ]);
    await create(deckId: deck.id);

    expect(viewModel.added.mode, AddedMode.lastDays);
    expect(viewModel.added.lastDays, 3);
    expect(viewModel.keptFilters, isEmpty);
    await settle(() => viewModel.count == 1);
  });

  test('a missing deck or pack is reported', () async {
    await create(deckId: 'nope');
    expect(viewModel.missing, isTrue);
  });
}
