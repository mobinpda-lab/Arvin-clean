import 'package:flutter/material.dart';

/// Reusable presentation shell matching the owner-approved Arvin Home contract.
///
/// This widget owns no data or persistence. The real Home route supplies its
/// existing task widgets and callbacks so this shell can be integrated without
/// introducing a second Task/FollowUp model.
class HomeVisualIntegration extends StatelessWidget {
  const HomeVisualIntegration({
    super.key,
    required this.body,
    this.onAdd,
    this.onMenu,
    this.onNotifications,
    this.searchHint = 'جست‌وجو در کارها',
  });

  static const primary = Color(0xFF4A4CAB);
  static const background = Color(0xFFF8F8FB);
  static const surface = Color(0xFFFDFDFE);
  static const border = Color(0xFFE5E7ED);
  static const textPrimary = Color(0xFF232433);
  static const textSecondary = Color(0xFF80829C);

  final Widget body;
  final VoidCallback? onAdd;
  final VoidCallback? onMenu;
  final VoidCallback? onNotifications;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    key: const ValueKey('home-notifications'),
                    tooltip: 'اعلان‌ها',
                    onPressed: onNotifications,
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F0F6),
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              'بسم الله الرحمن الرحیم',
                              key: ValueKey('home-bismillah-capsule'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'مدیریت کارها و پیگیری آروین',
                          key: ValueKey('home-product-title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('home-menu'),
                    tooltip: 'منو',
                    onPressed: onMenu,
                    icon: const Icon(Icons.menu_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                key: const ValueKey('home-canonical-search'),
                decoration: InputDecoration(
                  hintText: searchHint,
                  hintStyle: const TextStyle(color: textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: primary, width: 1.4),
                  ),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('home-canonical-add'),
        tooltip: 'افزودن کار جدید',
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: onAdd,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
