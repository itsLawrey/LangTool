# LangTool

[![Deploy to Firebase Hosting on merge](https://github.com/itsLawrey/LangTool/actions/workflows/firebase-hosting-merge.yml/badge.svg)](https://github.com/itsLawrey/LangTool/actions/workflows/firebase-hosting-merge.yml)

A dictionary app for learning languages. Entries are organised into language packs under a user profile, are searchable with typo tolerance, and sync across devices. German is the first supported language.

**Live demo:** https://itslawrey-langtool.web.app

## Stack

- **App:** Flutter (Dart), MVVM with `provider` and `go_router`
- **Local storage:** Drift (SQLite, also on the web via WebAssembly)
- **Backend:** Supabase (Auth, Postgres with row-level security)
- **Hosting:** Firebase Hosting, deployed by GitHub Actions

## Requirements

- Flutter SDK (stable channel)
- A Supabase project with the migrations in `supabase/migrations/`

## Getting started

```sh
cp env/dev.example.json env/dev.json   # fill in your Supabase URL and publishable key
flutter pub get
flutter run --dart-define-from-file=env/dev.json
```

## Development

```sh
flutter analyze                          # static analysis
flutter test                             # unit and widget tests
flutter test test/<file>                 # single test file
flutter test integration_test -d linux   # end-to-end flows
dart format .                            # format
```

## Deployment

Pull requests run analysis and tests, then deploy a preview channel and comment its URL on the PR. Merging to `main` deploys the live site.
