/// Stable application boundary for task persistence.
///
/// The core layer stays independent from Flutter, storage packages, and
/// concrete task models. Feature code can depend on this contract while the
/// existing storage implementation remains unchanged during migration.
abstract interface class TaskStore<T> {
  Future<List<T>> load();

  Future<void> save(List<T> items);
}
