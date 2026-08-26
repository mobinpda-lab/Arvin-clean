abstract interface class AutomaticFollowUpSchedulerAdapter {
  Future<void> reschedule();
  Future<void> cancel();
}
