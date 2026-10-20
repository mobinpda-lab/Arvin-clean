import 'dart:io';

import 'package:arvin/main.dart' as app;
import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/recurrence.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/persian_date_formatter.dart';
import 'package:arvin/services/task_recurrence_repository.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


class _ChecklistFileBackedBackupService extends ArvinBackupService {
  _ChecklistFileBackedBackupService(this.file);

  final File file;
  int writes = 0;

  @override
  String createBackupFileName(DateTime dateTime) => file.uri.pathSegments.last;

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writes += 1;
    final bytes = await prepareBackupBytes(
      payload,
      passphrase: encryptionPassphrase,
    );
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    if (!await file.exists()) return null;
    return decodeBackupBytes(
      await file.readAsBytes(),
      passphrase: passphrase,
    );
  }
}

void _logOccurrenceStates(String phase, Task task, List<DateTime> dates) {
  for (var index = 0; index < dates.length; index++) {
    final key = dates[index].toIso8601String();
    final snapshot = task.checklistOccurrences[key];
    final lifecycle = task.occurrenceHistory[key]?['status'] ?? 'unset';
    debugPrint(
      'ARVIN_CHECKLIST_OCCURRENCE_STATE phase=$phase day=${index + 1} task_id=${task.id} key=$key stored_snapshot_present=${snapshot != null} stored_snapshot=$snapshot lifecycle=$lifecycle task_completed=${task.completed} stored_occurrence_count=${task.checklistOccurrences.length}',
    );
  }
}

