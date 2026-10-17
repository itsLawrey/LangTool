import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/entry_detail/view_models/entry_detail_view_model.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late Entry haus;

  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  EntryDetailViewModel create(String entryId) {
    final viewModel = EntryDetailViewModel(
      entryRepository: repos.entries,
      packRepository: repos.packs,
      packId: pack.id,
      entryId: entryId,
    );
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
    haus = await repos.addNoun(pack, 'Haus', translations: ['house']);
  });

  tearDown(() => repos.close());

  test('loads the entry and its language schema', () async {
    final viewModel = create(haus.id);

    await settle(() => !viewModel.loading);

    expect(viewModel.entry, haus);
    expect(viewModel.schema?.code, 'de');
  });

  test('shows edits made elsewhere', () async {
    final viewModel = create(haus.id);
    await settle(() => !viewModel.loading);

    await repos.entries.update(haus.copyWith(translations: ['home']));

    await settle(() => viewModel.entry?.translations.single == 'home');
  });

  test('clears the entry once it is deleted', () async {
    final viewModel = create(haus.id);
    await settle(() => !viewModel.loading);

    await repos.entries.delete(haus.id);

    await settle(() => viewModel.entry == null);
  });

  test('reports a missing entry', () async {
    final viewModel = create('missing');

    await settle(() => !viewModel.loading);

    expect(viewModel.entry, isNull);
  });
}
