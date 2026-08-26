import 'package:flutter/material.dart';

import '../theme/app_font_controller.dart';
import '../theme/font_catalog.dart';

class FontSettingsPage extends StatelessWidget {
  const FontSettingsPage({
    super.key,
    this.controller,
  });

  final AppFontController? controller;

  @override
  Widget build(BuildContext context) {
    final fontController = controller ?? AppFontController.instance;
    return ValueListenableBuilder<String>(
      valueListenable: fontController,
      builder: (context, selectedId, _) {
        final selected = AppFontCatalog.byId(selectedId);
        final options = AppFontCatalog.availableOptions.toList(growable: false);
        return Scaffold(
          appBar: AppBar(
            title: const Text('فونت برنامه'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'پیش‌نمایش',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'آروین و یادنگار؛ یک تجربه روان برای متن فارسی ۱۲۳۴۵۶۷۸۹۰',
                        style: TextStyle(
                          fontFamily: selected.family,
                          fontSize: 18,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (option) => Card(
                  child: ListTile(
                    key: Key('font-option-${option.id}'),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontFamily: option.family,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      option.id == AppFontCatalog.defaultId
                          ? 'فونت اصلی و پیش‌فرض برنامه'
                          : 'اعمال روی تمام بخش‌های برنامه',
                    ),
                    leading: Icon(
                      selectedId == option.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    trailing: selectedId == option.id
                        ? const Icon(Icons.check_circle_outline)
                        : null,
                    onTap: () => fontController.select(option.id),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'انتخاب شما ذخیره می‌شود و در اجرای بعدی برنامه نیز حفظ خواهد شد.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
