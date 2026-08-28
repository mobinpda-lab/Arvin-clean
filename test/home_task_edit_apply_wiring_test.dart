import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home edit uses TaskEditApplyService instead of manual field copying', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains("import 'services/task_edit_apply_service.dart';"),
    );
    expect(source, contains('final TaskEditApplyService taskEditApplyService'));
    expect(source, contains('taskEditApplyService.apply(old, edited);'));

    expect(source, isNot(contains('old.title = edited.title;')));
    expect(source, isNot(contains('old.description = edited.description;')));
    expect(source, isNot(contains('old.followUpDate = edited.followUpDate;')));
    expect(source, isNot(contains('old.tags = List<String>.of(edited.tags);')));
  });
}
