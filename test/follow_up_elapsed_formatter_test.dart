import 'package:arvin/services/follow_up_elapsed_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = FollowUpElapsedFormatter();

  test('formats short and mixed elapsed durations with Persian digits', () {
    expect(formatter.format(const Duration(minutes: 15)), '۱۵ دقیقه');
    expect(
      formatter.format(const Duration(hours: 2, minutes: 15)),
      '۲ ساعت و ۱۵ دقیقه',
    );
    expect(
      formatter.format(const Duration(days: 3, hours: 4)),
      '۳ روز و ۴ ساعت',
    );
  });

  test('formats week and month scale durations compactly', () {
    expect(formatter.format(const Duration(days: 14)), '۲ هفته');
    expect(formatter.format(const Duration(days: 35)), '۱ ماه و ۵ روز');
  });

  test('since is derived from supplied clock and never persisted', () {
    expect(
      formatter.since(
        DateTime(2026, 8, 25, 10),
        now: DateTime(2026, 8, 28, 14),
      ),
      '۳ روز و ۴ ساعت از آخرین پیگیری گذشته',
    );
  });

  test('future timestamp is not rendered as negative elapsed time', () {
    expect(
      formatter.since(
        DateTime(2026, 8, 29, 10),
        now: DateTime(2026, 8, 28, 10),
      ),
      'زمان پیگیری در آینده است',
    );
  });
}
