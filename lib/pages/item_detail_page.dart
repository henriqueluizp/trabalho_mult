import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/collection_controller.dart';
import '../models/collection_item.dart';
import 'item_form_page.dart';

class ItemDetailPage extends StatelessWidget {
  final CollectionItem item;
  const ItemDetailPage({super.key, required this.item});

  String _currency(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  String _date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<CollectionController>();
    final isOwner = item.userId == controller.currentUserId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) => ItemFormPage(item: item))),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                  onPressed: () => _excluir(context, controller),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item.imagePath != null
                  ? Image.file(File(item.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme))
                  : _placeholder(theme),
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
                        child: Text(item.name,
                            style: theme.textTheme.headlineSmall)),
                    if (item.isRepeated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('Repetido',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    theme.colorScheme.onErrorContainer)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  _statusChip(context),
                  _rarityChip(context),
                  Chip(label: Text(item.category.label)),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (item.condition != null)
                  _linha(context, Icons.shield_outlined,
                      'Estado de Conservação', item.condition!.label),
                if (item.paidValue != null)
                  _linha(context, Icons.payments_outlined, 'Valor Pago',
                      _currency(item.paidValue!)),
                if (item.estimatedValue != null)
                  _linha(context, Icons.trending_up_outlined,
                      'Valor Estimado', _currency(item.estimatedValue!)),
                if (item.location != null)
                  _linha(context, Icons.place_outlined,
                      'Local de Armazenamento', item.location!),
                if (item.notes != null)
                  _linha(context, Icons.notes_outlined, 'Observações',
                      item.notes!),
                _linha(context, Icons.calendar_today_outlined,
                    'Adicionado em', _date(item.createdAt)),
                if (item.updatedAt != null)
                  _linha(context, Icons.update_outlined, 'Atualizado em',
                      _date(item.updatedAt!)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            size: 72, color: theme.colorScheme.outlineVariant),
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
    return Chip(
      label: Text(item.status.label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _rarityChip(BuildContext context) {
    final color = switch (item.rarity) {
      ItemRarity.common => Colors.grey,
      ItemRarity.uncommon => Colors.blue,
      ItemRarity.rare => Colors.purple,
      ItemRarity.ultraRare => Colors.amber,
    };
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(item.rarity.label),
    );
  }

  Widget _linha(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _excluir(
      BuildContext context, CollectionController controller) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Deseja realmente excluir este item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await controller.deleteItem(item.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
