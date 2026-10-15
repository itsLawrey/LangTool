import '../../domain/languages/language_schema.dart';
import '../../domain/models/entry.dart';

/// The term as it is usually written, with its article if it has one
/// (e.g. `das Haus`).
String headword(Entry entry) => switch (entry.forms['article']) {
  final article? => '$article ${entry.term}',
  null => entry.term,
};

/// The entry's forms other than the article, in schema order.
List<(String key, String value)> displayForms(
  Entry entry,
  LanguageSchema? schema,
) {
  final keys = [
    ...?schema?.wordTypes[entry.wordType]?.fields.map((f) => f.key),
    ...entry.forms.keys,
  ];
  final seen = <String>{};
  return [
    for (final key in keys)
      if (key != 'article' && seen.add(key))
        if (entry.forms[key] case final value?) (key, value),
  ];
}
