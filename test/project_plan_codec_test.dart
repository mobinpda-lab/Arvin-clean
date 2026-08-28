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
      itemIds: const ['task-1', 'task-2'],
    );

    final encoded = codec.encode(project);
    final decoded = codec.decode(encoded);

    expect(encoded.keys.toSet(), {'id', 'title', 'colorValue', 'itemIds'});
    expect(decoded.id, project.id);
    expect(decoded.title, project.title);
    expect(decoded.colorValue, project.colorValue);
    expect(decoded.itemIds, project.itemIds);
  });

  test('legacy Project shape gets safe color and empty membership defaults', () {
    final project = codec.decode({
      'id': 'legacy-project',
      'title': 'قدیمی',
    });

    expect(project.colorValue, ProjectPlanCodec.defaultColorValue);
    expect(project.itemIds, isEmpty);
  });

  test('list codec preserves order and canonical Task id references', () {
    final encoded = codec.encodeList([
      ProjectPlan(id: 'a', title: 'الف', itemIds: const ['task-a']),
      ProjectPlan(id: 'b', title: 'ب', itemIds: const ['task-b']),
    ]);
    final decoded = codec.decodeList(encoded);

    expect(decoded.map((project) => project.id), ['a', 'b']);
    expect(decoded[0].itemIds, ['task-a']);
    expect(decoded[1].itemIds, ['task-b']);
  });

  test('rejects malformed project identity or membership', () {
    expect(
      () => codec.decode({'id': '', 'title': 'بدون شناسه'}),
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
}
