import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/finance_entities.dart';
import '../bloc/finance_cubits.dart';

const _colorPalette = <String>[
  'FF66BB6A',
  'FF42A5F5',
  'FFAB47BC',
  'FFFF7043',
  'FF26A69A',
  'FFFFCA28',
  'FFEF5350',
  'FF5C6BC0',
  'FF29B6F6',
  'FFEC407A',
  'FF78909C',
  'FF8D6E63',
];

Future<void> showCategoryManagerBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final h = MediaQuery.sizeOf(sheetContext).height;
      return SafeArea(
        child: SizedBox(
          height: h * 0.78,
          child: const _CategoryManagerPanel(),
        ),
      );
    },
  );
}

class _CategoryManagerPanel extends StatefulWidget {
  const _CategoryManagerPanel();

  @override
  State<_CategoryManagerPanel> createState() => _CategoryManagerPanelState();
}

class _CategoryManagerPanelState extends State<_CategoryManagerPanel> {
  TransactionType _filter = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriaCubit, CategoriaState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Categorias',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.revenue,
                    label: Text('Receitas'),
                    icon: Icon(Icons.trending_up),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Despesas'),
                    icon: Icon(Icons.trending_down),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (s) {
                  setState(() => _filter = s.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            if (state is CategoriaLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state is CategoriaError)
              Expanded(
                child: Center(child: Text(state.message)),
              )
            else if (state is CategoriaLoaded) ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: state.categorias
                      .where((c) => c.type == _filter)
                      .map(
                        (c) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                              int.parse('0x${c.colorArgbHex}'),
                            ),
                            radius: 10,
                          ),
                          title: Text(c.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _edit(context, c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(context, c),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state is CategoriaLoaded
                    ? () => _add(
                          context,
                          _filter,
                          state.categorias.where((c) => c.type == _filter).length,
                        )
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Nova categoria'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _add(
    BuildContext context,
    TransactionType type,
    int existingCount,
  ) async {
    final name = await _promptName(context, title: 'Nova categoria');
    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }
    final color = _colorPalette[existingCount % _colorPalette.length];
    await context.read<CategoriaCubit>().saveCategoria(
          MovementCategory(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: name.trim(),
            type: type,
            colorArgbHex: color,
          ),
        );
  }

  Future<void> _edit(BuildContext context, MovementCategory c) async {
    final name = await _promptName(context, title: 'Editar', initial: c.name);
    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }
    await context.read<CategoriaCubit>().saveCategoria(
          MovementCategory(
            id: c.id,
            name: name.trim(),
            type: c.type,
            colorArgbHex: c.colorArgbHex,
          ),
        );
  }

  Future<void> _confirmDelete(BuildContext context, MovementCategory c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text(
          'Os lançamentos em "${c.name}" ficarão sem categoria. Continuar?',
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
    if (ok == true && context.mounted) {
      await context.read<CategoriaCubit>().deleteCategoria(c.id);
    }
  }

  Future<String?> _promptName(
    BuildContext context, {
    required String title,
    String initial = '',
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}
