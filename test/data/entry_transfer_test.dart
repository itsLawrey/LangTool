import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/data/local/app_database.dart';
import 'package:langtool/domain/exceptions.dart';
import 'package:langtool/domain/merge/entry_merge.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/utils/result.dart';

import '../helpers/fake_remote_sync_api.dart';
import '../helpers/sync_device.dart';
import '../helpers/test_repositories.dart';

String _describe(FormClash clash) =>
    '${clash.formKey} (${clash.packName}): ${clash.value}';

void main() {
  late TestRepositories repos;
  late LanguagePack alltag;
  late LanguagePack reise;

  setUp(() async {
    repos = TestRepositories();
    alltag = await repos.createPack('Alltag');
    reise = await repos.createPack('Reise');
  });

  tearDown(() => repos.close());

  Future<Result<Entry>> transfer(
    Entry entry, {
    LanguagePack? to,
    required bool move,
    bool combine = false,
  }) => repos.entries.transfer(
    entry.id,
    targetPackId: (to ?? reise).id,
    move: move,
    combine: combine ? _describe : null,
  );

  Entry ok(Result<Entry> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw StateError('$error'),
  };

  Future<List<Entry>> entriesOf(LanguagePack pack) =>
      repos.entries.watchEntries(pack.id).first;

  Future<EntryRow> row(String id) => (repos.db.select(
    repos.db.entries,
  )..where((e) => e.id.equals(id))).getSingle();

  test('copies an entry with a new id, keeping its creation time', () async {
    final haus = await repos.addNoun(alltag, 'Haus', translations: ['house']);

    final copy = ok(await transfer(haus, move: false));

    expect(copy.id, isNot(haus.id));
    expect(copy.packId, reise.id);
    expect(copy.createdAt, haus.createdAt);
    expect(copy.translations, ['house']);
    expect(await entriesOf(alltag), [haus]);
    expect(await entriesOf(reise), [copy]);
    expect((await row(copy.id)).needsPush, isTrue);
  });

  test('moves the entry itself to the other pack', () async {
    final haus = await repos.addNoun(alltag, 'Haus');

    final moved = ok(await transfer(haus, move: true));

    expect(moved.id, haus.id);
    expect(moved.packId, reise.id);
    expect(moved.createdAt, haus.createdAt);
    expect(await entriesOf(alltag), isEmpty);
    expect((await entriesOf(reise)).single.id, haus.id);
    expect((await row(haus.id)).needsPush, isTrue);
  });

  test('a duplicate in the target pack fails unless combining', () async {
    final haus = await repos.addNoun(alltag, 'Haus');
    final existing = await repos.addNoun(reise, ' haus ');

    final result = await transfer(haus, move: true);

    expect(
      result,
      isA<Err<Entry>>().having(
        (e) => e.error,
        'error',
        isA<DuplicateEntryException>().having(
          (e) => e.existing.id,
          'existing',
          existing.id,
        ),
      ),
    );
    expect(await entriesOf(alltag), hasLength(1));
  });

  test('copying into a duplicate combines both and keeps the source', () async {
    final haus = await repos.addNoun(alltag, 'Haus', translations: ['house']);
    final existing = await repos.addNoun(
      reise,
      'Haus',
      article: 'der',
      translations: ['home'],
    );

    final combined = ok(await transfer(haus, move: false, combine: true));

    expect(combined.id, existing.id);
    expect(combined.translations, ['house', 'home']);
    // The source was edited before the existing one, so it loses the form.
    expect(combined.forms['article'], 'der');
    expect(combined.notes, 'article (Alltag): das');
    expect(combined.createdAt, existing.createdAt);
    expect(await entriesOf(reise), [combined]);
    expect(await entriesOf(alltag), [haus]);
  });

  test(
    'moving into a duplicate combines both and deletes the source',
    () async {
      final haus = await repos.addNoun(alltag, 'Haus', translations: ['house']);
      await repos.addNoun(reise, 'Haus', translations: ['home']);

      final combined = ok(await transfer(haus, move: true, combine: true));

      expect(combined.translations, ['house', 'home']);
      expect(await entriesOf(alltag), isEmpty);
      expect(await entriesOf(reise), [combined]);
      final source = await row(haus.id);
      expect(source.deletedAt, isNotNull);
      expect(source.needsPush, isTrue);
    },
  );

  test('rejects packs of another language and missing ones', () async {
    final haus = await repos.addNoun(alltag, 'Haus');
    await (repos.db.update(repos.db.languagePacks)
          ..where((p) => p.id.equals(reise.id)))
        .write(const LanguagePacksCompanion(languageCode: Value('hu')));

    expect(
      await transfer(haus, move: true),
      isA<Err<Entry>>().having(
        (e) => e.error,
        'error',
        isA<LanguageMismatchException>(),
      ),
    );
    await repos.packs.delete(reise.id);
    expect(
      await transfer(haus, move: false),
      isA<Err<Entry>>().having(
        (e) => e.error,
        'error',
        isA<NotFoundException>(),
      ),
    );
    expect(await entriesOf(alltag), [haus]);
  });

  test('the same pack leaves the entry as it is', () async {
    final haus = await repos.addNoun(alltag, 'Haus');

    expect(ok(await transfer(haus, to: alltag, move: true)), haus);
    expect(await entriesOf(alltag), [haus]);
  });

  test('a moved entry arrives in the other pack on another device', () async {
    final server = FakeRemoteSyncApi();
    final phone = SyncDevice('phone', server);
    final laptop = SyncDevice('laptop', server);
    addTearDown(phone.close);
    addTearDown(laptop.close);
    final a = await phone.repos.createPack('A');
    final b = await phone.repos.createPack('B');
    final haus = await phone.repos.addNoun(a, 'Haus');
    await phone.sync();
    await laptop.sync();

    await phone.repos.entries.transfer(haus.id, targetPackId: b.id, move: true);
    await phone.sync();
    await laptop.sync();

    expect(await laptop.entries(a.id), isEmpty);
    expect((await laptop.entries(b.id)).single.id, haus.id);
  });
}
