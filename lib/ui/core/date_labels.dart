import 'package:intl/intl.dart';

/// Label for a local calendar [day] relative to [now]: `Today`, `Yesterday`,
/// or the full date.
String dayLabel(DateTime day, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(day.year, day.month, day.day);
  final difference = today.difference(date).inDays;
  return switch (difference) {
    0 => 'Today',
    1 => 'Yesterday',
    _ => DateFormat.yMMMMEEEEd().format(date),
  };
}

/// Local date and time, e.g. `15 Oct 2026, 14:05`.
String dateTimeLabel(DateTime time) =>
    DateFormat('d MMM y, HH:mm').format(time.toLocal());
