import 'package:flutter/material.dart';

import '../home/home_filter_ui.dart';

class ReusableFilterOption<T> {
  const ReusableFilterOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class ReusableSingleSelectResult<T> {
  const ReusableSingleSelectResult({required this.value, this.cleared = false});

  final T? value;
  final bool cleared;
}

/// Shared bottom-sheet interaction for filter dimensions and entity selectors.
/// Multi-select values are ORed within one dimension; callers combine
/// dimensions with AND when applying the resulting filter state.
abstract final class ReusableMultiSelectFilterBottomSheet {
  static Future<R?> showCustom<R>(
    BuildContext context, {
    required String title,
    required Color accent,
    required Widget child,
    double heightFactor = 0.82,
  }) {
    return HomeFilterSheet.show<R>(
      context,
      title: title,
      accent: accent,
      child: child,
      heightFactor: heightFactor,
    );
  }

  static Future<Set<T>?> showMultiSelect<T>(
    BuildContext context, {
    required String title,
    required List<ReusableFilterOption<T>> options,
    required Set<T> selectedValues,
    Color? accent,
    String searchHint = 'جستجو...',
    String createHint = 'نام مورد جدید',
    String createLabel = 'افزودن و انتخاب',
    String applyLabel = 'تأیید / اعمال فیلتر',
    Future<ReusableFilterOption<T>?> Function(String value)? onCreate,
    bool allowClear = true,
  }) async {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    final available = List<ReusableFilterOption<T>>.of(options);
    final working = <T>{...selectedValues};
    final searchController = TextEditingController();
    final createController = TextEditingController();
    var search = '';
    var creating = false;

    try {
      return await showCustom<Set<T>>(
        context,
        title: title,
        accent: color,
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filtered = available
                .where((option) =>
                    option.label.toLowerCase().contains(search.toLowerCase()))
                .toList(growable: false);
            return Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) => setSheetState(() => search = value),
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
                if (onCreate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: createController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) async {
                            final value = createController.text.trim();
                            if (value.isEmpty || creating) return;
                            setSheetState(() => creating = true);
                            try {
                              final created = await onCreate(value);
                              if (!sheetContext.mounted || created == null) return;
                              setSheetState(() {
                                if (!available.any((item) => item.value == created.value)) {
                                  available.add(created);
                                }
                                working.add(created.value);
                                createController.clear();
                              });
                            } finally {
                              if (sheetContext.mounted) {
                                setSheetState(() => creating = false);
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: createHint,
                            prefixIcon: const Icon(Icons.add_circle_outline_rounded),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: creating
                              ? null
                              : () async {
                                  final value = createController.text.trim();
                                  if (value.isEmpty) return;
                                  setSheetState(() => creating = true);
                                  try {
                                    final created = await onCreate(value);
                                    if (!sheetContext.mounted || created == null) return;
                                    setSheetState(() {
                                      if (!available.any((item) => item.value == created.value)) {
                                        available.add(created);
                                      }
                                      working.add(created.value);
                                      createController.clear();
                                    });
                                  } finally {
                                    if (sheetContext.mounted) {
                                      setSheetState(() => creating = false);
                                    }
                                  }
                                },
                          child: creating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(createLabel),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    children: [
                      for (final option in filtered)
                        CheckboxListTile(
                          value: working.contains(option.value),
                          activeColor: color,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(option.label),
                          subtitle: option.subtitle == null
                              ? null
                              : Text(option.subtitle!),
                          secondary: option.icon == null
                              ? null
                              : Icon(option.icon, color: color),
                          onChanged: (checked) => setSheetState(() {
                            if (checked == true) {
                              working.add(option.value);
                            } else {
                              working.remove(option.value);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (allowClear)
                      TextButton(
                        onPressed: () => setSheetState(working.clear),
                        child: const Text('پاک کردن انتخاب‌ها'),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('لغو'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(Set<T>.of(working)),
                      child: Text(applyLabel),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    } finally {
      searchController.dispose();
      createController.dispose();
    }
  }

  static Future<ReusableSingleSelectResult<T>?> showSingleSelect<T>(
    BuildContext context, {
    required String title,
    required List<ReusableFilterOption<T>> options,
    required T? selectedValue,
    Color? accent,
    String? emptyLabel,
    String searchHint = 'جستجو...',
    String createHint = 'نام مورد جدید',
    String createLabel = 'افزودن',
    Key? createKey,
    Future<ReusableFilterOption<T>?> Function(String value)? onCreate,
  }) async {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    final available = List<ReusableFilterOption<T>>.of(options);
    final searchController = TextEditingController();
    final createController = TextEditingController();
    var search = '';
    var creating = false;
    final clearToken = Object();
    Object? selected = selectedValue ?? (emptyLabel == null ? null : clearToken);

    try {
      return await showCustom<ReusableSingleSelectResult<T>>(
        context,
        title: title,
        accent: color,
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filtered = available
                .where((option) =>
                    option.label.toLowerCase().contains(search.toLowerCase()))
                .toList(growable: false);
            Future<void> createAndSelect() async {
              final value = createController.text.trim();
              if (value.isEmpty || onCreate == null || creating) return;
              setSheetState(() => creating = true);
              try {
                final created = await onCreate(value);
                if (!sheetContext.mounted || created == null) return;
                Navigator.of(sheetContext).pop(
                  ReusableSingleSelectResult<T>(value: created.value),
                );
              } finally {
                if (sheetContext.mounted) {
                  setSheetState(() => creating = false);
                }
              }
            }

            return Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) => setSheetState(() => search = value),
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
                if (onCreate != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: createController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => createAndSelect(),
                          decoration: InputDecoration(
                            hintText: createHint,
                            prefixIcon: const Icon(Icons.add_circle_outline_rounded),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          key: createKey,
                          onPressed: creating ? null : createAndSelect,
                          child: creating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(createLabel),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Expanded(
                  child: RadioGroup<Object?>(
                    groupValue: selected,
                    onChanged: (value) {
                      if (identical(value, clearToken)) {
                        Navigator.of(sheetContext).pop(
                          const ReusableSingleSelectResult<T>(
                            value: null,
                            cleared: true,
                          ),
                        );
                      } else {
                        Navigator.of(sheetContext).pop(
                          ReusableSingleSelectResult<T>(value: value as T),
                        );
                      }
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        if (emptyLabel != null)
                          RadioListTile<Object?>(
                            value: clearToken,
                            activeColor: color,
                            title: Text(emptyLabel),
                          ),
                        for (final option in filtered)
                          RadioListTile<Object?>(
                            value: option.value,
                            activeColor: color,
                            title: Text(option.label),
                            subtitle: option.subtitle == null
                                ? null
                                : Text(option.subtitle!),
                            secondary: option.icon == null
                                ? null
                                : Icon(option.icon, color: color),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('لغو'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      searchController.dispose();
      createController.dispose();
    }
  }
}
