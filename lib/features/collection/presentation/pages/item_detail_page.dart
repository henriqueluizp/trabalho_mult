import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/entities/enums.dart';
import '../controllers/collection_controller.dart';
import 'item_form_page.dart';

class ItemDetailPage extends StatelessWidget {
  final CollectionItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<CollectionController>();
    // Só o dono do item pode editar ou excluir
    final isOwner = item.userId == controller.currentUserId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemFormPage(item: item),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.imagePath != null
                  ? Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildImagePlaceholder(theme),
                    )
                  : _buildImagePlaceholder(theme),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    if (item.isRepeated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Repetido',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _statusChip(context, item.status),
                    _rarityChip(context, item.rarity),
                    Chip(label: Text(item.category.label)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                _DetailSection(
                  children: [
                    if (item.condition != null)
                      _DetailRow(
                        icon: Icons.shield_outlined,
                        label: 'Estado de Conservação',
                        value: item.condition!.label,
                      ),
                    if (item.paidValue != null)
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Valor Pago',
                        value: Formatters.currency(item.paidValue!),
                      ),
                    if (item.estimatedValue != null)
                      _DetailRow(
                        icon: Icons.trending_up_outlined,
                        label: 'Valor Estimado',
                        value: Formatters.currency(item.estimatedValue!),
                      ),
                    if (item.location != null)
                      _DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Local de Armazenamento',
                        value: item.location!,
                      ),
                    if (item.notes != null)
                      _DetailRow(
                        icon: Icons.notes_outlined,
                        label: 'Observações',
                        value: item.notes!,
                      ),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Adicionado em',
                      value: Formatters.date(item.createdAt),
                    ),
                    if (item.updatedAt != null)
                      _DetailRow(
                        icon: Icons.update_outlined,
                        label: 'Atualizado em',
                        value: Formatters.date(item.updatedAt!),
                      ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: 72,
        color: theme.colorScheme.outlineVariant,
      ),
    );
  }

  Widget _statusChip(BuildContext context, ItemStatus status) {
    final theme = Theme.of(context);
    final color = switch (status) {
      ItemStatus.owned => Colors.green,
      ItemStatus.wishlist => theme.colorScheme.primary,
      ItemStatus.sold => Colors.red,
      ItemStatus.traded => Colors.orange,
      ItemStatus.loaned => Colors.purple,
    };
    return Chip(
      label: Text(status.label),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _rarityChip(BuildContext context, ItemRarity rarity) {
    final color = switch (rarity) {
      ItemRarity.common => Colors.grey,
      ItemRarity.uncommon => Colors.blue,
      ItemRarity.rare => Colors.purple,
      ItemRarity.ultraRare => Colors.amber,
    };
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(rarity.label),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Deseja realmente excluir este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CollectionController>().deleteItem(item.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DetailSection extends StatelessWidget {
  final List<Widget> children;
  const _DetailSection({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((w) => [w, const SizedBox(height: 12)])
          .toList()
        ..removeLast(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
