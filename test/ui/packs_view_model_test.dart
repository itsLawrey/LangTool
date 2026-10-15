import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/packs/view_models/packs_view_model.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late PacksViewModel viewModel;

  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  List<String> names() => [for (final p in viewModel.packs) p.name];

  setUp(() {
    repos = TestRepositories();
    viewModel = PacksViewModel(packRepository: repos.packs, ownerId: 'user-1');
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('lists only the owner\'s packs, by name', () async {
    await repos.createPack('Wortschatz');
    await repos.createPack('Alltag');
    await repos.createPack('Fremd', 'user-2');

    await settle(() => names().length == 2);
    expect(viewModel.loading, isFalse);
    expect(names(), ['Alltag', 'Wortschatz']);
  });

  test('creates German packs and updates the list', () async {
    await settle(() => !viewModel.loading);

    final result = await viewModel.create('Deutsch');

    expect((result as Ok<LanguagePack>).value.languageCode, 'de');
    await settle(() => names().length == 1);
  });

  test('renames and deletes', () async {
    final pack = await repos.createPack('Alt');
    await settle(() => names().length == 1);

    await viewModel.rename(pack, 'Neu');
    await settle(() => names().single == 'Neu');

    await viewModel.delete(pack);
    await settle(() => names().isEmpty);
  });

  test('passes errors through', () async {
    expect(
      await viewModel.create('   '),
      isA<Err<LanguagePack>>().having(
        (e) => e.error,
        'error',
        isA<InvalidPackNameException>(),
      ),
    );
  });
}
