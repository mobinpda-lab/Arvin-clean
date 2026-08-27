import 'dart:convert';

import '../daily_content.dart';

/// Strict JSON codec for compact Daily Content packs.
///
/// Structural errors fail closed. Content-level attribution gaps remain visible
/// to [DailyContentItem.isPublishable] and are filtered before selection.
class DailyContentPackCodec {
  const DailyContentPackCodec();

  DailyContentPack decode(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Daily Content pack root must be an object');
    }

    final schemaVersion = decoded['schemaVersion'];
    final contentVersion = decoded['contentVersion'];
    final rawItems = decoded['items'];

    if (schemaVersion is! int || schemaVersion != 1) {
      throw const FormatException('Unsupported Daily Content schema version');
    }
    if (contentVersion is! String || contentVersion.trim().isEmpty) {
      throw const FormatException('Daily Content pack version is missing');
    }
    if (rawItems is! List) {
      throw const FormatException('Daily Content items must be an array');
    }

    final items = <DailyContentItem>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map<String, dynamic>) {
        throw const FormatException('Daily Content item must be an object');
      }
      items.add(_decodeItem(rawItem));
    }

    return DailyContentPack(
      schemaVersion: schemaVersion,
      contentVersion: contentVersion.trim(),
      items: List.unmodifiable(items),
    );
  }

  DailyContentItem _decodeItem(Map<String, dynamic> json) {
    return DailyContentItem(
      id: _requiredString(json, 'id'),
      kind: _decodeKind(_requiredString(json, 'kind')),
      text: _requiredString(json, 'text'),
      author: _requiredString(json, 'author'),
      source: _requiredString(json, 'source'),
      reference: _requiredString(json, 'reference'),
      verifiedBy: _requiredString(json, 'verifiedBy'),
      originalText: _optionalString(json, 'originalText'),
      sourceUrl: _optionalString(json, 'sourceUrl'),
    );
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Daily Content field "$key" must be a string');
    }
    return value;
  }

  String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Daily Content field "$key" must be a string');
    }
    return value;
  }

  DailyContentKind _decodeKind(String raw) {
    return switch (raw) {
      'quran' => DailyContentKind.quran,
      'nahjAlBalagha' => DailyContentKind.nahjAlBalagha,
      'shiaHadith' => DailyContentKind.shiaHadith,
      'sahifaSajjadiya' => DailyContentKind.sahifaSajjadiya,
      'iranianQuote' => DailyContentKind.iranianQuote,
      'worldQuote' => DailyContentKind.worldQuote,
      _ => throw FormatException('Unsupported Daily Content kind: $raw'),
    };
  }
}
