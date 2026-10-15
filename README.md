# LangTool

A dictionary app for learning languages. Entries are organised into language packs under a user profile and backed up to the cloud so they can be restored on another device. German is the first supported language.

## Stack

- **App:** Flutter (Dart)
- **Backend:** Supabase (Auth, Postgres)

## Requirements

- Flutter SDK (stable channel)
- A Supabase project

## Getting started

```sh
flutter pub get
flutter run
```

## Development

```sh
flutter analyze             # static analysis
flutter test                # all tests
flutter test test/<file>    # single test file
dart format .               # format
```
