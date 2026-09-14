class HomeGroup<T> {
  final String id;
  final String title;
  final List<T> items;

  const HomeGroup({
    required this.id,
    required this.title,
    required this.items,
  });

  int get count => items.length;
}
