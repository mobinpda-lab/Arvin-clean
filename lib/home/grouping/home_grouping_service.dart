import 'home_group.dart';
import 'home_group_mode.dart';

class HomeGroupingService<T> {
  const HomeGroupingService();

  List<HomeGroup<T>> group(List<T> items, HomeGroupMode mode) {
    switch (mode) {
      case HomeGroupMode.time:
      case HomeGroupMode.projects:
      case HomeGroupMode.categories:
      case HomeGroupMode.labels:
        return [
          HomeGroup<T>(
            id: mode.name,
            title: mode.name,
            items: items,
          ),
        ];
    }
  }
}
