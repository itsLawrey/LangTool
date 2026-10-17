import '../../../../domain/recap/recap_session.dart';

/// Parses the `direction` query parameter of a recap session route (a
/// [RecapDirection] name). Missing or unknown values mean
/// [RecapDirection.foreignFirst].
RecapDirection recapDirectionFromParam(String? value) =>
    RecapDirection.values.asNameMap()[value] ?? RecapDirection.foreignFirst;
