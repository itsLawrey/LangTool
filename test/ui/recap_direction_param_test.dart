import 'package:flutter_test/flutter_test.dart';
import 'package:langtool/domain/recap/recap_session.dart';
import 'package:langtool/ui/features/recap_session/view_models/recap_direction_param.dart';

void main() {
  test('parses every direction name', () {
    for (final direction in RecapDirection.values) {
      expect(recapDirectionFromParam(direction.name), direction);
    }
  });

  test('defaults to foreign first when missing or invalid', () {
    expect(recapDirectionFromParam(null), RecapDirection.foreignFirst);
    expect(recapDirectionFromParam(''), RecapDirection.foreignFirst);
    expect(recapDirectionFromParam('sideways'), RecapDirection.foreignFirst);
    expect(recapDirectionFromParam('Mixed'), RecapDirection.foreignFirst);
  });
}
