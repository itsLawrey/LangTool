import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:langtool/data/repositories/settings_repository.dart';
import 'package:langtool/data/services/in_memory_settings_store.dart';
import 'package:langtool/ui/features/options/view_models/options_view_model.dart';
import 'package:langtool/ui/features/options/views/options_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_repositories.dart';
import '../helpers/widget_harness.dart';

void main() {
  late TestRepositories repos;
  late InMemorySettingsStore store;
  late SettingsRepository settings;

  setUp(() {
    repos = TestRepositories();
    store = InMemorySettingsStore();
    settings = SettingsRepository(store);
  });

  Future<void> openOptions(WidgetTester tester) => pumpRoutes(
    tester,
    repos: repos,
    settings: settings,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => ChangeNotifierProvider(
          create: (context) =>
              OptionsViewModel(settingsRepository: context.read()),
          child: const OptionsScreen(),
        ),
      ),
    ],
  );

  bool switchValue(WidgetTester tester, String title) => tester
      .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
      .value;

  testWidgets('shows both options, off by default', (tester) async {
    await openOptions(tester);

    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Comma-separated translations'), findsOneWidget);
    expect(
      find.text('Type all translations in one field, separated by commas.'),
      findsOneWidget,
    );
    expect(find.text('Quick add mode'), findsOneWidget);
    expect(
      find.text('Ctrl+Enter saves the entry and starts a new one.'),
      findsOneWidget,
    );
    expect(switchValue(tester, 'Comma-separated translations'), isFalse);
    expect(switchValue(tester, 'Quick add mode'), isFalse);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('toggling an option stores it', (tester) async {
    await openOptions(tester);

    await tester.tap(find.text('Comma-separated translations'));
    await settle(tester);
    expect(switchValue(tester, 'Comma-separated translations'), isTrue);
    expect(store.getBool(SettingsRepository.commaTranslationsKey), isTrue);
    expect(settings.commaTranslations, isTrue);

    await tester.tap(find.text('Quick add mode'));
    await settle(tester);
    expect(switchValue(tester, 'Quick add mode'), isTrue);
    expect(store.getBool(SettingsRepository.quickAddModeKey), isTrue);

    await tester.tap(find.text('Comma-separated translations'));
    await settle(tester);
    expect(switchValue(tester, 'Comma-separated translations'), isFalse);
    expect(store.getBool(SettingsRepository.commaTranslationsKey), isFalse);
    await disposeAndClose(tester, repos.db);
  });

  testWidgets('shows the stored options', (tester) async {
    settings = SettingsRepository(
      InMemorySettingsStore({SettingsRepository.quickAddModeKey: true}),
    );
    await openOptions(tester);

    expect(switchValue(tester, 'Comma-separated translations'), isFalse);
    expect(switchValue(tester, 'Quick add mode'), isTrue);
    await disposeAndClose(tester, repos.db);
  });
}
