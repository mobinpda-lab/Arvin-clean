import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/daily_content_pack_cache.dart';
import 'package:arvin/services/daily_content_refresh_service.dart';

const _validPack = '''
{
  "schemaVersion": 1,
  "contentVersion": "v1",
  "items": [
    {
      "id": "q1",
      "kind": "quran",
      "text": "متن",
      "author": "قرآن کریم",
      "source": "مرجع قرآن",
      "reference": "آیه ۱",
      "verifiedBy": "مرجع رسمی"
    }
  ]
}
''';

class _Fetcher implements DailyContentPackFetcher {
  _Fetcher(this.value, {this.error = false});
  final String? value;
  final bool error;

  @override
  Future<String?> fetchRawPack() async {
    if (error) throw StateError('offline');
    return value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('valid fetched pack updates cache', () async {
    final result = await DailyContentRefreshService(
      fetcher: _Fetcher(_validPack),
    ).refresh();

    expect(result, DailyContentRefreshResult.updated);
    expect((await DailyContentPackCache().load()).contentVersion, 'v1');
  });

  test('invalid remote content keeps previous verified cache', () async {
    final cache = DailyContentPackCache();
    await cache.replaceIfValid(_validPack);

    final result = await DailyContentRefreshService(
      fetcher: _Fetcher('{"schemaVersion":999}'),
      cache: cache,
    ).refresh();

    expect(result, DailyContentRefreshResult.keptCached);
    expect((await cache.load()).contentVersion, 'v1');
  });

  test('offline without cache is unavailable', () async {
    final result = await DailyContentRefreshService(
      fetcher: _Fetcher(null, error: true),
    ).refresh();

    expect(result, DailyContentRefreshResult.unavailable);
  });
}
