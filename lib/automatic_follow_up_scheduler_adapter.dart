abstract interface class AutomaticFollowUpSchedulerAdapter {
  Future<void> reschedule();
  Future<void> cancel();
}

class NoopAutomaticFollowUpSchedulerAdapter
    implements AutomaticFollowUpSchedulerAdapter {
  const NoopAutomaticFollowUpSchedulerAdapter();

  @override
  Future<void> reschedule() async {}

  @override
  Future<void> cancel() async {}
}
