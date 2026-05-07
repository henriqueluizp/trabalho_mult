import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/entities/enums.dart';

class ItemCard extends StatelessWidget {
  final CollectionItem item;
  final VoidCallback? onTap;

  const ItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildImage(theme)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _StatusChip(status: item.status)),
                      const SizedBox(width: 4),
                      _RarityDot(rarity: item.rarity),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    if (item.imagePath != null) {
      final file = File(item.imagePath!);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(theme),
      );
    }
    return _imagePlaceholder(theme);
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: theme.colorScheme.outlineVariant,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ItemStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, label) = switch (status) {
      ItemStatus.owned => (Colors.green, status.label),
      ItemStatus.wishlist => (theme.colorScheme.primary, status.label),
      ItemStatus.sold => (Colors.red, status.label),
      ItemStatus.traded => (Colors.orange, status.label),
      ItemStatus.loaned => (Colors.purple, status.label),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RarityDot extends StatelessWidget {
  final ItemRarity rarity;
  const _RarityDot({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = switch (rarity) {
      ItemRarity.common => Colors.grey,
      ItemRarity.uncommon => Colors.blue,
      ItemRarity.rare => Colors.purple,
      ItemRarity.ultraRare => Colors.amber,
    };
    return Tooltip(
      message: rarity.label,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
