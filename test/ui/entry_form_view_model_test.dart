import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/entry_draft.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:langtool/ui/features/entry_form/view_models/entry_form_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;

  Future<EntryFormViewModel> create({String? entryId}) async {
    final viewModel = EntryFormViewModel(
      entryRepository: repos.entries,
      packRepository: repos.packs,
      packId: pack.id,
      entryId: entryId,
    );
    while (viewModel.loading) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return viewModel;
  }

  EntryDraft noun(String term) => EntryDraft(
    packId: 'ignored',
    wordType: WordType.noun,
    term: term,
    forms: {'article': 'das'},
  );

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
  });

  tearDown(() => repos.close());

  test('adds an entry to its pack', () async {
    final viewModel = await create();

    final result = await viewModel.save(noun('Haus'));

    expect(viewModel.schema?.code, 'de');
    expect(result, isA<Ok<Object?>>());
    expect((result as Ok).value.packId, pack.id);
  });

  test('reports duplicates with the existing entry', () async {
    final existing = await repos.addNoun(pack, 'Haus');
    final viewModel = await create();

    final result = await viewModel.save(noun('haus'));

    expect(
      result,
      isA<Err<Object?>>().having(
        (e) => (e.error as DuplicateEntryException).existing,
        'existing',
        existing,
      ),
    );
  });

  test('finds similar entries when adding', () async {
    await repos.addNoun(pack, 'Haus');
    final viewModel = await create();

    final similar = await viewModel.findSimilar('Hasu', WordType.noun);

    expect([for (final e in similar) e.term], ['Haus']);
  });

  test(
    'edits an entry and skips the similar check if the term is kept',
    () async {
      await repos.addNoun(pack, 'Maus', article: 'die');
      final haus = await repos.addNoun(pack, 'Haus');
      final viewModel = await create(entryId: haus.id);

      expect(viewModel.initial, haus);
      expect(await viewModel.findSimilar(' haus', WordType.noun), isEmpty);
      expect(await viewModel.findSimilar('Mause', WordType.noun), isNotEmpty);

      final result = await viewModel.save(
        noun('Haus').copyWith(translations: ['house']),
      );
      expect((result as Ok).value.translations, ['house']);
    },
  );

  test('reports a missing entry', () async {
    final viewModel = await create(entryId: 'missing');

    expect(viewModel.missing, isTrue);
  });
}
