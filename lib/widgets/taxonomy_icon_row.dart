import 'package:flutter/material.dart';

import '../arvin_colors.dart';

/// Canonical compact visual row for the three taxonomy dimensions.
///
/// Project membership is supplied by the canonical ProjectPlan projection;
/// category and tags come from the canonical Task fields. This widget owns no
/// persistence or model and intentionally keeps the three icons adjacent in a
/// single RTL row.
class TaxonomyIconRow extends StatelessWidget {
  const TaxonomyIconRow({
    super.key,
    this.project,
    this.category,
    this.tags = const <String>[],
    this.maxTags = 2,
  });

  final String? project;
  final String? category;
  final List<String> tags;
  final int maxTags;

  @override
  Widget build(BuildContext context) {
    final normalizedProject = project?.trim();
    final normalizedCategory = category?.trim();
    final normalizedTags = tags
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .take(maxTags)
        .toList(growable: false);
    final children = <Widget>[
      if (normalizedProject?.isNotEmpty == true)
        _chip(
          key: const ValueKey('taxonomy-icon-row-project'),
          icon: Icons.folder_outlined,
          label: normalizedProject!,
          color: ArvinColors.project,
          softColor: ArvinColors.projectSoft,
        ),
      if (normalizedCategory?.isNotEmpty == true)
        _chip(
          key: const ValueKey('taxonomy-icon-row-category'),
          icon: Icons.grid_view_rounded,
          label: normalizedCategory!,
          color: ArvinColors.category,
          softColor: ArvinColors.categorySoft,
        ),
      for (final tag in normalizedTags)
        _chip(
          key: ValueKey('taxonomy-icon-row-tag-$tag'),
          icon: Icons.sell_outlined,
          label: '#$tag',
          color: ArvinColors.tag,
          softColor: ArvinColors.tagSoft,
        ),
    ];
    if (children.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        key: const ValueKey('taxonomy-icon-row'),
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            Flexible(child: children[index]),
          ],
        ],
      ),
    );
  }

  Widget _chip({
    required Key key,
    required IconData icon,
    required String label,
    required Color color,
    required Color softColor,
  }) {
    return Container(
      key: key,
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
