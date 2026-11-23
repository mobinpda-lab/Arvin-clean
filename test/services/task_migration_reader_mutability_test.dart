import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_migration_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('empty migration result remains mutable for Home add flow', () async {
    final tasks = await TaskMigrationReader().load();

    tasks.add(Task(id: 'new-task', title: 'کار جدید'));

    expect(tasks.single.id, 'new-task');
  });
}
