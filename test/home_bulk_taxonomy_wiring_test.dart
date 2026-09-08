import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home bulk taxonomy actions reuse canonical mutation service', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains("import 'services/task_bulk_mutation_service.dart';"),
    );
    expect(source, contains('TaskBulkMutationService taskBulkMutationService'));
    expect(source, contains('taskBulkMutationService.moveToCategory('));
    expect(source, contains('taskBulkMutationService.addTags('));
    expect(source, contains('onCategory: _moveSelectedToCategory'));
    expect(source, contains('onTags: _addTagsToSelected'));
    expect(source, contains("ValueKey('task-bulk-category-input')"));
    expect(source, contains("ValueKey('task-bulk-tags-input')"));
    expect(source, contains('await _save()'));
  });

  test('bulk taxonomy actions clear selection only after a real mutation', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('if (changed == 0) return;'));
    expect(source, contains('selected.clear();'));
    expect(source, contains('selectionMode = false;'));
    expect(source, contains("split(RegExp(r'[,،]'))"));
  });
}
