import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/finance_entities.dart';
import '../bloc/finance_cubits.dart';

/// Abre edição de um lançamento existente. Retorna `true` se salvou ou excluiu.
Future<bool?> showEditTransactionBottomSheet(
  BuildContext context, {
  required Transaction transaction,
  required List<MovementCategory> categories,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _EditTransactionSheet(
          initial: transaction,
          categories: categories,
        ),
      );
    },
  );
}

class _EditTransactionSheet extends StatefulWidget {
  const _EditTransactionSheet({
    required this.initial,
    required this.categories,
  });

  final Transaction initial;
  final List<MovementCategory> categories;

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _descriptionController = TextEditingController(text: t.description);
    _valueController = TextEditingController(
      text: _formatValueForField(t.value),
    );
    _selectedDate = t.date;
    _selectedType = t.type;
    _categoryId = t.categoryId;
  }

  String _formatValueForField(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    return v.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _save() async {
    final description = _descriptionController.text.trim();
    final parsed =
        double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0;
    if (description.isEmpty || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe descrição e valor maior que zero.'),
        ),
      );
      return;
    }

    final updated = Transaction(
      id: widget.initial.id,
      description: description,
      value: parsed,
      date: _selectedDate,
      type: _selectedType,
      accountId: widget.initial.accountId,
      categoryId: _categoryId,
    );

    await context.read<LancamentoCubit>().addLancamento(updated);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir movimentação'),
        content: const Text(
          'Esta ação não pode ser desfeita. Deseja excluir este lançamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<LancamentoCubit>().deleteLancamento(widget.initial.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final typeCategories =
        widget.categories.where((c) => c.type == _selectedType).toList();
    final categoryItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Sem categoria'),
      ),
      ...typeCategories.map(
        (c) => DropdownMenuItem<String?>(
          value: c.id,
          child: Text(c.name),
        ),
      ),
    ];
    final categoryValue = (_categoryId != null &&
            typeCategories.any((c) => c.id == _categoryId))
        ? _categoryId
        : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar movimentação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TransactionType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TransactionType.revenue,
                        child: Text('Receita'),
                      ),
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Despesa'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedType = v;
                          _categoryId = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(dateLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: categoryValue,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: categoryItems,
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar alterações'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir lançamento'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
