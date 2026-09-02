import 'package:arvin/widgets/task_bulk_selection_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    double width = 500,
    int selectedCount = 2,
    bool allVisibleSelected = false,
    VoidCallback? onToggleAll,
    VoidCallback? onClear,
    VoidCallback? onArchive,
    VoidCallback? onTrash,
    VoidCallback? onCategory,
    VoidCallback? onTags,
    VoidCallback? onShare,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: width,
              child: TaskBulkSelectionBar(
                selectedCount: selectedCount,
                allVisibleSelected: allVisibleSelected,
                onToggleAll: onToggleAll ?? () {},
                onClearSelection: onClear ?? () {},
                onArchive: onArchive,
                onTrash: onTrash,
                onCategory: onCategory,
                onTags: onTags,
                onShare: onShare,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows selected count and select-all state', (tester) async {
    await tester.pumpWidget(
      host(selectedCount: 3, allVisibleSelected: true),
    );

    expect(find.text('3 انتخاب'), findsOneWidget);
    expect(find.text('لغو همه'), findsOneWidget);
    expect(find.byIcon(Icons.check_box), findsOneWidget);
  });

  testWidgets('selection controls and enabled actions invoke callbacks',
      (tester) async {
    var toggled = 0;
    var cleared = 0;
    var archived = 0;
    var trashed = 0;
    var categorized = 0;
    var tagged = 0;
    var shared = 0;

    await tester.pumpWidget(
      host(
        onToggleAll: () => toggled++,
        onClear: () => cleared++,
        onArchive: () => archived++,
        onTrash: () => trashed++,
        onCategory: () => categorized++,
        onTags: () => tagged++,
        onShare: () => shared++,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('task-bulk-select-all')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-clear')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-archive')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-trash')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-category')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-tags')));
    await tester.tap(find.byKey(const ValueKey('task-bulk-share')));

    expect(toggled, 1);
    expect(cleared, 1);
    expect(archived, 1);
    expect(trashed, 1);
    expect(categorized, 1);
    expect(tagged, 1);
    expect(shared, 1);
  });

  testWidgets('unwired actions stay disabled', (tester) async {
    await tester.pumpWidget(host());

    for (final key in [
      'task-bulk-archive',
      'task-bulk-trash',
      'task-bulk-category',
      'task-bulk-tags',
      'task-bulk-share',
    ]) {
      expect(
        tester.widget<IconButton>(find.byKey(ValueKey(key))).onPressed,
        isNull,
      );
    }
  });

  testWidgets('compact width stays layout-safe', (tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      host(
        width: 300,
        selectedCount: 12,
        onArchive: () {},
        onTrash: () {},
        onCategory: () {},
        onTags: () {},
        onShare: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('task-bulk-selection-bar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
