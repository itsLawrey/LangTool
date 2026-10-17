import '../../../../../../domain/recap/deck_filter.dart';
import '../../../../../../utils/clock.dart';
import 'filter_editor.dart';

/// How the Added filter restricts entries by the day they were added.
enum AddedMode {
  /// No restriction.
  anyTime,

  /// Between two dates; either may be open.
  between,

  /// During the last [AddedFilterEditor.lastDays] days.
  lastDays,
}

/// Date ranges that fill both dates of [AddedMode.between], ending today.
enum AddedPreset {
  today(1),
  last7Days(7),
  last30Days(30);

  const AddedPreset(this.days);

  final int days;
}

/// Edits the filter on when entries were added.
class AddedFilterEditor extends FilterEditor {
  /// `now` gives today's date for the presets.
  AddedFilterEditor({this._now = DateTime.now});

  final Clock _now;
  bool _loaded = false;

  AddedMode _mode = AddedMode.anyTime;
  DateTime? _from;
  DateTime? _to;
  int? _lastDays = 7;

  AddedMode get mode => _mode;

  /// First day of the range, or `null` if open.
  DateTime? get from => _from;

  /// Last day of the range, or `null` if open.
  DateTime? get to => _to;

  /// The number of days for [AddedMode.lastDays], or `null` if the input is
  /// not a number.
  int? get lastDays => _lastDays;

  /// Today's local date.
  DateTime get today => _day(_now().toLocal());

  @override
  bool get isValid => _mode != AddedMode.lastDays || (_lastDays ?? 0) >= 1;

  @override
  DeckFilter? get filter => switch (_mode) {
    AddedMode.anyTime => null,
    AddedMode.between when _from == null && _to == null => null,
    AddedMode.between => DeckFilter.addedBetween(from: _from, to: _to),
    AddedMode.lastDays =>
      isValid ? DeckFilter.addedInLastDays(_lastDays!) : null,
  };

  void setMode(AddedMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setFrom(DateTime? day) {
    _from = day == null ? null : _day(day);
    notifyListeners();
  }

  void setTo(DateTime? day) {
    _to = day == null ? null : _day(day);
    notifyListeners();
  }

  void setLastDays(int? days) {
    _lastDays = days;
    notifyListeners();
  }

  void applyPreset(AddedPreset preset) {
    final today = this.today;
    _mode = AddedMode.between;
    _from = DateTime(today.year, today.month, today.day - (preset.days - 1));
    _to = today;
    notifyListeners();
  }

  /// Filters that match nothing (no days) are left to be kept unchanged.
  @override
  bool load(DeckFilter filter) {
    if (_loaded) return false;
    switch (filter) {
      case AddedBetween(:final from, :final to):
        _mode = AddedMode.between;
        _from = from == null ? null : _day(from);
        _to = to == null ? null : _day(to);
      case AddedInLastDays(:final days) when days >= 1:
        _mode = AddedMode.lastDays;
        _lastDays = days;
      default:
        return false;
    }
    _loaded = true;
    return true;
  }

  static DateTime _day(DateTime time) =>
      DateTime(time.year, time.month, time.day);
}
