import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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


  final Widget body;
  final VoidCallback? onAdd;
  final VoidCallback? onMenu;
  final VoidCallback? onNotifications;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final svgColor = isDark
        ? theme.colorScheme.onSurface
        : colors.onSurface;
    final capsuleBackground = isDark
        ? theme.colorScheme.surfaceContainerLow
        : Color.alphaBlend(colors.primary.withAlpha(10), colors.surface);
    return Scaffold(
      backgroundColor: colors.surface,
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
                  Expanded(
                    child: Column(
                      children: [
                        DecoratedBox(
                          key: const ValueKey('home-bismillah-capsule-surface'),
                          decoration: BoxDecoration(
                            color: capsuleBackground,
                            borderRadius: const BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Semantics(
                              key: const ValueKey('home-bismillah-capsule'),
                              label: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              child: SvgPicture.asset(
                                'assets/images/branding/bismillah.svg',
                                key: const ValueKey('home-bismillah-svg'),
                                width: 52,
                                height: 30,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  svgColor,
                                  BlendMode.srcIn,
                                ),
                                excludeFromSemantics: true,
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
                            color: colors.onSurface,
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
                  fillColor: colors.surface,
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
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        onPressed: onAdd,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
