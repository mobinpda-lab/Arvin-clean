import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/home_task_editor_context_service.dart';
import 'package:arvin/services/task_project_assignment_service.dart';

void main() {
  test('Wave 2 editor context service is available as the canonical adapter', () {
    final service = HomeTaskEditorContextService(
      assignmentService: TaskProjectAssignmentService(),
    );

    expect(service, isA<HomeTaskEditorContextService>());
  });
}
