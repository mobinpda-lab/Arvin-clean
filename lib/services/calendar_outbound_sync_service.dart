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

  Future<CalendarProviderSyncResult?> sync(
    Iterable<CalendarReminder> reminders,
  ) async {
    final integration = (await settingsService.load()).calendarIntegration;
    final targetCalendarId = integration.targetCalendarId?.trim();
    if (!integration.enabled ||
        !integration.syncArvinToDevice ||
        targetCalendarId == null ||
        targetCalendarId.isEmpty) {
      return null;
    }

    final revisions = <CalendarSyncRevision>[];
    for (final reminder in reminders) {
      try {
        revisions.add(await revisionService.fromReminder(reminder));
      } on ArgumentError {
        // Official, prayer, external, completed and otherwise non-canonical
        // reminders are intentionally outside outbound provider sync.
      }
    }

    final links = await linkStore.load();
    final plan = planService.plan(revisions: revisions, links: links);
    return executor.execute(plan: plan, targetCalendarId: targetCalendarId);
  }
}
