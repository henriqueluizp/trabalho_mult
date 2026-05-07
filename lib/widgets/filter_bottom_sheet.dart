import 'package:flutter/material.dart';
import '../models/collection_item.dart';

class FilterBottomSheet extends StatefulWidget {
  final ItemCategory? category;
  final ItemStatus? status;
  final ItemRarity? rarity;
  final ItemCondition? condition;
  final void Function(
      ItemCategory?, ItemStatus?, ItemRarity?, ItemCondition?) onApply;

  const FilterBottomSheet({
    super.key,
    this.category,
    this.status,
    this.rarity,
    this.condition,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  ItemCategory? _cat;
  ItemStatus? _sta;
  ItemRarity? _rar;
  ItemCondition? _con;

  @override
  void initState() {
    super.initState();
    _cat = widget.category;
    _sta = widget.status;
    _rar = widget.rarity;
    _con = widget.condition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('Filtros', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _grupo('Categoria', ItemCategory.values, _cat, (e) => e.label,
              (e) => setState(() => _cat = _cat == e ? null : e)),
          _grupo('Status', ItemStatus.values, _sta, (e) => e.label,
              (e) => setState(() => _sta = _sta == e ? null : e)),
          _grupo('Raridade', ItemRarity.values, _rar, (e) => e.label,
              (e) => setState(() => _rar = _rar == e ? null : e)),
          _grupo('Estado de Conservação', ItemCondition.values, _con,
              (e) => e.label,
              (e) => setState(() => _con = _con == e ? null : e)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _cat = null; _sta = null; _rar = null; _con = null;
                }),
                child: const Text('Limpar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_cat, _sta, _rar, _con);
                  Navigator.pop(context);
                },
                child: const Text('Aplicar'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _grupo<T>(String titulo, List<T> itens, T? selecionado,
      String Function(T) label, void Function(T) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 4,
          children: itens.map((e) => FilterChip(
            label: Text(label(e)),
            selected: selecionado == e,
            onSelected: (_) => onTap(e),
          )).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
