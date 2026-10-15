import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/ui/core/date_labels.dart';

void main() {
  final now = DateTime(2026, 10, 15, 9);

  test('labels today and yesterday', () {
    expect(dayLabel(DateTime(2026, 10, 15), now: now), 'Today');
    expect(dayLabel(DateTime(2026, 10, 14), now: now), 'Yesterday');
  });

  test('labels older days with the full date', () {
    expect(
      dayLabel(DateTime(2026, 10, 1), now: now),
      'Thursday, October 1, 2026',
    );
  });
}
