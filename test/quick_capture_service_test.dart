import 'package:arvin/services/quick_capture_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = QuickCaptureService();
  final createdAt = DateTime(2026, 8, 26, 8, 30);

  test('captures Persian title and hashtags into canonical Task fields', () {
    final task = service.capture(
      'تماس با علی #فروش #مهم',
      id: 'capture-1',
      createdAt: createdAt,
    );

    expect(task, isNotNull);
    expect(task!.id, 'capture-1');
    expect(task.title, 'تماس با علی');
    expect(task.tags, ['فروش', 'مهم']);
    expect(task.createdAt, createdAt);
    expect(task.archived, isFalse);
    expect(task.trashed, isFalse);
    expect(task.completed, isFalse);
  });

  test('normalizes whitespace and keeps tag order while removing duplicates', () {
    final task = service.capture(
      '  پیگیری   قرارداد   #فروش   #فروش   #فوری  ',
      id: 'capture-2',
      createdAt: createdAt,
    )!;

    expect(task.title, 'پیگیری قرارداد');
    expect(task.tags, ['فروش', 'فوری']);
  });

  test('returns null for empty input', () {
    expect(
      service.capture('   ', id: 'empty', createdAt: createdAt),
      isNull,
    );
  });

  test('uses existing no-title fallback for tag-only capture', () {
    final task = service.capture(
      '#فروش #مهم',
      id: 'tags-only',
      createdAt: createdAt,
    )!;

    expect(task.title, 'بدون عنوان');
    expect(task.tags, ['فروش', 'مهم']);
  });

  test('does not treat an embedded hash as a standalone tag', () {
    final task = service.capture(
      'نسخه C# برای مشتری',
      id: 'embedded',
      createdAt: createdAt,
    )!;

    expect(task.title, 'نسخه C# برای مشتری');
    expect(task.tags, isEmpty);
  });
}
