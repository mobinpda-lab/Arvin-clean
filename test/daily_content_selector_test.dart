import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/services/daily_content_selector.dart';

DailyContentItem _item(
  String id, {
  DailyContentKind kind = DailyContentKind.quran,
  String? verifiedBy,
}) {
  return DailyContentItem(
    id: id,
    kind: kind,
    text: 'متن $id',
    author: 'منبع $id',
    source: 'کتاب $id',
    reference: 'ارجاع $id',
    verifiedBy: verifiedBy ?? 'مرجع معتبر',
  );
}

void main() {
  const selector = DailyContentSelector();

  test('same date and pack always select the same item', () {
    final pack = DailyContentPack(
      schemaVersion: 1,
      contentVersion: '1405-06-v1',
      items: [_item('a'), _item('b'), _item('c')],
    );
    final date = DateTime(2026, 8, 27, 18, 42);

    final first = selector.selectForDate(date: date, pack: pack);
    final second = selector.selectForDate(date: date, pack: pack);

    expect(first, isNotNull);
    expect(second?.id, first?.id);
  });

  test('consecutive days do not repeat before eligible pool is exhausted', () {
    final pack = DailyContentPack(
      schemaVersion: 1,
      contentVersion: '1405-06-v1',
      items: [_item('a'), _item('b'), _item('c'), _item('d')],
    );
    final start = DateTime(2026, 8, 27);

    final ids = <String>{};
    for (var offset = 0; offset < 4; offset++) {
      final item = selector.selectForDate(
        date: start.add(Duration(days: offset)),
        pack: pack,
      );
      expect(item, isNotNull);
      ids.add(item!.id);
    }

    expect(ids, hasLength(4));
  });

  test('enabled kinds constrain the eligible pool', () {
    final pack = DailyContentPack(
      schemaVersion: 1,
      contentVersion: '1405-06-v1',
      items: [
        _item('quran', kind: DailyContentKind.quran),
        _item('nahj', kind: DailyContentKind.nahjAlBalagha),
      ],
    );

    final item = selector.selectForDate(
      date: DateTime(2026, 8, 27),
      pack: pack,
      enabledKinds: {DailyContentKind.nahjAlBalagha},
    );

    expect(item?.id, 'nahj');
  });

  test('unverifiable content is never selected', () {
    final pack = DailyContentPack(
      schemaVersion: 1,
      contentVersion: '1405-06-v1',
      items: [_item('bad', verifiedBy: '   ')],
    );

    final item = selector.selectForDate(
      date: DateTime(2026, 8, 27),
      pack: pack,
    );

    expect(item, isNull);
  });

  test('unsupported or unversioned packs fail closed', () {
    final unsupported = DailyContentPack(
      schemaVersion: 2,
      contentVersion: 'next',
      items: [_item('a')],
    );
    final unversioned = DailyContentPack(
      schemaVersion: 1,
      contentVersion: ' ',
      items: [_item('a')],
    );

    expect(
      selector.selectForDate(date: DateTime(2026, 8, 27), pack: unsupported),
      isNull,
    );
    expect(
      selector.selectForDate(date: DateTime(2026, 8, 27), pack: unversioned),
      isNull,
    );
  });

  test('approved product taxonomy contains exactly the six content lanes', () {
    expect(
      DailyContentKind.values,
      containsAll(<DailyContentKind>[
        DailyContentKind.quran,
        DailyContentKind.nahjAlBalagha,
        DailyContentKind.shiaHadith,
        DailyContentKind.sahifaSajjadiya,
        DailyContentKind.iranianQuote,
        DailyContentKind.worldQuote,
      ]),
    );
    expect(DailyContentKind.values, hasLength(6));
  });
}
