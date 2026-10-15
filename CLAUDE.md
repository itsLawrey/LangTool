# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

LangTool: a Flutter app with a Supabase backend for building vocabulary dictionaries. A signed-in user owns language packs, and a pack contains searchable entries. The cloud only backs up and syncs the user's data across devices. German is the only language for now, but the data model must allow other languages with different grammar to be added later.

Development proceeds in stages defined by the user. Implement only the current stage's spec. Don't add features, UI copy or flavour text that wasn't specified.

## Commands

```sh
flutter pub get
flutter analyze
flutter test                          # all tests
flutter test test/widget_test.dart    # single file
flutter test --name "<test name>"     # single test by name
dart format .
```

## Supabase

- Project: `langtool`, ref `gdduanyobtuqplhknxss`, region `eu-west-1`.
- The Supabase MCP server (`.mcp.json`) has access to the whole organization. Only operate on `langtool`.
- Never commit keys. Local config goes in `env/*.json` (gitignored), passed with `--dart-define-from-file`.

## Hot reload

After editing `.dart` files under `lib/` (not comment-only changes), discover the running app with the Dart MCP `dtd` tool. Then call `hot_reload` for UI or simple method changes, or `hot_restart` for changes to `main()`, `initState`, or global/static state. Skip this for files outside `lib/`.
