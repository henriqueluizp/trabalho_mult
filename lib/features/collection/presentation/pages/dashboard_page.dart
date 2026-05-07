import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/collection_summary.dart';
import '../../domain/entities/enums.dart';
import '../controllers/collection_controller.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CollectionController>();
    final summary = controller.summary;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Painel')),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.loadSummary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Resumo Geral', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SummaryCard(
                    title: 'Total de Itens',
                    value: summary.totalItems.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Possuídos',
                          value: summary.ownedItems.toString(),
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Lista de Desejos',
                          value: summary.wishlistItems.toString(),
                          icon: Icons.favorite_outline,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Vendidos',
                          value: summary.soldItems.toString(),
                          icon: Icons.sell_outlined,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Trocados',
                          value: summary.tradedItems.toString(),
                          icon: Icons.swap_horiz,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Emprestados',
                          value: summary.loanedItems.toString(),
                          icon: Icons.people_outline,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          title: 'Repetidos',
                          value: summary.repeatedItems.toString(),
                          icon: Icons.copy_outlined,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Valores', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SummaryCard(
                    title: 'Total Pago',
                    value: Formatters.currency(summary.totalPaidValue),
                    icon: Icons.payments_outlined,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: 'Total Estimado',
                    value: Formatters.currency(summary.totalEstimatedValue),
                    icon: Icons.trending_up,
                    color: Colors.indigo,
                  ),
                  if (summary.itemsByCategory.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Por Categoria', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _CategoryChart(summary: summary),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final CollectionSummary summary;
  const _CategoryChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = summary.itemsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.map((entry) {
            final fraction = entry.value / max;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key.label, style: theme.textTheme.bodySmall),
                      Text(
                        '${entry.value} itens',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _categoryColor(entry.key),
                      ),
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

  Color _categoryColor(ItemCategory cat) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[cat.index % colors.length];
  }
}
