// Bottom sheet de filtros.
// Exibe opções de filtro por Categoria, Status, Raridade e Estado de Conservação.
// O usuário pode selecionar um ou mais filtros e aplicar ou limpar todos.

import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

class FilterBottomSheet extends StatefulWidget {
  // Filtros atualmente ativos (recebidos da tela anterior)
  final ItemCategory? selectedCategory;
  final ItemStatus? selectedStatus;
  final ItemRarity? selectedRarity;
  final ItemCondition? selectedCondition;

  // Callback chamado quando o usuário clica em "Aplicar"
  final void Function(
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
  ) onApply;

  const FilterBottomSheet({
    super.key,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedRarity,
    this.selectedCondition,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Estado local dos filtros selecionados (cópia dos valores recebidos)
  ItemCategory? _category;
  ItemStatus? _status;
  ItemRarity? _rarity;
  ItemCondition? _condition;

  @override
  void initState() {
    super.initState();
    // Inicializa com os filtros que já estavam ativos
    _category = widget.selectedCategory;
    _status = widget.selectedStatus;
    _rarity = widget.selectedRarity;
    _condition = widget.selectedCondition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 8),
            // Barra indicadora de arrasto
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filtros', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            // --- Filtro por Categoria ---
            Text('Categoria', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipsDeSelecao<ItemCategory>(
              itens: ItemCategory.values,
              selecionado: _category,
              rotulo: (e) => e.label,
              aoSelecionar: (e) =>
                  setState(() => _category = _category == e ? null : e),
            ),
            const SizedBox(height: 16),

            // --- Filtro por Status ---
            Text('Status', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipsDeSelecao<ItemStatus>(
              itens: ItemStatus.values,
              selecionado: _status,
              rotulo: (e) => e.label,
              aoSelecionar: (e) =>
                  setState(() => _status = _status == e ? null : e),
            ),
            const SizedBox(height: 16),

            // --- Filtro por Raridade ---
            Text('Raridade', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipsDeSelecao<ItemRarity>(
              itens: ItemRarity.values,
              selecionado: _rarity,
              rotulo: (e) => e.label,
              aoSelecionar: (e) =>
                  setState(() => _rarity = _rarity == e ? null : e),
            ),
            const SizedBox(height: 16),

            // --- Filtro por Estado de Conservação ---
            Text('Estado de Conservação', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _ChipsDeSelecao<ItemCondition>(
              itens: ItemCondition.values,
              selecionado: _condition,
              rotulo: (e) => e.label,
              aoSelecionar: (e) =>
                  setState(() => _condition = _condition == e ? null : e),
            ),
            const SizedBox(height: 24),

            // Botões de ação: Limpar e Aplicar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _category = null;
                      _status = null;
                      _rarity = null;
                      _condition = null;
                    }),
                    child: const Text('Limpar Filtros'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // Envia os filtros selecionados de volta para a tela
                      widget.onApply(_category, _status, _rarity, _condition);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizável que exibe um grupo de chips para seleção única
class _ChipsDeSelecao<T> extends StatelessWidget {
  final List<T> itens;
  final T? selecionado;
  final String Function(T) rotulo;
  final void Function(T) aoSelecionar;

  const _ChipsDeSelecao({
    required this.itens,
    required this.selecionado,
    required this.rotulo,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: itens
          .map(
            (e) => FilterChip(
              label: Text(rotulo(e)),
              selected: selecionado == e,
              onSelected: (_) => aoSelecionar(e),
            ),
          )
          .toList(),
    );
  }
}
