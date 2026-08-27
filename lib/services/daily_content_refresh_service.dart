import 'daily_content_pack_cache.dart';

abstract interface class DailyContentPackFetcher {
  Future<String?> fetchRawPack();
}

enum DailyContentRefreshResult {
  updated,
  keptCached,
  unavailable,
}

/// Refreshes Daily Content without trusting the transport.
///
/// The fetcher only transports text. Validation and the size ceiling remain the
/// cache's responsibility, so a future HTTP/provider adapter cannot bypass the
/// source-attribution/schema guardrails.
class DailyContentRefreshService {
  DailyContentRefreshService({
    required DailyContentPackFetcher fetcher,
    DailyContentPackCache? cache,
  })  : _fetcher = fetcher,
        _cache = cache ?? DailyContentPackCache();

  final DailyContentPackFetcher _fetcher;
  final DailyContentPackCache _cache;

  Future<DailyContentRefreshResult> refresh() async {
    String? raw;
    try {
      raw = await _fetcher.fetchRawPack();
    } catch (_) {
      return await _hasCachedPack()
          ? DailyContentRefreshResult.keptCached
          : DailyContentRefreshResult.unavailable;
    }

    if (raw == null || raw.trim().isEmpty) {
      return await _hasCachedPack()
          ? DailyContentRefreshResult.keptCached
          : DailyContentRefreshResult.unavailable;
    }

    final accepted = await _cache.replaceIfValid(raw);
    if (accepted) return DailyContentRefreshResult.updated;
    return await _hasCachedPack()
        ? DailyContentRefreshResult.keptCached
        : DailyContentRefreshResult.unavailable;
  }

  Future<bool> _hasCachedPack() async => (await _cache.loadOrNull()) != null;
}
