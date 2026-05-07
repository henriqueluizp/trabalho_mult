import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/collection_controller.dart';
import '../models/collection_item.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _currency(double v) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<CollectionController>().summary;
    final theme = Theme.of(context);

    if (s == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Painel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Resumo Geral', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SummaryCard(
              title: 'Total de Itens',
              value: s.total.toString(),
              icon: Icons.inventory_2_outlined,
              color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: SummaryCard(
                    title: 'Possuídos',
                    value: s.owned.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green)),
            const SizedBox(width: 8),
            Expanded(
                child: SummaryCard(
                    title: 'Lista de Desejos',
                    value: s.wishlist.toString(),
                    icon: Icons.favorite_outline,
                    color: theme.colorScheme.primary)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: SummaryCard(
                    title: 'Vendidos',
                    value: s.sold.toString(),
                    icon: Icons.sell_outlined,
                    color: Colors.red)),
            const SizedBox(width: 8),
            Expanded(
                child: SummaryCard(
                    title: 'Trocados',
                    value: s.traded.toString(),
                    icon: Icons.swap_horiz,
                    color: Colors.orange)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: SummaryCard(
                    title: 'Emprestados',
                    value: s.loaned.toString(),
                    icon: Icons.people_outline,
                    color: Colors.purple)),
            const SizedBox(width: 8),
            Expanded(
                child: SummaryCard(
                    title: 'Repetidos',
                    value: s.repeated.toString(),
                    icon: Icons.copy_outlined,
                    color: theme.colorScheme.error)),
          ]),
          const SizedBox(height: 20),
          Text('Valores', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SummaryCard(
              title: 'Total Pago',
              value: _currency(s.totalPaid),
              icon: Icons.payments_outlined,
              color: Colors.teal),
          const SizedBox(height: 8),
          SummaryCard(
              title: 'Total Estimado',
              value: _currency(s.totalEstimated),
              icon: Icons.trending_up,
              color: Colors.indigo),
          if (s.byCategory.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Por Categoria', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _CategoryChart(byCategory: s.byCategory),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<ItemCategory, int> byCategory;
  const _CategoryChart({required this.byCategory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value.toDouble();
    const colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.red, Colors.indigo, Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.map((e) {
            final color = colors[e.key.index % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.label, style: theme.textTheme.bodySmall),
                      Text('${e.value} itens',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / max,
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
