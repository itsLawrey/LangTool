import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/entry.dart';

/// Stores a `Map<String, String>` as a JSON object.
class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();

  @override
  Map<String, String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as Map<String, Object?>).cast<String, String>();

  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

/// Stores a `List<String>` as a JSON array.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<Object?>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Stores a `List<Example>` as a JSON array of objects.
class ExampleListConverter extends TypeConverter<List<Example>, String> {
  const ExampleListConverter();

  @override
  List<Example> fromSql(String fromDb) => [
    for (final json in jsonDecode(fromDb) as List<Object?>)
      Example.fromJson(json! as Map<String, Object?>),
  ];

  @override
  String toSql(List<Example> value) =>
      jsonEncode([for (final example in value) example.toJson()]);
}
