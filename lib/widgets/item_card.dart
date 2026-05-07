import 'dart:io';
import 'package:flutter/material.dart';
import '../models/collection_item.dart';

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
            Expanded(child: _imagem(theme)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.category.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _statusChip(context)),
                      const SizedBox(width: 4),
                      _raridadeDot(),
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

  Widget _imagem(ThemeData theme) {
    if (item.imagePath != null) {
      return Image.file(File(item.imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(theme));
    }
    return _placeholder(theme);
  }

  Widget _placeholder(ThemeData theme) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            size: 40, color: theme.colorScheme.outlineVariant),
      );

  Widget _statusChip(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (item.status) {
      ItemStatus.owned => Colors.green,
      ItemStatus.wishlist => theme.colorScheme.primary,
      ItemStatus.sold => Colors.red,
      ItemStatus.traded => Colors.orange,
      ItemStatus.loaned => Colors.purple,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(item.status.label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color),
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _raridadeDot() {
    final color = switch (item.rarity) {
      ItemRarity.common => Colors.grey,
      ItemRarity.uncommon => Colors.blue,
      ItemRarity.rare => Colors.purple,
      ItemRarity.ultraRare => Colors.amber,
    };
    return Tooltip(
      message: item.rarity.label,
      child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}
