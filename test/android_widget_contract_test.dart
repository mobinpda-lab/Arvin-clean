import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android Widget reuses canonical Task SharedPreferences only', () {
    final source = File(
      'android/app/src/main/kotlin/com/example/arvin/ArvinWidgetProvider.kt',
    ).readAsStringSync();

    expect(source, contains('FlutterSharedPreferences'));
    expect(source, contains('flutter.arvin.tasks'));
    expect(source, contains('followUps'));
    expect(source, contains('dateTime'));
    expect(source, isNot(contains('widget.tasks')));
    expect(source, isNot(contains('SharedPreferences.Editor')));
  });

  test('manifest and provider info register one canonical reminder widget', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final info = File('android/app/src/main/res/xml/arvin_widget_info.xml').readAsStringSync();
    final layout = File('android/app/src/main/res/layout/arvin_widget.xml').readAsStringSync();

    expect(manifest, contains('.ArvinWidgetProvider'));
    expect(manifest, contains('android.appwidget.action.APPWIDGET_UPDATE'));
    expect(manifest, contains('@xml/arvin_widget_info'));
    expect(info, contains('home_screen|keyguard'));
    expect(info, contains('@layout/arvin_widget'));
    expect(layout, contains('android:layoutDirection="rtl"'));
    expect(layout, contains('یادآورهای آروین'));
    expect(layout, contains('android:text="یادآور"'));
  });

  test('widget rows carry canonical task id to app intent', () {
    final source = File(
      'android/app/src/main/kotlin/com/example/arvin/ArvinWidgetProvider.kt',
    ).readAsStringSync();

    expect(source, contains('EXTRA_TASK_ID'));
    expect(source, contains('arvin_task_id'));
    expect(source, contains('putExtra(EXTRA_TASK_ID, row.taskId)'));
  });

  test('Home consumes widget task id and opens canonical Task detail', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'services/widget_task_bridge.dart';"));
    expect(
      source,
      contains("import 'services/widget_task_selection_service.dart';"),
    );
    expect(source, contains("import 'task_detail_page.dart';"));
    expect(source, contains('widgetTaskBridge.listen(_openWidgetTask)'));
    expect(source, contains('consumeInitialTaskId()'));
    expect(source, contains('widgetTaskSelectionService.loadTask(taskId)'));
    expect(source, contains('await _openTaskDetail(task)'));
    expect(source, contains('TaskDetailPage('));
    expect(source, contains('onAddFollowUp: _addFollowUpFromDetail'));
    expect(source, contains('widgetTaskBridge.dispose()'));
  });
}
