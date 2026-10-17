import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/transfer/pack_file_pack.dart';
import 'package:langtool/ui/features/transfer/view_models/export_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_file_service.dart';
import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late FakeFileService files;
  late ExportViewModel viewModel;
  late LanguagePack alltag;
  late LanguagePack reise;

  /// Waits until [condition] holds after the view model notifies.
  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  List<String> names() => [for (final p in viewModel.packs) p.name];

  LanguagePack pack(String name) => LanguagePack(
    id: name,
    ownerId: 'user-1',
    name: name,
    languageCode: 'de',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  setUp(() async {
    repos = TestRepositories();
    files = FakeFileService();
    reise = await repos.createPack('Reise');
    alltag = await repos.createPack('Alltag');
    await repos.addNoun(alltag, 'Haus');
    await repos.createPack('Fremd', 'user-2');
    viewModel = ExportViewModel(
      packRepository: repos.packs,
      transferRepository: repos.transfer,
      fileService: files,
      ownerId: 'user-1',
      clock: () => DateTime(2026, 3, 7, 23, 30),
    );
    await settle(() => !viewModel.loading);
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('lists the owner\'s packs with none selected', () {
    expect(names(), ['Alltag', 'Reise']);
    expect(viewModel.selected, isEmpty);
    expect(viewModel.canExport, isFalse);
  });

  test('toggles packs and all packs', () {
    viewModel.toggle(reise.id);
    expect(viewModel.selected, {reise.id});
    expect(viewModel.canExport, isTrue);
    expect(viewModel.allSelected, isFalse);

    viewModel.toggleAll();
    expect(viewModel.selected, {alltag.id, reise.id});
    expect(viewModel.allSelected, isTrue);

    viewModel.toggleAll();
    expect(viewModel.selected, isEmpty);

    viewModel.toggle(reise.id);
    viewModel.toggle(reise.id);
    expect(viewModel.selected, isEmpty);
  });

  test('drops deleted packs from the selection', () async {
    viewModel.toggleAll();
    await repos.packs.delete(reise.id);
    await settle(() => names().length == 1);

    expect(viewModel.selected, {alltag.id});
  });

  test('saves the selected packs in list order under a dated name', () async {
    viewModel.toggle(reise.id);
    viewModel.toggle(alltag.id);

    final future = viewModel.export();
    expect(viewModel.exporting, isTrue);
    expect(viewModel.canExport, isFalse);
    final result = await future;

    expect((result as Ok<bool>).value, isTrue);
    expect(viewModel.exporting, isFalse);
    final saved = files.saved.single;
    expect(saved.name, 'langtool-packs-2026-03-07.langtool');
    final packs =
        (repos.transfer.decode(saved.bytes) as Ok<List<PackFilePack>>).value;
    expect([for (final p in packs) p.name], ['Alltag', 'Reise']);
    expect(packs.first.entries.single.term, 'Haus');
  });

  test('names a single pack\'s file after the pack', () async {
    viewModel.toggle(alltag.id);

    await viewModel.export();

    expect(files.saved.single.name, 'Alltag.langtool');
  });

  test('returns false when the save is cancelled', () async {
    files.cancelSave = true;
    viewModel.toggle(alltag.id);

    final result = await viewModel.export();

    expect((result as Ok<bool>).value, isFalse);
    expect(files.saved, isEmpty);
  });

  test('passes a failed save through', () async {
    files.saveFailure = Exception('disk full');
    viewModel.toggle(alltag.id);

    final result = await viewModel.export();

    expect(result, isA<Err<bool>>());
    expect(viewModel.exporting, isFalse);
  });

  group('suggestedFileName', () {
    final now = DateTime(2026, 12, 1, 8);

    test('uses the pack name for one pack', () {
      expect(suggestedFileName([pack('Alltag')], now), 'Alltag.langtool');
    });

    test('replaces characters not allowed in file names', () {
      expect(
        suggestedFileName([pack(' A/B\\C:D*E?F"G<H>I|J\u0007K ')], now),
        'A_B_C_D_E_F_G_H_I_J_K.langtool',
      );
    });

    test('falls back to a default for a name with nothing left', () {
      expect(suggestedFileName([pack('   ')], now), 'langtool-pack.langtool');
    });

    test('uses the local date for several packs', () {
      expect(
        suggestedFileName([pack('A'), pack('B')], now),
        'langtool-packs-2026-12-01.langtool',
      );
    });
  });
}
