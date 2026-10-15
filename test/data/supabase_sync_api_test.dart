import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:langtool/data/services/remote_sync_api.dart';
import 'package:langtool/data/services/supabase_sync_api.dart';
import 'package:langtool/domain/models/entry.dart';
import 'package:langtool/domain/models/language_pack.dart';
import 'package:langtool/domain/models/word_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Contract tests: the exact PostgREST requests the adapter sends, and how
/// it parses responses shaped like the real `language_packs` / `entries`
/// tables (see supabase/migrations/).
void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) respond;
  late SupabaseClient client;
  late SupabaseSyncApi api;

  setUp(() {
    requests = [];
    respond = (_) => http.Response('[]', 200);
    client = SupabaseClient(
      'https://test.supabase.co',
      'publishable-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        final response = respond(request);
        // The client reads the request back from the response.
        return http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: request,
        );
      }),
    );
    api = SupabaseSyncApi(client);
  });

  tearDown(() => client.dispose());

  final created = DateTime.utc(2026, 10, 15, 12);
  final updated = DateTime.utc(2026, 10, 15, 13, 0, 0, 123, 456);

  final entry = Entry(
    id: '0199f0e2-0000-7000-8000-000000000001',
    ownerId: 'user-1',
    packId: '0199f0e2-0000-7000-8000-0000000000aa',
    wordType: WordType.noun,
    term: 'Haus',
    forms: {'article': 'das', 'plural': 'Häuser'},
    translations: ['house', 'ház'],
    examples: [const Example(text: 'Das Haus ist groß.', translation: 'Big.')],
    tags: ['A1'],
    notes: 'note',
    schemaVersion: 1,
    createdAt: created,
    updatedAt: updated,
  );

  group('upsert', () {
    test('posts entries as snake_case rows, merging on id', () async {
      await api.upsertEntries([entry]);

      final [request] = requests;
      expect(request.method, 'POST');
      expect(request.url.path, '/rest/v1/entries');
      expect(request.url.queryParameters['on_conflict'], 'id');
      expect(
        request.headers['Prefer'],
        contains('resolution=merge-duplicates'),
      );
      expect(jsonDecode(request.body), [
        {
          'id': '0199f0e2-0000-7000-8000-000000000001',
          'owner_id': 'user-1',
          'pack_id': '0199f0e2-0000-7000-8000-0000000000aa',
          'word_type': 'noun',
          'term': 'Haus',
          'forms': {'article': 'das', 'plural': 'Häuser'},
          'translations': ['house', 'ház'],
          'examples': [
            {'text': 'Das Haus ist groß.', 'translation': 'Big.'},
          ],
          'tags': ['A1'],
          'notes': 'note',
          'schema_version': 1,
          'created_at': '2026-10-15T12:00:00.000Z',
          'updated_at': '2026-10-15T13:00:00.123456Z',
          'deleted_at': null,
        },
      ]);
    });

    test('posts packs to language_packs', () async {
      await api.upsertPacks([
        LanguagePack(
          id: 'pack-1',
          ownerId: 'user-1',
          name: 'Deutsch',
          languageCode: 'de',
          createdAt: created,
          updatedAt: created,
          deletedAt: updated,
        ),
      ]);

      final [request] = requests;
      expect(request.url.path, '/rest/v1/language_packs');
      final [row] = jsonDecode(request.body) as List<Object?>;
      expect(row, {
        'id': 'pack-1',
        'owner_id': 'user-1',
        'name': 'Deutsch',
        'language_code': 'de',
        'created_at': '2026-10-15T12:00:00.000Z',
        'updated_at': '2026-10-15T12:00:00.000Z',
        'deleted_at': '2026-10-15T13:00:00.123456Z',
      });
    });

    test('sends nothing for an empty batch', () async {
      await api.upsertEntries(const []);
      await api.upsertPacks(const []);

      expect(requests, isEmpty);
    });
  });

  group('fetch', () {
    Map<String, String> paramsOf(http.Request request) =>
        request.url.queryParameters;

    test(
      'without a cursor requests every row of the owner, in feed order',
      () async {
        await api.fetchEntries(ownerId: 'user-1', from: null, limit: 500);

        final [request] = requests;
        expect(request.method, 'GET');
        expect(request.url.path, '/rest/v1/entries');
        expect(paramsOf(request), {
          'select': '*',
          'owner_id': 'eq.user-1',
          'order': 'server_updated_at.asc.nullslast,id.asc.nullslast',
          'limit': '500',
        });
      },
    );

    test('from a time requests rows written at or after it', () async {
      await api.fetchPacks(
        ownerId: 'user-1',
        from: ChangeCursor(updated),
        limit: 10,
      );

      final params = paramsOf(requests.single);
      expect(requests.single.url.path, '/rest/v1/language_packs');
      expect(params['server_updated_at'], 'gte.2026-10-15T13:00:00.123456Z');
      expect(params.containsKey('or'), isFalse);
    });

    test('after a row continues strictly after (time, id)', () async {
      await api.fetchEntries(
        ownerId: 'user-1',
        from: ChangeCursor(updated, 'abc'),
        limit: 10,
      );

      final params = paramsOf(requests.single);
      expect(
        params['or'],
        '(server_updated_at.gt."2026-10-15T13:00:00.123456Z",'
        'and(server_updated_at.eq."2026-10-15T13:00:00.123456Z",id.gt.abc))',
      );
      expect(params.containsKey('server_updated_at'), isFalse);
    });

    test('parses rows as Postgres returns them', () async {
      respond = (_) => http.Response(
        jsonEncode([
          {
            'id': '0199f0e2-0000-7000-8000-000000000001',
            'owner_id': 'user-1',
            'pack_id': '0199f0e2-0000-7000-8000-0000000000aa',
            'word_type': 'noun',
            'term': 'Haus',
            'forms': {'article': 'das', 'plural': 'Häuser'},
            'translations': ['house', 'ház'],
            'examples': [
              {'text': 'Das Haus ist groß.', 'translation': 'Big.'},
            ],
            'tags': ['A1'],
            'notes': 'note',
            'schema_version': 1,
            'created_at': '2026-10-15T12:00:00+00:00',
            'updated_at': '2026-10-15T13:00:00.123456+00:00',
            'deleted_at': null,
            'server_updated_at': '2026-10-15T15:48:44.810123+00:00',
          },
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

      final [record] = await api.fetchEntries(
        ownerId: 'user-1',
        from: null,
        limit: 500,
      );

      expect(record.value, entry);
      expect(record.value.updatedAt.isUtc, isTrue);
      expect(
        record.serverUpdatedAt,
        DateTime.utc(2026, 10, 15, 15, 48, 44, 810, 123),
      );
    });

    test('surfaces database errors as PostgrestException', () async {
      respond = (_) => http.Response(
        jsonEncode({
          'code': '42501',
          'message': 'permission denied for table entries',
          'details': null,
          'hint': null,
        }),
        401,
        headers: {'content-type': 'application/json'},
      );

      await expectLater(
        api.fetchEntries(ownerId: 'user-1', from: null, limit: 500),
        throwsA(
          isA<PostgrestException>()
              .having((e) => e.code, 'code', '42501')
              .having((e) => e.message, 'message', contains('permission')),
        ),
      );
    });
  });
}
