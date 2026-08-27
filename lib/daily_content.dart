enum DailyContentKind {
  quran,
  nahjAlBalagha,
  shiaHadith,
  sahifaSajjadiya,
  iranianQuote,
  worldQuote,
}

/// One small, source-attributed item that can be surfaced as «پیام روز».
///
/// Daily Content is intentionally independent from Task/FollowUp and from the
/// official-calendar reminder model. It is content projected onto a date, not
/// a user-owned task and not an official civic/religious calendar event.
class DailyContentItem {
  const DailyContentItem({
    required this.id,
    required this.kind,
    required this.text,
    required this.author,
    required this.source,
    required this.reference,
    required this.verifiedBy,
    this.originalText,
    this.sourceUrl,
  });

  final String id;
  final DailyContentKind kind;
  final String text;
  final String author;
  final String source;
  final String reference;
  final String verifiedBy;
  final String? originalText;
  final String? sourceUrl;

  /// Content is publishable only when the user can trace it back to a source.
  /// This prevents random, unattributed internet quotes from entering the lane.
  bool get isPublishable =>
      id.trim().isNotEmpty &&
      text.trim().isNotEmpty &&
      author.trim().isNotEmpty &&
      source.trim().isNotEmpty &&
      reference.trim().isNotEmpty &&
      verifiedBy.trim().isNotEmpty;
}

/// A compact, versioned content payload suitable for download and local cache.
///
/// The app should cache packs instead of bundling full books or large hadith
/// databases into the APK.
class DailyContentPack {
  const DailyContentPack({
    required this.schemaVersion,
    required this.contentVersion,
    required this.items,
  });

  final int schemaVersion;
  final String contentVersion;
  final List<DailyContentItem> items;

  List<DailyContentItem> get publishableItems =>
      items.where((item) => item.isPublishable).toList(growable: false);
}

/// Source boundary for future online or bundled compact packs.
///
/// Implementations may use network + cache, a small bundled emergency pack,
/// or another audited transport. They must not introduce a second calendar or
/// task storage system.
abstract interface class DailyContentSource {
  Future<DailyContentPack> load();
}
