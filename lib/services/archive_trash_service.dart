class ArchiveTrashService<T> {
  const ArchiveTrashService();

  T archive(T item, void Function(T item) setArchived) {
    setArchived(item);
    return item;
  }

  T moveToTrash(T item, void Function(T item) setTrashed) {
    setTrashed(item);
    return item;
  }

  T restore(T item, {required void Function(T item) clearArchived, required void Function(T item) clearTrashed}) {
    clearArchived(item);
    clearTrashed(item);
    return item;
  }
}
