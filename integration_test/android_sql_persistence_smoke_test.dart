import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canonical SQL persists a full task cycle on Android',
      (tester) async {
    final firstStore = TaskStore();
    await firstStore.save(<Task>[
      Task(
        id: 'android-sql-cycle',
        title: 'چرخه ذخیره‌سازی اندروید',
        description: 'داده کامل',
        tags: <String>['مهم'],
        category: 'فروش',
        followUps: <FollowUp>[
          FollowUp(
            id: 'android-sql-follow-up',
            dateTime: DateTime(2026, 9, 24, 10),
            note: 'پیگیری پایدار',
            completed: true,
          ),
        ],
        checklist: <String>['مرحله ۱', 'مرحله ۲'],
      ),
    ]);

    final secondStore = TaskStore();
    final loaded = await secondStore.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'android-sql-cycle');
    expect(loaded.single.title, 'چرخه ذخیره‌سازی اندروید');
    expect(loaded.single.description, 'داده کامل');
    expect(loaded.single.tags, <String>['مهم']);
    expect(loaded.single.category, 'فروش');
    expect(loaded.single.checklist, <String>['مرحله ۱', 'مرحله ۲']);
    expect(loaded.single.followUps.single.id, 'android-sql-follow-up');
    expect(loaded.single.followUps.single.note, 'پیگیری پایدار');
    expect(loaded.single.followUps.single.completed, isTrue);

    await firstStore.save(const <Task>[]);
  });
}
