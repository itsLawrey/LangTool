import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/transfer/view_models/import_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late Uint8List file;
  ImportViewModel? viewModel;

  ImportViewModel create(Uint8List bytes) => viewModel = ImportViewModel(
    transferRepository: repos.transfer,
    ownerId: 'user-2',
    bytes: bytes,
  );

  Future<List<String>> packNamesOf(String ownerId) async => [
    for (final pack in await repos.packs.watchPacks(ownerId).first) pack.name,
  ];

  setUp(() async {
    repos = TestRepositories();
    final alltag = await repos.createPack('Alltag');
    await repos.addNoun(alltag, 'Haus');
    await repos.addNoun(alltag, 'Auto');
    await repos.createDeck(alltag, 'Nouns');
    final reise = await repos.createPack('Reise');
    await repos.addNoun(reise, 'Ticket');
    final zuhause = await repos.createPack('Zuhause');
    file = await repos.transfer.export([alltag.id, reise.id, zuhause.id]);
  });

  tearDown(() async {
    viewModel?.dispose();
    viewModel = null;
    await repos.close();
  });

  test('decodes the file and selects every pack', () {
    create(file);

    expect(viewModel!.error, isNull);
    expect(
      [for (final p in viewModel!.packs) p.name],
      ['Alltag', 'Reise', 'Zuhause'],
    );
    expect(viewModel!.packs.first.entries, hasLength(2));
    expect(viewModel!.packs.first.decks, hasLength(1));
    expect(viewModel!.selected, {0, 1, 2});
    expect(viewModel!.canImport, isTrue);
  });

  test('reports a file it cannot read', () {
    create(Uint8List.fromList([1, 2, 3]));

    expect(
      viewModel!.error,
      isA<PackFileException>().having(
        (e) => e.reason,
        'reason',
        PackFileProblem.notLangTool,
      ),
    );
    expect(viewModel!.packs, isEmpty);
    expect(viewModel!.canImport, isFalse);
  });

  test('toggles the selection; an empty one cannot be imported', () {
    create(file);
    var notified = 0;
    viewModel!.addListener(() => notified++);

    viewModel!.toggle(1);
    expect(viewModel!.selected, {0, 2});
    viewModel!.toggle(0);
    viewModel!.toggle(2);
    expect(viewModel!.selected, isEmpty);
    expect(viewModel!.canImport, isFalse);
    viewModel!.toggle(1);
    expect(viewModel!.selected, {1});
    expect(notified, 4);
  });

  test('imports only the selected packs, in file order', () async {
    create(file);
    viewModel!.toggle(1);

    final future = viewModel!.import();
    expect(viewModel!.importing, isTrue);
    expect(viewModel!.canImport, isFalse);
    final result = await future;

    expect(viewModel!.importing, isFalse);
    final packs = (result as Ok<List<LanguagePack>>).value;
    expect([for (final p in packs) p.name], ['Alltag', 'Zuhause']);
    expect([for (final p in packs) p.ownerId], ['user-2', 'user-2']);
    expect(await packNamesOf('user-2'), ['Alltag', 'Zuhause']);
    expect(
      [for (final p in viewModel!.selectedPacks) p.name],
      ['Alltag', 'Zuhause'],
    );
  });
}
