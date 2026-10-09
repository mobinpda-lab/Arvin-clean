import '../calendar_page.dart';
import 'app_settings_service.dart';
import 'calendar_provider_sync_executor.dart';
import 'calendar_sync_plan_service.dart';
import 'external_calendar_link_store.dart';

/// Product-level outbound sync coordinator for canonical Arvin reminders.
///
/// It reuses the existing revision/planner/executor/link foundations. It does
/// not persist another event model and it performs no provider writes unless
/// calendar integration and outbound sync are explicitly enabled with a target
/// calendar selected by the owner.
class CalendarOutboundSyncService {
  CalendarOutboundSyncService({
    AppSettingsService? settingsService,
    CalendarSyncRevisionService? revisionService,
    CalendarSyncPlanService? planService,
    CalendarProviderSyncExecutor? executor,
    ExternalCalendarLinkStore? linkStore,
  })  : settingsService = settingsService ?? AppSettingsService(),
        revisionService = revisionService ?? CalendarSyncRevisionService(),
        planService = planService ?? const CalendarSyncPlanService(),
        executor = executor ?? CalendarProviderSyncExecutor(),
        linkStore = linkStore ?? ExternalCalendarLinkStore();

  final AppSettingsService settingsService;
  final CalendarSyncRevisionService revisionService;
  final CalendarSyncPlanService planService;
  final CalendarProviderSyncExecutor executor;
  final ExternalCalendarLinkStore linkStore;

  String? _taskIdForReminder(String reminderId) {
    for (final prefix in const <String>[
      'task-due:',
      'task-reminder:',
      'task-followup:',
      'task-recurrence:',
    ]) {
      if (reminderId.startsWith(prefix)) {
        final value = reminderId.substring(prefix.length);
        final separator = value.indexOf(':');
        return separator < 0 ? value : value.substring(0, separator);
      }
    }
    if (reminderId.startsWith('followup:')) {
      final value = reminderId.substring('followup:'.length);
      final separator = value.indexOf(':');
      if (separator > 0) return value.substring(0, separator);
    }
    return null;
  }

  Future<CalendarProviderSyncResult?> sync(
    Iterable<CalendarReminder> reminders, {
    bool force = false,
    bool linkedOnly = false,
  }) async {
    final integration = (await settingsService.load()).calendarIntegration;
    final targetCalendarId = integration.targetCalendarId?.trim();
    if (!integration.enabled ||
        (!integration.autoSync && !force) ||
        targetCalendarId == null ||
        targetCalendarId.isEmpty) {
      return null;
    }

    final links = await linkStore.load();
    final linkedReminderIds = links.map((link) => link.reminderId).toSet();
    final importedTaskIds = links
        .where((link) => link.reminderId.startsWith('external-calendar:') &&
            link.lastSyncedFingerprint.startsWith('imported-task:'))
        .map((link) => link.lastSyncedFingerprint.substring('imported-task:'.length))
        .where((id) => id.isNotEmpty)
        .toSet();

    final revisions = <CalendarSyncRevision>[];
    for (final reminder in reminders) {
      if (linkedOnly && !linkedReminderIds.contains(reminder.id)) continue;
      final taskId = _taskIdForReminder(reminder.id);
      if (taskId != null && importedTaskIds.contains(taskId)) continue;
      if (!_enabledForReminder(integration, reminder)) continue;
      try {
        revisions.add(await revisionService.fromReminder(reminder));
      } on ArgumentError {
        // Official, prayer, external, completed and otherwise non-canonical
        // reminders are intentionally outside outbound provider sync.
      }
    }

    if (linkedOnly && revisions.isEmpty) return null;

    final managedLinks = links.where((link) => _enabledForReminderId(integration, link.reminderId));
    final revisionIds = revisions.map((revision) => revision.reminderId).toSet();
    final linksForPlan = linkedOnly
        ? managedLinks.where((link) => revisionIds.contains(link.reminderId))
        : integration.deleteLinkedEventWithTask
            ? managedLinks
            : managedLinks.where((link) => revisionIds.contains(link.reminderId));
    final plan = planService.plan(
      revisions: revisions,
      links: linksForPlan,
      targetCalendarId: targetCalendarId,
    );
    final result = await executor.execute(
      plan: plan,
      targetCalendarId: targetCalendarId,
    );
    if (!linkedOnly && !integration.deleteLinkedEventWithTask) {
      final orphanedManagedIds = managedLinks
          .map((link) => link.reminderId)
          .where((id) => !revisionIds.contains(id))
          .toSet();
      if (orphanedManagedIds.isNotEmpty) {
        await linkStore.removeByReminderIds(orphanedManagedIds);
      }
    }
    return result;
  }

  bool _enabledForReminder(
    CalendarIntegrationSettings integration,
    CalendarReminder reminder,
  ) => _enabledForReminderId(integration, reminder.id);

  bool _enabledForReminderId(
    CalendarIntegrationSettings integration,
    String id,
  ) {
    if (id.startsWith('task-due:')) {
      return integration.syncDueDates;
    }
    if (id.startsWith('task-reminder:')) {
      return integration.syncTaskReminders;
    }
    if (id.startsWith('followup:')) {
      return integration.syncFollowUps;
    }
    if (id.startsWith('task-followup:')) {
      return integration.syncFollowUpReminders;
    }
    if (id.startsWith('task-recurrence:')) {
      return integration.syncRecurrence;
    }
    return false;
  }
}
