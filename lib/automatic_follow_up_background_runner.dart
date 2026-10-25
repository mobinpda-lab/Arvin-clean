/// Retired entry point retained only to safely absorb a stale AlarmManager
/// callback from an older installation before the canonical scheduler cancels
/// the old Arvin-owned alarm ID. It must never read or mutate Task data or
/// deliver a legacy Next Follow-up notification.
@pragma('vm:entry-point')
Future<void> arvinAutomaticFollowUpAlarmCallback() async {}
