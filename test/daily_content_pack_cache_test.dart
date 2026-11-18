import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/daily_content_pack_cache.dart';

String _pack({String id = 'quran-2-153', String source = 'قرآن کریم'}) => '''
{
  "schemaVersion": 1,
  "contentVersion": "1405-06-a",
  "items": [
    {
      "id": "$id",
      "kind": "quran",
      "text": "متن آزمون",
      "author": "قرآن کریم",
      "source": "$source",
      "reference": "سوره بقره، آیه ۱۵۳",
      "verifiedBy": "مرجع رسمی"
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('valid pack replaces cache and can be loaded', () async {
    final cache = DailyContentPackCache();
    final saved = DateTime.utc(2026, 8, 27, 6, 0);

    expect(await cache.replaceIfValid(_pack(), savedAt: saved), isTrue);
    final pack = await cache.load();

    expect(pack.contentVersion, '1405-06-a');
    expect(pack.items.single.id, 'quran-2-153');
    expect(await cache.savedAt(), saved);
  });

  test('invalid replacement preserves previous good pack', () async {
    final cache = DailyContentPackCache();
    expect(await cache.replaceIfValid(_pack()), isTrue);

    final invalid = _pack(source: '');
    expect(await cache.replaceIfValid(invalid), isFalse);

    final pack = await cache.load();
    expect(pack.items.single.source, 'قرآن کریم');
  });

  test('duplicate ids fail closed', () async {
    final raw = '''
{
  "schemaVersion": 1,
  "contentVersion": "dup",
  "items": [
    {"id":"same","kind":"quran","text":"a","author":"a","source":"s","reference":"r","verifiedBy":"v"},
    {"id":"same","kind":"quran","text":"b","author":"a","source":"s","reference":"r","verifiedBy":"v"}
  ]
}
''';

    expect(await DailyContentPackCache().replaceIfValid(raw), isFalse);
  });

  test('oversized pack is rejected before persistence', () async {
    final oversized = 'x' * (DailyContentPackCache.maxPackBytes + 1);
    expect(utf8.encode(oversized).length, greaterThan(DailyContentPackCache.maxPackBytes));
    expect(await DailyContentPackCache().replaceIfValid(oversized), isFalse);
  });

  test('empty cache returns null through safe read', () async {
    expect(await DailyContentPackCache().loadOrNull(), isNull);
  });
}
