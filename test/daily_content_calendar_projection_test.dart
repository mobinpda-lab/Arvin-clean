import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/services/daily_content_calendar_projection.dart';
import 'package:arvin/services/daily_content_preferences_service.dart';

const _pack = DailyContentPack(
  schemaVersion: 1,
  contentVersion: 'v1',
  items: [
    DailyContentItem(
      id: 'q1',
      kind: DailyContentKind.quran,
      text: 'آیه',
      author: 'قرآن کریم',
      source: 'مرجع قرآن',
      reference: 'آیه ۱',
      verifiedBy: 'مرجع رسمی',
    ),
    DailyContentItem(
      id: 'h1',
      kind: DailyContentKind.shiaHadith,
      text: 'حدیث',
      author: 'امام صادق (ع)',
      source: 'الکافی',
      reference: 'ج ۱، ص ۱',
      verifiedBy: 'مرجع حدیث',
    ),
  ],
);

DailyContentPreferences _preferences({
  bool enabled = true,
  Set<DailyContentKind>? kinds,
}) => DailyContentPreferences(
      enabled: enabled,
      notificationEnabled: false,
      notificationHour: 8,
      notificationMinute: 0,
      enabledKinds: kinds ?? DailyContentKind.values.toSet(),
    );

void main() {
  const projection = DailyContentCalendarProjection();

  test('master switch hides Daily Content from calendar projection', () {
    expect(
      projection.forDate(
        date: DateTime(2026, 8, 27),
        pack: _pack,
        preferences: _preferences(enabled: false),
      ),
      isNull,
    );
  });

  test('enabled kinds restrict the selected pool', () {
    final item = projection.forDate(
      date: DateTime(2026, 8, 27),
      pack: _pack,
      preferences: _preferences(kinds: {DailyContentKind.shiaHadith}),
    );

    expect(item?.id, 'h1');
  });

  test('resolver stays deterministic for repeated calendar reads', () {
    final resolver = projection.resolver(
      pack: _pack,
      preferences: _preferences(),
    );
    final day = DateTime(2026, 8, 27);

    expect(resolver(day)?.id, resolver(day)?.id);
  });
}
