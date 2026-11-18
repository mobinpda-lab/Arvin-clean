import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../daily_content.dart';
import 'daily_content_pack_codec.dart';

/// Keeps only the latest small, fully publishable Daily Content pack.
///
/// The cache is deliberately bounded so SharedPreferences never turns into a
/// hidden book/database store. Invalid replacements leave the previous good
/// pack untouched.
class DailyContentPackCache implements DailyContentSource {
  DailyContentPackCache({
    DailyContentPackCodec codec = const DailyContentPackCodec(),
  }) : _codec = codec;

  static const rawPackKey = 'arvin.dailyContent.cachedPack.v1';
  static const savedAtKey = 'arvin.dailyContent.cachedPack.savedAt';
  static const maxPackBytes = 256 * 1024;

  final DailyContentPackCodec _codec;

  @override
  Future<DailyContentPack> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(rawPackKey);
    if (raw == null || raw.trim().isEmpty) {
      throw StateError('No valid Daily Content pack is cached');
    }
    try {
      final pack = _codec.decode(raw);
      if (!_isValidForCache(pack)) {
        throw const FormatException('Cached Daily Content pack is not publishable');
      }
      return pack;
    } on FormatException {
      throw StateError('No valid Daily Content pack is cached');
    }
  }

  Future<DailyContentPack?> loadOrNull() async {
    try {
      return await load();
    } on StateError {
      return null;
    }
  }

  Future<bool> replaceIfValid(String rawJson, {DateTime? savedAt}) async {
    if (utf8.encode(rawJson).length > maxPackBytes) return false;

    late final DailyContentPack pack;
    try {
      pack = _codec.decode(rawJson);
    } on FormatException {
      return false;
    }
    if (!_isValidForCache(pack)) return false;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(rawPackKey, rawJson);
    await preferences.setString(
      savedAtKey,
      (savedAt ?? DateTime.now()).toUtc().toIso8601String(),
    );
    return true;
  }

  Future<DateTime?> savedAt() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(savedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  bool _isValidForCache(DailyContentPack pack) {
    if (pack.items.isEmpty || pack.items.any((item) => !item.isPublishable)) {
      return false;
    }
    final ids = <String>{};
    for (final item in pack.items) {
      if (!ids.add(item.id.trim())) return false;
    }
    return true;
  }
}
