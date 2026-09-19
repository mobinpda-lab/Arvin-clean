import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/iran_clock.dart';

void main() {
  test('IranClock uses the fixed Iran UTC+03:30 offset', () {
    final now = DateTime.now().toUtc();
    final iran = IranClock.now();

    expect(iran.isUtc, isTrue);
    expect(iran.difference(now).inSeconds, inInclusiveRange(0, 1));
    expect(IranClock.utcOffset, const Duration(hours: 3, minutes: 30));
  });
}
