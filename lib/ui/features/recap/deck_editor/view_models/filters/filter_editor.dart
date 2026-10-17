import 'package:flutter/foundation.dart';

import '../../../../../../domain/recap/deck_filter.dart';

/// The editable state of one kind of deck filter in the deck editor. Each
/// kind has a matching section widget in `views/filters/`.
///
/// To add a filter kind, add an editor here, its section widget, and
/// register both in `DeckEditorViewModel` and `DeckEditorForm`.
abstract class FilterEditor extends ChangeNotifier {
  /// The filter for the current input, or `null` if it selects every entry.
  DeckFilter? get filter;

  /// Whether the current input can be saved.
  bool get isValid => true;

  /// Takes [filter] from the edited deck if this editor handles it. Returns
  /// `false` for filters of other kinds, or if one was already taken.
  bool load(DeckFilter filter);
}
