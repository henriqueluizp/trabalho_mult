import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/collection_controller.dart';
import '../models/collection_item.dart';

class ItemFormPage extends StatefulWidget {
  final CollectionItem? item;
  const ItemFormPage({super.key, this.item});

  bool get isEditing => item != null;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _pago;
  late final TextEditingController _estimado;
  late final TextEditingController _local;
  late final TextEditingController _notas;

  late ItemCategory _categoria;
  late ItemStatus _status;
  late ItemRarity _raridade;
  ItemCondition? _condicao;
  bool _repetido = false;
  String? _imagePath;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nome = TextEditingController(text: i?.name);
    _pago = TextEditingController(text: i?.paidValue?.toStringAsFixed(2));
    _estimado =
        TextEditingController(text: i?.estimatedValue?.toStringAsFixed(2));
    _local = TextEditingController(text: i?.location);
    _notas = TextEditingController(text: i?.notes);
    _categoria = i?.category ?? ItemCategory.other;
    _status = i?.status ?? ItemStatus.owned;
    _raridade = i?.rarity ?? ItemRarity.common;
    _condicao = i?.condition;
    _repetido = i?.isRepeated ?? false;
    _imagePath = i?.imagePath;
  }

  @override
  void dispose() {
    _nome.dispose();
    _pago.dispose();
    _estimado.dispose();
    _local.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Selecionar imagem'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      ),
    );
    if (source == null) return;
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    await imagesDir.create(recursive: true);
    final ext = p.extension(picked.path);
    final saved =
        await File(picked.path).copy('${imagesDir.path}/${const Uuid().v4()}$ext');
    if (mounted) setState(() => _imagePath = saved.path);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final c = context.read<CollectionController>();
    final now = DateTime.now();
    final item = CollectionItem(
      id: widget.item?.id ?? const Uuid().v4(),
      userId: widget.item?.userId ?? c.currentUserId!,
      name: _nome.text.trim(),
      category: _categoria,
      status: _status,
      rarity: _raridade,
      condition: _condicao,
      paidValue: _pago.text.isNotEmpty
          ? double.tryParse(_pago.text.replaceAll(',', '.'))
          : null,
      estimatedValue: _estimado.text.isNotEmpty
          ? double.tryParse(_estimado.text.replaceAll(',', '.'))
          : null,
      location: _local.text.trim().isEmpty ? null : _local.text.trim(),
      notes: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      isRepeated: _repetido,
      imagePath: _imagePath,
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: widget.isEditing ? now : null,
    );

    try {
      if (widget.isEditing) {
        await c.updateItem(item);
      } else {
        await c.addItem(item);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Item' : 'Adicionar Item'),
        actions: [
          if (_salvando)
            const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _salvar, child: const Text('Salvar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seletor de imagem
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: theme.colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagePath != null
                    ? Stack(fit: StackFit.expand, children: [
                        Image.file(File(_imagePath!), fit: BoxFit.cover),
                        Positioned(
                          bottom: 8, right: 8,
                          child: FilledButton.tonalIcon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Alterar'),
                          ),
                        ),
                      ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text('Adicionar Imagem',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.label_outline)),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 12),
            _dropdown<ItemCategory>(
                'Categoria', _categoria, ItemCategory.values,
                (e) => e.label, Icons.category_outlined,
                (v) => setState(() => _categoria = v!)),
            const SizedBox(height: 12),
            _dropdown<ItemStatus>('Status', _status, ItemStatus.values,
                (e) => e.label, Icons.swap_horiz_outlined,
                (v) => setState(() => _status = v!)),
            const SizedBox(height: 12),
            _dropdown<ItemRarity>(
                'Raridade', _raridade, ItemRarity.values,
                (e) => e.label, Icons.star_outline,
                (v) => setState(() => _raridade = v!)),
            const SizedBox(height: 12),
            _dropdownNullable<ItemCondition>(
                'Estado de Conservação', _condicao, ItemCondition.values,
                (e) => e.label, Icons.shield_outlined,
                (v) => setState(() => _condicao = v)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _pago,
                  decoration: const InputDecoration(
                      labelText: 'Valor Pago (R\$)',
                      prefixIcon: Icon(Icons.payments_outlined)),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _estimado,
                  decoration: const InputDecoration(
                      labelText: 'Valor Estimado (R\$)',
                      prefixIcon: Icon(Icons.trending_up_outlined)),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _local,
              decoration: const InputDecoration(
                  labelText: 'Local de Armazenamento',
                  prefixIcon: Icon(Icons.place_outlined)),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notas,
              decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Item Repetido'),
              value: _repetido,
              onChanged: (v) => setState(() => _repetido = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child:
                  Text(widget.isEditing ? 'Salvar' : 'Adicionar Item'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>(String label, T value, List<T> items,
      String Function(T) toLabel, IconData icon,
      void Function(T?) onChange) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration:
          InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: items
          .map((e) =>
              DropdownMenuItem(value: e, child: Text(toLabel(e))))
          .toList(),
      onChanged: onChange,
    );
  }

  Widget _dropdownNullable<T>(String label, T? value, List<T> items,
      String Function(T) toLabel, IconData icon,
      void Function(T?) onChange) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration:
          InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        const DropdownMenuItem(child: Text('Não informado')),
        ...items.map(
            (e) => DropdownMenuItem(value: e, child: Text(toLabel(e)))),
      ],
      onChanged: onChange,
    );
  }
}
