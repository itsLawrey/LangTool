import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/ui/features/timeline/view_models/timeline_items.dart';
import 'package:langtool/ui/features/timeline/view_models/timeline_view_model.dart';

import '../helpers/test_repositories.dart';

void main() {
  late TestRepositories repos;
  late LanguagePack pack;
  late TimelineViewModel viewModel;

  TimelineViewModel create({int pageSize = 50}) => TimelineViewModel(
    entryRepository: repos.entries,
    packRepository: repos.packs,
    packId: pack.id,
    pageSize: pageSize,
    searchDebounce: Duration.zero,
  );

  /// Waits until [condition] holds after the view model notifies.
  Future<void> settle(bool Function() condition) async {
    for (var i = 0; i < 100 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(condition(), isTrue, reason: 'condition not reached');
  }

  List<String> terms() => [
    for (final item in viewModel.items)
      if (item case EntryItem(:final entry)) entry.term,
  ];

  setUp(() async {
    repos = TestRepositories();
    pack = await repos.createPack();
  });

  tearDown(() async {
    viewModel.dispose();
    await repos.close();
  });

  test('shows entries newest first, grouped by day', () async {
    await repos.addNoun(pack, 'Haus');
    await repos.addNoun(pack, 'Baum', article: 'der');
    viewModel = create();

    await settle(() => !viewModel.loading && viewModel.pack != null);

    expect(viewModel.pack!.name, 'Deutsch');
    expect(viewModel.items.first, isA<DayHeaderItem>());
    expect(terms(), ['Baum', 'Haus']);
  });

  test('loads older entries page by page', () async {
    for (var i = 0; i < 5; i++) {
      await repos.addNoun(pack, 'Wort$i');
    }
    viewModel = create(pageSize: 2);
    await settle(() => !viewModel.loading);
    expect(terms(), ['Wort4', 'Wort3']);
    expect(viewModel.hasMore, isTrue);

    viewModel.loadMore();
    await settle(() => terms().length == 4);
    viewModel.loadMore();
    await settle(() => terms().length == 5);

    expect(viewModel.hasMore, isFalse);
  });

  test('picks up new entries without reloading', () async {
    viewModel = create();
    await settle(() => !viewModel.loading);
    expect(viewModel.items, isEmpty);

    await repos.addNoun(pack, 'Haus');

    await settle(() => terms().isNotEmpty);
    expect(terms(), ['Haus']);
  });

  test('search filters the timeline and clearing restores it', () async {
    await repos.addNoun(pack, 'Haus', translations: ['house']);
    await repos.addNoun(pack, 'Maus', article: 'die', translations: ['mouse']);
    viewModel = create();
    await settle(() => !viewModel.loading);

    viewModel.search('house');
    await settle(() => !viewModel.loading);
    expect(terms(), ['Haus']);
    expect(viewModel.showingSimilar, isFalse);

    viewModel.search('');
    await settle(() => terms().length == 2);
  });

  test('search shows best matches first, without day headers', () async {
    await repos.addNoun(pack, 'Haus');
    await repos.addNoun(pack, 'Krankenhaus');
    await repos.addNoun(pack, 'Hausaufgabe', article: 'die');
    viewModel = create();
    await settle(() => !viewModel.loading);

    viewModel.search('haus');
    await settle(() => !viewModel.loading);

    expect(terms(), ['Haus', 'Hausaufgabe', 'Krankenhaus']);
    expect(viewModel.items, everyElement(isA<EntryItem>()));
  });

  test('flags typo-tolerant results as similar', () async {
    await repos.addNoun(pack, 'Haus');
    viewModel = create();
    await settle(() => !viewModel.loading);

    viewModel.search('hasu');
    await settle(() => !viewModel.loading);

    expect(terms(), ['Haus']);
    expect(viewModel.showingSimilar, isTrue);
  });

  test('re-runs the search when entries change', () async {
    viewModel = create();
    await settle(() => !viewModel.loading);
    viewModel.search('haus');
    await settle(() => !viewModel.loading);
    expect(terms(), isEmpty);

    await repos.addNoun(pack, 'Haus');

    await settle(() => terms().isNotEmpty);
  });

  test('reports a missing pack', () async {
    await repos.packs.delete(pack.id);
    viewModel = create();

    await settle(() => viewModel.packMissing);
  });
}
