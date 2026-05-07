import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/collection_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/item_card.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import 'item_detail_page.dart';
import 'item_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirFiltros(CollectionController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FilterBottomSheet(
        selectedCategory: controller.filterCategory,
        selectedStatus: controller.filterStatus,
        selectedRarity: controller.filterRarity,
        selectedCondition: controller.filterCondition,
        onApply: (category, status, rarity, condition) => controller.setFilters(
          category: category,
          status: status,
          rarity: rarity,
          condition: condition,
        ),
      ),
    );
  }

  void _abrirAdicionarItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ItemFormPage()),
    );
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CollectionController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleção'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _abrirFiltros(controller),
                tooltip: 'Filtros',
              ),
              // Ponto vermelho indicando filtro ativo
              if (controller.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _sair,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar itens...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      controller.setSearchQuery('');
                    },
                  ),
              ],
              onChanged: controller.setSearchQuery,
            ),
          ),
          if (controller.hasActiveFilters)
            _BarraFiltrosAtivos(controller: controller),
          const SizedBox(height: 8),
          Expanded(child: _construirCorpo(controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirAdicionarItem,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Item'),
      ),
    );
  }

  Widget _construirCorpo(CollectionController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(
        child: Text(
          controller.error!,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    if (controller.items.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum item encontrado',
        subtitle:
            controller.hasActiveFilters || controller.searchQuery.isNotEmpty
            ? 'Tente ajustar os filtros ou a busca.'
            : 'Adicione seu primeiro item à coleção!',
        icon: Icons.inventory_2_outlined,
        onAction:
            controller.hasActiveFilters || controller.searchQuery.isNotEmpty
            ? null
            : _abrirAdicionarItem,
        actionLabel: 'Adicionar Item',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return ItemCard(
              item: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
              ),
            );
          },
        );
      },
    );
  }
}

class _BarraFiltrosAtivos extends StatelessWidget {
  final CollectionController controller;
  const _BarraFiltrosAtivos({required this.controller});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (controller.filterCategory != null) {
      chips.add(
        _chip(
          context,
          controller.filterCategory!.label,
          () => controller.setFilters(
            status: controller.filterStatus,
            rarity: controller.filterRarity,
            condition: controller.filterCondition,
          ),
        ),
      );
    }
    if (controller.filterStatus != null) {
      chips.add(
        _chip(
          context,
          controller.filterStatus!.label,
          () => controller.setFilters(
            category: controller.filterCategory,
            rarity: controller.filterRarity,
            condition: controller.filterCondition,
          ),
        ),
      );
    }
    if (controller.filterRarity != null) {
      chips.add(
        _chip(
          context,
          controller.filterRarity!.label,
          () => controller.setFilters(
            category: controller.filterCategory,
            status: controller.filterStatus,
            condition: controller.filterCondition,
          ),
        ),
      );
    }
    if (controller.filterCondition != null) {
      chips.add(
        _chip(
          context,
          controller.filterCondition!.label,
          () => controller.setFilters(
            category: controller.filterCategory,
            status: controller.filterStatus,
            rarity: controller.filterRarity,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips,
            TextButton.icon(
              onPressed: () => controller.setFilters(clear: true),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback aoRemover) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: aoRemover,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
