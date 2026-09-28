import 'package:arvin/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy checklist payload remains enabled after canonical JSON migration', () {
    final legacy = Task.fromJson({
      'id': 'legacy-checklist',
      'title': 'چک‌لیست قدیمی',
      'checklist': ['[ ] مورد قدیمی'],
    });
    expect(legacy.checklistEnabled, isTrue);
    expect(legacy.checklist, const ['[ ] مورد قدیمی']);
    expect(legacy.isNotebookChecklist, isFalse);
  });

  test('Task checklist mode survives canonical JSON round trip', () {
    final enabled = Task(
      id: 'task-checklist',
      title: 'کار',
      checklist: const ['[ ] مورد اول'],
      checklistEnabled: true,
    );
    final enabledRoundTrip = Task.fromJson(enabled.toJson());
    expect(enabledRoundTrip.checklistEnabled, isTrue);
    expect(enabledRoundTrip.checklist, const ['[ ] مورد اول']);

    final disabled = Task(
      id: 'task-checklist-disabled',
      title: 'کار',
      checklist: const ['[ ] مورد اول'],
      checklistEnabled: false,
    );
    final disabledRoundTrip = Task.fromJson(disabled.toJson());
    expect(disabledRoundTrip.checklistEnabled, isFalse);
    expect(disabledRoundTrip.checklist, const ['[ ] مورد اول']);
  });
}
