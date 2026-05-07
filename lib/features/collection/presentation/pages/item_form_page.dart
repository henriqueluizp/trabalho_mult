import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/image_helper.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/entities/enums.dart';
import '../controllers/collection_controller.dart';

class ItemFormPage extends StatefulWidget {
  final CollectionItem? item;

  const ItemFormPage({super.key, this.item});

  bool get isEditing => item != null;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _estimatedCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;

  late ItemCategory _category;
  late ItemStatus _status;
  late ItemRarity _rarity;
  ItemCondition? _condition;
  bool _isRepeated = false;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name);
    _paidCtrl = TextEditingController(
      text: item?.paidValue?.toStringAsFixed(2),
    );
    _estimatedCtrl = TextEditingController(
      text: item?.estimatedValue?.toStringAsFixed(2),
    );
    _locationCtrl = TextEditingController(text: item?.location);
    _notesCtrl = TextEditingController(text: item?.notes);
    _category = item?.category ?? ItemCategory.other;
    _status = item?.status ?? ItemStatus.owned;
    _rarity = item?.rarity ?? ItemRarity.common;
    _condition = item?.condition;
    _isRepeated = item?.isRepeated ?? false;
    _imagePath = item?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _paidCtrl.dispose();
    _estimatedCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (_) => _ImageSourceDialog(),
    );
    if (result == null) return;

    final path = result == ImageSource.gallery
        ? await ImageHelper.pickFromGallery()
        : await ImageHelper.pickFromCamera();

    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final paidValue = _paidCtrl.text.isNotEmpty
        ? double.tryParse(_paidCtrl.text.replaceAll(',', '.'))
        : null;
    final estimatedValue = _estimatedCtrl.text.isNotEmpty
        ? double.tryParse(_estimatedCtrl.text.replaceAll(',', '.'))
        : null;

    final now = DateTime.now();
    final controller = context.read<CollectionController>();

    final newItem = CollectionItem(
      id: widget.item?.id ?? const Uuid().v4(),
      userId: widget.item?.userId ?? controller.currentUserId!,
      name: _nameCtrl.text.trim(),
      category: _category,
      status: _status,
      rarity: _rarity,
      condition: _condition,
      paidValue: paidValue,
      estimatedValue: estimatedValue,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      isRepeated: _isRepeated,
      imagePath: _imagePath,
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: widget.isEditing ? now : null,
    );

    try {
      if (widget.isEditing) {
        await controller.updateItem(newItem);
      } else {
        await controller.addItem(newItem);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Item' : 'Adicionar Item'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(theme),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null,
            ),
            const SizedBox(height: 12),
            _DropdownField<ItemCategory>(
              label: 'Categoria',
              value: _category,
              items: ItemCategory.values,
              itemLabel: (e) => e.label,
              onChanged: (v) => setState(() => _category = v!),
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _DropdownField<ItemStatus>(
              label: 'Status',
              value: _status,
              items: ItemStatus.values,
              itemLabel: (e) => e.label,
              onChanged: (v) => setState(() => _status = v!),
              icon: Icons.swap_horiz_outlined,
            ),
            const SizedBox(height: 12),
            _DropdownField<ItemRarity>(
              label: 'Raridade',
              value: _rarity,
              items: ItemRarity.values,
              itemLabel: (e) => e.label,
              onChanged: (v) => setState(() => _rarity = v!),
              icon: Icons.star_outline,
            ),
            const SizedBox(height: 12),
            _NullableDropdownField<ItemCondition>(
              label: 'Estado de Conservação',
              value: _condition,
              items: ItemCondition.values,
              itemLabel: (e) => e.label,
              onChanged: (v) => setState(() => _condition = v),
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _paidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Valor Pago (R\$)',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _estimatedCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Valor Estimado (R\$)',
                      prefixIcon: Icon(Icons.trending_up_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Local de Armazenamento',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Observações',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Item Repetido'),
              subtitle: const Text('Marcar se este item está duplicado na coleção'),
              value: _isRepeated,
              onChanged: (v) => setState(() => _isRepeated = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(widget.isEditing ? 'Salvar' : 'Adicionar Item'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_imagePath!), fit: BoxFit.cover),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FilledButton.tonalIcon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Alterar Imagem'),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicionar Imagem',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final IconData icon;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _NullableDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final IconData icon;

  const _NullableDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: [
        const DropdownMenuItem(child: Text('Não informado')),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e)))),
      ],
      onChanged: onChanged,
    );
  }
}

class _ImageSourceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar imagem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Galeria'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Câmera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
