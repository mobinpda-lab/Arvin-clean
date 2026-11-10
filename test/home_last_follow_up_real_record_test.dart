import 'package:arvin/main.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home shows last FollowUp only for a real record and does not create one',
      (tester) async {
    final legacyDate = DateTime(2026, 10, 30, 9);
    final realDate = DateTime(2026, 10, 31, 10, 30);
    await TaskStore().save([
      Task(
        id: 'legacy-only',
        title: 'فقط داده قدیمی',
        followUpEnabled: true,
        followUpDate: legacyDate,
      ),
      Task(
        id: 'real-history',
        title: 'سابقه واقعی',
        followUpEnabled: true,
        followUpDate: DateTime(2030, 1, 1, 8),
        followUps: [
          FollowUp(
            id: 'real-followup',
            dateTime: realDate,
            note: 'پیگیری واقعی',
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('فقط داده قدیمی'), findsOneWidget);
    expect(find.text('سابقه واقعی'), findsOneWidget);
    expect(find.textContaining('آخرین پیگیری:'), findsOneWidget);

    final persisted = await TaskStore().load();
    final legacyTask = persisted.singleWhere((task) => task.id == 'legacy-only');
    final realTask = persisted.singleWhere((task) => task.id == 'real-history');
    expect(legacyTask.followUps, isEmpty);
    expect(legacyTask.followUpDate, legacyDate);
    expect(legacyTask.followUpEnabled, isTrue);
    expect(realTask.followUps, hasLength(1));
    expect(realTask.followUps.single.id, 'real-followup');
    expect(realTask.followUps.single.dateTime, realDate);
  });
}
