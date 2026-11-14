import 'package:arvin/models/goal_project.dart';
import 'package:arvin/services/project_plan_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = ProjectPlanCodec();

  test('round-trips canonical ProjectPlan fields losslessly', () {
    final project = ProjectPlan(
      id: 'project-1',
      title: 'کاری',
      colorValue: 0xFF2F80ED,
      isArchived: true,
      itemIds: const ['task-1', 'task-2'],
    );

    final encoded = codec.encode(project);
    final decoded = codec.decode(encoded);

    expect(
      encoded.keys.toSet(),
      {'id', 'title', 'colorValue', 'isArchived', 'itemIds'},
    );
    expect(decoded.id, project.id);
    expect(decoded.title, project.title);
    expect(decoded.colorValue, project.colorValue);
    expect(decoded.isArchived, isTrue);
    expect(decoded.itemIds, project.itemIds);
  });

  test('new Projects use the canonical turquoise brand default', () {
    expect(ProjectPlanCodec.defaultColorValue, 0xFF087F8C);
    expect(ProjectPlan(id: 'new', title: 'جدید').colorValue, 0xFF087F8C);
  });

  test('legacy Project shape gets safe defaults', () {
    final project = codec.decode({
      'id': 'legacy-project',
      'title': 'قدیمی',
    });

    expect(project.colorValue, ProjectPlanCodec.defaultColorValue);
    expect(project.isArchived, isFalse);
    expect(project.itemIds, isEmpty);
  });

  test('list codec preserves order and canonical Task id references', () {
    final encoded = codec.encodeList([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-a']),
      ProjectPlan(
        id: 'b',
        title: 'ب',
        isArchived: true,
        itemIds: const ['task-b'],
      ),
    ]);
    final decoded = codec.decodeList(encoded);

    expect(decoded.map((project) => project.id), ['a', 'b']);
    expect(decoded[0].itemIds, ['task-a']);
    expect(decoded[1].itemIds, ['task-b']);
    expect(decoded[1].isArchived, isTrue);
  });

  test('rejects malformed project identity, archive state or membership', () {
    expect(
      () => codec.decode({'id': '', 'title': 'بدون شناسه'}),
      throwsFormatException,
    );
    expect(
      () => codec.decode({
        'id': 'project',
        'title': 'کاری',
        'isArchived': 'yes',
      }),
      throwsFormatException,
    );
    expect(
      () => codec.decode({
        'id': 'project',
        'title': 'کاری',
        'itemIds': ['task-1', 2],
      }),
      throwsFormatException,
    );
    expect(() => codec.decodeList({'id': 'not-a-list'}), throwsFormatException);
  });
  test('legacy centerId decodes as one canonical Center edge', () {
    final project = codec.decode({
      'id': 'legacy-center-project',
      'title': 'قدیمی',
      'centerId': 'center-old',
    });
    expect(project.centerId, 'center-old');
    expect(project.centerIds, ['center-old']);
    expect(project.centerRelationshipsSpecified, isTrue);
  });

  test('multi-Center and multi-Category relationships round-trip deterministically', () {
    final project = ProjectPlan(
      id: 'project-m2m',
      title: 'چند رابطه',
      centerIds: const ['center-b', 'center-a'],
      categoryIds: const ['category-z', 'category-a'],
      itemIds: const ['task-2', 'task-1'],
      legacyFields: const {
        'createdAt': '2026-01-02T03:04:05.000Z',
        'historicalMetadata': {'source': 'old-backup', 'revision': 3},
      },
    );
    final encoded = codec.encode(project);
    final decoded = codec.decode(encoded);
    expect(decoded.centerIds, ['center-a', 'center-b']);
    expect(decoded.categoryIds, ['category-a', 'category-z']);
    expect(decoded.legacyFields['createdAt'], '2026-01-02T03:04:05.000Z');
    expect(decoded.legacyFields['historicalMetadata'], {
      'source': 'old-backup', 'revision': 3,
    });
    expect(codec.encode(decoded), encoded);
  });

  test('missing and explicit NULL relationship fields have distinct patch semantics', () {
    final missing = codec.decode({'id': 'missing', 'title': 'بدون روابط'});
    final explicitNull = codec.decode({
      'id': 'nulls',
      'title': 'روابط خالی',
      'centerIds': null,
      'categoryIds': null,
      'itemIds': null,
    });
    expect(missing.centerRelationshipsSpecified, isFalse);
    expect(missing.categoryRelationshipsSpecified, isFalse);
    expect(missing.itemIdsSpecified, isFalse);
    expect(explicitNull.centerRelationshipsSpecified, isTrue);
    expect(explicitNull.categoryRelationshipsSpecified, isTrue);
    expect(explicitNull.itemIdsSpecified, isTrue);
    expect(explicitNull.centerIds, isEmpty);
    expect(explicitNull.categoryIds, isEmpty);
    expect(explicitNull.itemIds, isEmpty);
  });

}