const _prefix = 'ARVIN-CHECKLIST-WAVE-5-01-';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'creates a real Task, edits its recurring checklist through UI and persists seven occurrences',
    (tester) async {
      final store = TaskStore();
      // The emulator is disposable CI state. Remove only this test's own
      // namespaced fixtures so retries cannot create ambiguous evidence.
      await store.mutate<void>((tasks) {
        tasks.removeWhere((task) => task.title.startsWith(_prefix));
      });

      Future<void> waitForFinder(Finder finder, {int attempts = 100}) async {
        for (var attempt = 0; attempt < attempts; attempt++) {
          if (finder.evaluate().isNotEmpty) return;
          await tester.pump(const Duration(milliseconds: 100));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      Future<List<Task>> matchingTasks() async => (await store.load())
          .where((task) => task.title.startsWith(_prefix))
          .toList(growable: false);

      app.main();
      await tester.pumpAndSettle();
      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
      await tester.pumpAndSettle();
      final quickCapture = find.byKey(const ValueKey('quick-capture-dialog'));
      await waitForFinder(quickCapture);
      expect(quickCapture, findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('quick-capture-input')),
        '$_prefix مدرسه',
      );
      await tester.tap(find.byKey(const ValueKey('quick-capture-full-form')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('arvin-task-editor-dialog')), findsOneWidget);

      // Start four local calendar days in the past so the seven real Repeat
      // occurrences cover four historical days, today, and two future days.
      final reminderDateRollbox =
          find.byKey(const ValueKey('task-editor-reminder-date-rollbox'));
      await tester.ensureVisible(reminderDateRollbox);
      await tester.tap(reminderDateRollbox);
      await tester.pumpAndSettle();
      await tester.tap(find.text('تاریخ سفارشی').last);
      await tester.pumpAndSettle();
      const formatter = PersianDateFormatter();
      final pastAnchor = DateTime.now().subtract(const Duration(days: 4));
      final pastJalali = formatter.toJalali(pastAnchor);
      for (var attempt = 0; attempt < 3; attempt++) {
        final visibleYear = tester
            .widget<DropdownButton<int>>(
              find.byKey(const ValueKey('persian-date-year')),
            )
            .value;
        final visibleMonth = tester
            .widget<Text>(
              find.byKey(const ValueKey('persian-date-month-name')),
            )
            .data;
        if (visibleYear == pastJalali.year &&
            visibleMonth == formatter.monthName(pastJalali.month)) {
          break;
        }
        await tester.tap(find.byTooltip('ماه قبل'));
        await tester.pumpAndSettle();
      }
      await tester.tap(
        find.byKey(ValueKey('persian-date-day-${pastJalali.day}')),
      );
      await tester.pump();
      await tester.tap(find.text('تأیید').last);
      await tester.pumpAndSettle();

      final checklistToggle = find.byKey(const ValueKey('task-editor-checklist-toggle'));
      await tester.ensureVisible(checklistToggle);
      await tester.tap(checklistToggle);
      await tester.pumpAndSettle();
      final checklistInput = find.byKey(const ValueKey('task-editor-checklist-input'));
      final checklistAdd = find.byKey(const ValueKey('task-editor-checklist-add'));
      for (final item in const ['A', 'B', 'C']) {
        await tester.ensureVisible(checklistInput);
        await tester.enterText(checklistInput, item);
        await tester.tap(checklistAdd);
        await tester.pump();
      }

      // Configure Repeat through the same UI control used by the product.
      final recurrenceControl = find.byKey(const ValueKey('task-editor-recurrence'));
      await tester.ensureVisible(recurrenceControl);
      await tester.tap(recurrenceControl);
      await tester.pumpAndSettle();
      await tester.tap(find.text('روزانه').last);
      await tester.pumpAndSettle();
      final save = find.byKey(const ValueKey('task-editor-header-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      final cancelCapture = find.byKey(const ValueKey('quick-capture-cancel'));
      if (cancelCapture.evaluate().isNotEmpty) {
        await tester.tap(cancelCapture);
        await tester.pumpAndSettle();
      }

      var matches = await matchingTasks();
      expect(matches, hasLength(1),
          reason: 'The Task must be created through the actual Arvin UI exactly once.');
      final createdId = matches.single.id;
      expect(createdId, isNotEmpty);
      expect(matches.single.checklist, const ['[ ] A', '[ ] B', '[ ] C']);
      expect(matches.single.checklistEnabled, isTrue,
          reason: 'Checklist enabled state must persist from the creation UI.');

      final today = DateTime.now();
      final beforeRule = (await store.load()).singleWhere((task) => task.id == createdId);
      expect(beforeRule.recurrence, isNotNull);
      expect(beforeRule.recurrence!.frequency, RecurrenceFrequency.daily);
      expect(beforeRule.recurrence!.active, isTrue);
      expect(beforeRule.checklistEnabled, isTrue);

      // Observe the schedule produced by the persisted UI-created rule.
      // This end-to-end test deliberately does not fabricate seven stored
      // snapshots; snapshot/history preservation belongs to storage tests.
      final rule = beforeRule.recurrence!;
      // The real UI defaults Repeat to "from Task time" when no explicit start
      // date is chosen. Use that canonical Task timestamp as the schedule anchor.
      final anchor = rule.startDate ?? beforeRule.reminderDate ?? beforeRule.createdAt;
      expect(anchor, isNotNull,
          reason: 'The UI-created Repeat rule must expose a canonical schedule anchor.');
      final scheduleAnchor = anchor!;
      final dates = rule.occurrencesBetween(
        anchor: scheduleAnchor,
        from: scheduleAnchor,
        to: scheduleAnchor.add(const Duration(days: 7)),
      );
      expect(dates, hasLength(7));
      expect(
        rule.occurrencesBetween(
          anchor: scheduleAnchor,
          from: scheduleAnchor,
          to: scheduleAnchor.add(const Duration(days: 7)),
        ),
        dates,
        reason: 'Repeat schedule calculation must be idempotent.',
      );

      final recurrence = TaskRecurrenceRepository(store: store, now: () => today);

      // Rebuild Home from canonical storage so the real editor receives the
      // persisted Repeat state rather than a stale in-memory Task copy.
      await tester.pumpWidget(const SizedBox.shrink());
      await app.main();
      await tester.pumpAndSettle();
      final secondSkipGuide = find.text('رد کردن');
      if (secondSkipGuide.evaluate().isNotEmpty) {
        await tester.tap(secondSkipGuide);
        await tester.pumpAndSettle();
      }

      final card = find.byKey(ValueKey(createdId));
      await waitForFinder(card);
      expect(card, findsOneWidget);
      final cardTapTarget = find.byKey(
        ValueKey('task-card-open-$createdId'),
      );
      expect(cardTapTarget, findsOneWidget);
      await tester.ensureVisible(cardTapTarget);
      await tester.tap(cardTapTarget);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('occurrence-checklist-card')),
        findsOneWidget,
        reason: 'Recurring Task Details must show the occurrence-scoped Checklist editor.',
      );
      final occurrencePicker =
          find.byKey(ValueKey('occurrence-checklist-picker-$createdId'));
      final tickPatterns = <Set<int>>[
        <int>{0, 2},
        <int>{1},
        <int>{0, 1},
        <int>{2},
        <int>{},
        <int>{},
        <int>{},
      ];
      for (var index = 0; index < dates.length; index++) {
        await tester.tap(occurrencePicker);
        await tester.pumpAndSettle();
        final occurrenceLabel = formatter.format(
          dates[index],
          usePersianDate: true,
        );
        await tester.tap(find.text(occurrenceLabel).last);
        await tester.pumpAndSettle();
        for (final itemIndex in tickPatterns[index]) {
          await tester.tap(
            find.byKey(
              ValueKey(
                'occurrence-checklist-item-$createdId-${dates[index].toIso8601String()}-$itemIndex',
              ),
            ),
          );
          await tester.pump();
        }
        await tester.tap(find.byKey(const ValueKey('occurrence-checklist-save')));
        await tester.pumpAndSettle();
      }

      await recurrence.completeOccurrence(
        createdId,
        dates[4],
        completedAt: DateTime.now(),
      );
      await recurrence.cancelOccurrence(
        createdId,
        dates[5],
        result: 'Wave 5.14 preservation sentinel',
      );

      final before = (await store.load()).singleWhere((task) => task.id == createdId);
      final expectedBefore = <List<String>>[
        const ['[x] A', '[ ] B', '[x] C'],
        const ['[ ] A', '[x] B', '[ ] C'],
        const ['[x] A', '[x] B', '[ ] C'],
        const ['[ ] A', '[ ] B', '[x] C'],
        const ['[ ] A', '[ ] B', '[ ] C'],
        const ['[ ] A', '[ ] B', '[ ] C'],
        const ['[ ] A', '[ ] B', '[ ] C'],
      ];
      final originalSnapshots = <String, List<String>>{
        for (final entry in before.checklistOccurrences.entries)
          entry.key: List<String>.of(entry.value),
      };
      final originalHistory = <String, Map<String, dynamic>>{
        for (final entry in before.occurrenceHistory.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      };
      expect(before.id, createdId);
      expect(
        before.checklistOccurrences.keys.toSet(),
        dates.map((date) => date.toIso8601String()).toSet(),
        reason: 'All seven snapshots must be created by the real occurrence UI.',
      );
      expect(before.checklistOccurrences.length, 7);
      for (var index = 0; index < dates.length; index++) {
        expect(
          before.checklistOccurrences[dates[index].toIso8601String()],
          expectedBefore[index],
          reason: 'Occurrence ${dates[index]} must retain its own UI-saved ticks.',
        );
      }
      expect(originalHistory.keys.toSet(), {
        dates[4].toIso8601String(),
        dates[5].toIso8601String(),
      });
      debugPrint(
        'ARVIN_CHECKLIST_PRE_EDIT task_id=${before.id} schedule_count=${dates.length} stored_snapshot_count=${before.checklistOccurrences.length} history_count=${before.occurrenceHistory.length}',
      );
      _logOccurrenceStates('pre-edit', before, dates);

      await tester.tap(find.byKey(const ValueKey('task-detail-edit')));
      await tester.pumpAndSettle();
      // The detail callback awaits canonical editor preparation before showing
      // the dialog. pumpAndSettle alone can return while that future is pending.
      final editDialog = find.byKey(const ValueKey('arvin-task-editor-dialog'));
      await waitForFinder(editDialog);
      expect(
        editDialog,
        findsOneWidget,
        reason: 'The real Task Detail edit action must open ArvinTaskEditorDialog.',
      );

      // A saved Task may retain its checklist rows while the editor's display
      // toggle is off. Enable the canonical editor section before editing rows.
      final checklistBlock = find.byKey(const ValueKey('task-editor-checklist-block'));
      if (checklistBlock.evaluate().isEmpty) {
        final editChecklistToggle = find.byKey(const ValueKey('task-editor-checklist-toggle'));
        await tester.ensureVisible(editChecklistToggle);
        await tester.tap(editChecklistToggle);
        await tester.pumpAndSettle();
      }
      expect(checklistBlock, findsOneWidget);
      final deleteC = find.byKey(const ValueKey('task-editor-checklist-delete-2'));
      expect(deleteC, findsOneWidget);
      await tester.ensureVisible(deleteC);
      await tester.tap(deleteC);
      await tester.pump();
      await tester.enterText(checklistInput, 'D');
      await tester.tap(checklistAdd);
      await tester.pump();
      final checklistSection =
          find.byKey(const ValueKey('task-editor-checklist-section'));
      expect(checklistSection, findsOneWidget);
      expect(
        find.descendant(of: checklistSection, matching: find.text('C')),
        findsNothing,
        reason: 'Removed option C must not remain in the editor Checklist.',
      );
      expect(
        find.descendant(of: checklistSection, matching: find.text('D')),
        findsOneWidget,
        reason: 'New option D must appear in the editor Checklist.',
      );
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      matches = await matchingTasks();
      expect(matches, hasLength(1));
      final after = matches.single;
      expect(after.id, createdId);
      expect(after.checklist, const ['[ ] A', '[ ] B', '[ ] D']);
      expect(after.recurrence, isNotNull);
      expect(after.recurrence!.frequency, RecurrenceFrequency.daily);
      expect(
        after.checklistOccurrences.keys.toSet(),
        originalSnapshots.keys.toSet(),
        reason: 'Template edit must preserve the exact set of real occurrence keys.',
      );
      expect(after.checklistOccurrences.length, 7);
      for (var index = 0; index < 4; index++) {
        expect(
          after.checklistOccurrences[dates[index].toIso8601String()],
          originalSnapshots[dates[index].toIso8601String()],
          reason: 'Past occurrence ${dates[index]} must preserve its checklist and ticks.',
        );
      }
      for (var index = 4; index < 7; index++) {
        expect(
          after.checklistOccurrences[dates[index].toIso8601String()],
          const ['[ ] A', '[ ] B', '[ ] D'],
          reason: 'Current/future occurrence ${dates[index]} must rebuild unchecked.',
        );
      }
      expect(after.occurrenceHistory, originalHistory);
      expect(after.completed, isFalse);
      expect(after.checklistEnabled, isTrue);
      for (var index = 0; index < dates.length; index++) {
        expect(
          await recurrence.checklistForOccurrence(createdId, dates[index]),
          index < 4
              ? originalSnapshots[dates[index].toIso8601String()]
              : const ['[ ] A', '[ ] B', '[ ] D'],
        );
      }
      final refreshedLastItem = tester.widget<CheckboxListTile>(
        find.byKey(
          ValueKey(
            'occurrence-checklist-item-$createdId-${dates.last.toIso8601String()}-2',
          ),
        ),
      );
      expect((refreshedLastItem.title as Text).data, 'D');
      expect(refreshedLastItem.value, isFalse);
      _logOccurrenceStates('post-edit', after, dates);
      final repeatedDates = after.recurrence!.occurrencesBetween(
        anchor: scheduleAnchor,
        from: scheduleAnchor,
        to: scheduleAnchor.add(const Duration(days: 7)),
      );
      expect(repeatedDates, dates,
          reason: 'Re-evaluating Repeat after edit must not add duplicate occurrences.');
      debugPrint(
        'ARVIN_CHECKLIST_POST_EDIT task_id=${after.id} schedule_count=${repeatedDates.length} stored_snapshot_count=${after.checklistOccurrences.length} history_count=${after.occurrenceHistory.length} task_count=${matches.length}',
      );
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('checklist-evolution-after-edit');

      // Exercise the existing BackupPage UI against the same canonical Task.
      // The injected service keeps CI independent of Android's external file
      // picker; physical SAF/provider acceptance remains a separate gate.
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        ArvinBackupManager.directoryKey,
        'content://arvin-checklist-wave-5-00',
      );
      final backupDirectory =
          await Directory.systemTemp.createTemp('arvin-checklist-backup-');
      addTearDown(() async {
        if (await backupDirectory.exists()) {
          await backupDirectory.delete(recursive: true);
        }
      });
      final backupFile = File(
        '${backupDirectory.path}/checklist-wave-5-00.json',
      );
      final backupService = _ChecklistFileBackedBackupService(backupFile);
      final backupManager = ArvinBackupManager(service: backupService);
      await tester.pumpWidget(
        MaterialApp(
          home: BackupPage(
            manager: backupManager,
            loadTasks: () async => (await store.load())
                .map((task) => task.toJson())
                .toList(growable: false),
            replaceTasks: (rawTasks) async {
              await store.save(
                rawTasks.map((raw) => Task.fromJson(raw)).toList(growable: false),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final createBackupButton = find.byKey(const Key('create_backup_button'));
      await tester.ensureVisible(createBackupButton);
      await tester.tap(createBackupButton);
      await tester.pumpAndSettle();
      expect(backupService.writes, 1);
      final backupDocument = await backupService.readBackup();
      expect(backupDocument, isNotNull);
      final rawBackupTasks = (backupDocument!['tasks'] as List)
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .toList(growable: false);
      final backedUp = Task.fromJson(
        rawBackupTasks.singleWhere((raw) => raw['id'] == createdId),
      );
      expect(backedUp.id, createdId);
      expect(backedUp.checklist, after.checklist);
      expect(backedUp.checklistOccurrences, after.checklistOccurrences);
      expect(backedUp.occurrenceHistory, after.occurrenceHistory);
      _logOccurrenceStates('pre-backup', backedUp, dates);

      // Deliberately corrupt only this Task after backup so Restore must
      // recover the saved canonical Task rather than re-read the live value.
      await store.mutate<void>((tasks) {
        final task = tasks.singleWhere((item) => item.id == createdId);
        task.title = '$_prefix corrupted-after-backup';
        task.checklist = const ['[ ] CORRUPTED'];
        task.checklistOccurrences = <String, List<String>>{};
        task.occurrenceHistory = <String, Map<String, dynamic>>{};
      });
      final restoreButton = find.byKey(const Key('restore_plain_backup_button'));
      await tester.ensureVisible(restoreButton);
      await tester.tap(restoreButton);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('تأیید بازیابی'), findsOneWidget);
      await tester.tap(find.byKey(const Key('restore_confirm_apply')));
      await tester.pump(const Duration(seconds: 1));

      final restored = (await TaskStore().load())
          .singleWhere((task) => task.id == createdId);
      expect(restored.id, createdId);
      expect(restored.title, after.title);
      expect(restored.checklist, const ['[ ] A', '[ ] B', '[ ] D']);
      expect(restored.checklistOccurrences, after.checklistOccurrences);
      expect(restored.occurrenceHistory, after.occurrenceHistory);
      expect(restored.completed, isFalse);
      expect(
        (await store.load()).where((task) => task.title.startsWith(_prefix)),
        hasLength(1),
      );
      expect(backupService.writes, greaterThanOrEqualTo(2),
          reason: 'Restore must create its emergency pre-restore backup.');
      _logOccurrenceStates('post-restore', restored, dates);
      debugPrint(
        'ARVIN_CHECKLIST_BACKUP_RESTORE task_id=${restored.id} schedule_count=${dates.length} stored_snapshot_count=${restored.checklistOccurrences.length} history_count=${restored.occurrenceHistory.length} backup_writes=${backupService.writes}',
      );
    },
  );
}