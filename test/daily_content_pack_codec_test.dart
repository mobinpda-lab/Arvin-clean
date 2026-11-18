import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/services/daily_content_pack_codec.dart';

void main() {
  const codec = DailyContentPackCodec();

  test('decodes a compact verified pack', () {
    final pack = codec.decode('''
{
  "schemaVersion": 1,
  "contentVersion": "1405-06-v1",
  "items": [
    {
      "id": "nahj-123",
      "kind": "nahjAlBalagha",
      "text": "متن فارسی",
      "originalText": "النص العربي",
      "author": "امام علی (ع)",
      "source": "نهج‌البلاغه",
      "reference": "حکمت ۱۲۳",
      "verifiedBy": "مرجع معتبر"
    }
  ]
}
''');

    expect(pack.schemaVersion, 1);
    expect(pack.contentVersion, '1405-06-v1');
    expect(pack.items, hasLength(1));
    expect(pack.items.single.kind, DailyContentKind.nahjAlBalagha);
    expect(pack.items.single.isPublishable, isTrue);
  });

  test('rejects unsupported schema and unknown content kind', () {
    expect(
      () => codec.decode('{"schemaVersion":2,"contentVersion":"x","items":[]}'),
      throwsFormatException,
    );
    expect(
      () => codec.decode('''
{
  "schemaVersion": 1,
  "contentVersion": "x",
  "items": [
    {
      "id": "x",
      "kind": "randomInternetQuote",
      "text": "x",
      "author": "x",
      "source": "x",
      "reference": "x",
      "verifiedBy": "x"
    }
  ]
}
'''),
      throwsFormatException,
    );
  });

  test('structural type errors fail closed', () {
    expect(
      () => codec.decode('{"schemaVersion":1,"contentVersion":"x","items":{}}'),
      throwsFormatException,
    );
    expect(
      () => codec.decode('''
{
  "schemaVersion": 1,
  "contentVersion": "x",
  "items": [
    {
      "id": 10,
      "kind": "quran",
      "text": "x",
      "author": "x",
      "source": "x",
      "reference": "x",
      "verifiedBy": "x"
    }
  ]
}
'''),
      throwsFormatException,
    );
  });

  test('attribution gaps decode but stay unpublishable', () {
    final pack = codec.decode('''
{
  "schemaVersion": 1,
  "contentVersion": "x",
  "items": [
    {
      "id": "quran-x",
      "kind": "quran",
      "text": "متن",
      "author": "قرآن کریم",
      "source": "",
      "reference": "",
      "verifiedBy": ""
    }
  ]
}
''');

    expect(pack.items.single.isPublishable, isFalse);
    expect(pack.publishableItems, isEmpty);
  });
}
