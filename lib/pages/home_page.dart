import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/collection_controller.dart';
import '../pages/login_page.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'item_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openFilters(CollectionController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => FilterBottomSheet(
        category: c.filterCategory,
        status: c.filterStatus,
        rarity: c.filterRarity,
        condition: c.filterCondition,
        onApply: (cat, sta, rar, con) =>
            c.setFilters(category: cat, status: sta, rarity: rar, condition: con),
      ),
    );
  }

  Future<void> _logout(CollectionController c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CollectionController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleção'),
        actions: [
          Stack(children: [
            IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Filtros',
                onPressed: () => _openFilters(c)),
            if (c.hasActiveFilters)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle),
                ),
              ),
          ]),
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _logout(c)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _search,
              hintText: 'Buscar itens...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_search.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _search.clear();
                      c.setSearch('');
                    },
                  ),
              ],
              onChanged: c.setSearch,
            ),
          ),
          if (c.hasActiveFilters) _ActiveFilters(controller: c),
          const SizedBox(height: 8),
          Expanded(child: _body(c)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ItemFormPage())),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }

  Widget _body(CollectionController c) {
    if (c.isLoading) return const Center(child: CircularProgressIndicator());
    if (c.error != null) {
      return Center(
          child: Text(c.error!,
              style: Theme.of(context).textTheme.bodyLarge));
    }
    if (c.items.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum item encontrado',
        subtitle: c.hasActiveFilters || c.searchQuery.isNotEmpty
            ? 'Tente ajustar os filtros.'
            : 'Adicione seu primeiro item!',
        onAction: c.hasActiveFilters || c.searchQuery.isNotEmpty
            ? null
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ItemFormPage())),
        actionLabel: 'Adicionar Item',
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 600 ? 3 : 2;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72),
        itemCount: c.items.length,
        itemBuilder: (context, i) => ItemCard(
          item: c.items[i],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => ItemDetailPage(item: c.items[i]))),
        ),
      );
    });
  }
}

class _ActiveFilters extends StatelessWidget {
  final CollectionController controller;
  const _ActiveFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (c.filterCategory != null)
              _chip(context, c.filterCategory!.label, () => c.setFilters(
                  status: c.filterStatus, rarity: c.filterRarity,
                  condition: c.filterCondition)),
            if (c.filterStatus != null)
              _chip(context, c.filterStatus!.label, () => c.setFilters(
                  category: c.filterCategory, rarity: c.filterRarity,
                  condition: c.filterCondition)),
            if (c.filterRarity != null)
              _chip(context, c.filterRarity!.label, () => c.setFilters(
                  category: c.filterCategory, status: c.filterStatus,
                  condition: c.filterCondition)),
            if (c.filterCondition != null)
              _chip(context, c.filterCondition!.label, () => c.setFilters(
                  category: c.filterCategory, status: c.filterStatus,
                  rarity: c.filterRarity)),
            TextButton.icon(
              onPressed: () => c.setFilters(clear: true),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Limpar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onDelete) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(label),
          onDeleted: onDelete,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      );
}
