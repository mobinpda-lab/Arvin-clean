import '../models/task.dart';

/// Converts one short line of text into the existing canonical [Task] model.
///
/// Tokens starting with `#` become tags. The remaining text becomes the title.
/// This service owns no persistence or UI state and can be reused by a future
/// quick-add surface without introducing a second task model.
class QuickCaptureService {
  const QuickCaptureService();

  Task? capture(
    String raw, {
    required String id,
    required DateTime createdAt,
  }) {
    final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return null;

    final tags = <String>[];
    final titleParts = <String>[];

    for (final token in normalized.split(' ')) {
      if (token.startsWith('#') && token.length > 1) {
        final tag = token.substring(1).trim();
        if (tag.isNotEmpty && !tags.contains(tag)) {
          tags.add(tag);
        }
      } else {
        titleParts.add(token);
      }
    }

    final title = titleParts.join(' ').trim();

    return Task(
      id: id,
      title: title.isEmpty ? 'بدون عنوان' : title,
      tags: tags,
      createdAt: createdAt,
    );
  }
}
