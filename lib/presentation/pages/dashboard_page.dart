import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../application/usecases/analytics_usecases.dart';
import '../../core/network_connectivity.dart';
import '../../infrastructure/services/biometric_lock_service.dart';
import '../../application/usecases/cloud_sync_usecases.dart';
import '../../domain/entities/finance_entities.dart';
import '../bloc/finance_cubits.dart';
import '../widgets/analytics_widgets.dart';
import '../widgets/category_manager_sheet.dart';
import '../widgets/edit_transaction_sheet.dart';

class DashboardPage extends StatefulWidget {
  final UserSession session;
  final BackupFinanceSnapshotUseCase backupFinanceSnapshotUseCase;
  final BuildFinanceSummaryUseCase buildFinanceSummaryUseCase;
  final GenerateInvestmentAdvisorReportUseCase
  generateInvestmentAdvisorReportUseCase;

  const DashboardPage({
    super.key,
    required this.session,
    required this.backupFinanceSnapshotUseCase,
    required this.buildFinanceSummaryUseCase,
    required this.generateInvestmentAdvisorReportUseCase,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  bool get _isDeviceLocalSession =>
      widget.session.authProvider == AuthProvider.deviceLocal;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  bool _isSavingTransaction = false;
  bool _isBackingUp = false;
  bool _isGeneratingReport = false;

  InvestmentAdvisorReport? _advisorReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<LancamentoCubit>().loadLancamentos();
    context.read<ContaCubit>().loadContas();
    context.read<CategoriaCubit>().loadCategorias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveTransaction() async {
    if (_isSavingTransaction) {
      return;
    }

    final description = _descriptionController.text.trim();
    final parsedValue =
        double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0;

    if (description.isEmpty || parsedValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe descrição e valor maior que zero.'),
        ),
      );
      return;
    }

    setState(() => _isSavingTransaction = true);

    try {
      await _ensureDefaultAccount();
      if (!mounted) {
        return;
      }

      final tx = Transaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        description: description,
        value: parsedValue,
        date: _selectedDate,
        type: _selectedType,
        accountId: _defaultAccountId,
        categoryId: _selectedCategoryId,
      );

      await context.read<LancamentoCubit>().addLancamento(tx);

      _descriptionController.clear();
      _valueController.clear();
      _selectedDate = DateTime.now();
      _selectedType = TransactionType.expense;

      if (mounted) {
        setState(() {
          _advisorReport = null;
          _selectedCategoryId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar movimentação: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingTransaction = false);
      }
    }
  }

  Future<void> _openEditTransaction(
    Transaction transaction,
    List<MovementCategory> categories,
  ) async {
    final changed = await showEditTransactionBottomSheet(
      context,
      transaction: transaction,
      categories: categories,
    );
    if (changed == true && mounted) {
      setState(() => _advisorReport = null);
    }
  }

  Future<void> _ensureDefaultAccount() async {
    final contaCubit = context.read<ContaCubit>();
    final state = contaCubit.state;
    if (state is ContaLoaded) {
      final hasDefault = state.contas.any((conta) => conta.id == _defaultAccountId);
      if (!hasDefault) {
        await contaCubit.addConta(
          Conta(id: _defaultAccountId, name: 'Conta Principal', currency: 0),
        );
      }
      return;
    }

    await contaCubit.loadContas();
    final refreshedState = contaCubit.state;
    if (refreshedState is ContaLoaded) {
      final hasDefault =
          refreshedState.contas.any((conta) => conta.id == _defaultAccountId);
      if (!hasDefault) {
        await contaCubit.addConta(
          Conta(id: _defaultAccountId, name: 'Conta Principal', currency: 0),
        );
      }
    }
  }

  Future<void> _backupSnapshot() async {
    if (_isBackingUp) {
      return;
    }
    if (_isDeviceLocalSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backup na nuvem não está disponível no login só aparelho.',
          ),
        ),
      );
      return;
    }

    setState(() => _isBackingUp = true);
    try {
      await assertDeviceOnline();
      await widget.backupFinanceSnapshotUseCase(widget.session);
      if (mounted) {
        final msg = switch (widget.session.authProvider) {
          AuthProvider.gmail => 'Backup enviado para Google Drive.',
          AuthProvider.outlook => 'Backup enviado para OneDrive.',
          AuthProvider.deviceLocal => 'Backup enviado.',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no backup: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _generateReport(List<Transaction> transactions) async {
    setState(() => _isGeneratingReport = true);
    try {
      final summary = widget.buildFinanceSummaryUseCase(
        transactions,
        chartPeriod: const AnalyticsLastMonths(6),
      );
      final report = await widget.generateInvestmentAdvisorReportUseCase(
        summary: summary,
        transactions: transactions,
      );
      if (mounted) {
        setState(() => _advisorReport = report);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao gerar relatório: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  List<Transaction> _transactionsFromState(LancamentoState state) {
    if (state is LancamentoLoaded) {
      return state.lancamentos;
    }
    return const <Transaction>[];
  }

  @override
  Widget build(BuildContext context) {
    final providerLabel = switch (widget.session.authProvider) {
      AuthProvider.gmail => 'Gmail -> Google Drive',
      AuthProvider.outlook => 'Outlook -> OneDrive',
      AuthProvider.deviceLocal => 'Só aparelho (testes)',
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Financeiro'),
            Text(
              '${widget.session.displayName} | $providerLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (_isBackingUp || _isDeviceLocalSession)
                ? null
                : _backupSnapshot,
            icon: _isBackingUp
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            tooltip: _isDeviceLocalSession
                ? 'Backup na nuvem indisponível neste modo'
                : 'Fazer backup',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.swap_horiz), text: 'Movimentações'),
            Tab(icon: Icon(Icons.query_stats), text: 'Gráficos'),
            Tab(icon: Icon(Icons.assistant), text: 'IA Investimentos'),
            Tab(icon: Icon(Icons.cloud_sync), text: 'Nuvem'),
          ],
        ),
      ),
      body: BlocBuilder<CategoriaCubit, CategoriaState>(
        builder: (context, categoriaState) {
          final categories = categoriaState is CategoriaLoaded
              ? categoriaState.categorias
              : const <MovementCategory>[];
          return BlocBuilder<LancamentoCubit, LancamentoState>(
            builder: (context, lancamentoState) {
              final transactions = _transactionsFromState(lancamentoState);

              return TabBarView(
                controller: _tabController,
                children: [
                  _MovementsTab(
                    state: lancamentoState,
                    transactions: transactions,
                    categories: categories,
                    descriptionController: _descriptionController,
                    valueController: _valueController,
                    selectedDate: _selectedDate,
                    selectedType: _selectedType,
                    selectedCategoryId: _selectedCategoryId,
                    onDateTap: _pickDate,
                    onTypeChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          _selectedCategoryId = null;
                        });
                      }
                    },
                    onCategoryChanged: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                    onSaveTap: _isSavingTransaction ? null : _saveTransaction,
                    onTransactionTap: (tx) =>
                        _openEditTransaction(tx, categories),
                  ),
                  _AnalyticsTab(
                    transactions: transactions,
                    categories: categories,
                    buildFinanceSummary: widget.buildFinanceSummaryUseCase,
                  ),
                  _AdvisorTab(
                    report: _advisorReport,
                    isGenerating: _isGeneratingReport,
                    onRefresh: () => _generateReport(transactions),
                  ),
                  _CloudTab(
                    session: widget.session,
                    onBackupTap: (_isBackingUp || _isDeviceLocalSession)
                        ? null
                        : _backupSnapshot,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

const String _defaultAccountId = 'conta_principal';

class _MovementsTab extends StatelessWidget {
  final LancamentoState state;
  final List<Transaction> transactions;
  final List<MovementCategory> categories;
  final TextEditingController descriptionController;
  final TextEditingController valueController;
  final DateTime selectedDate;
  final TransactionType selectedType;
  final String? selectedCategoryId;
  final VoidCallback onDateTap;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback? onSaveTap;
  final ValueChanged<Transaction> onTransactionTap;

  const _MovementsTab({
    required this.state,
    required this.transactions,
    required this.categories,
    required this.descriptionController,
    required this.valueController,
    required this.selectedDate,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onDateTap,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onSaveTap,
    required this.onTransactionTap,
  });

  String? _categoryName(String? id) {
    if (id == null) {
      return null;
    }
    for (final c in categories) {
      if (c.id == id) {
        return c.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(selectedDate);
    final typeCategories =
        categories.where((c) => c.type == selectedType).toList();
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
    final categoryValue = (selectedCategoryId != null &&
            typeCategories.any((c) => c.id == selectedCategoryId))
        ? selectedCategoryId
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova movimentação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
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
                        value: selectedType,
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
                        onChanged: onTypeChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onDateTap,
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
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onSaveTap,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar movimentação'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (state is LancamentoLoading)
          const Center(child: CircularProgressIndicator())
        else if (state is LancamentoError)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text((state as LancamentoError).message),
            ),
          )
        else if (transactions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhuma movimentação registrada ainda.'),
            ),
          )
        else
          ...transactions.map((transaction) {
            final isRevenue = transaction.type == TransactionType.revenue;
            final cat = _categoryName(transaction.categoryId);
            return Card(
              child: ListTile(
                onTap: () => onTransactionTap(transaction),
                title: Text(transaction.description),
                subtitle: Text(
                  cat != null
                      ? '${DateFormat('dd/MM/yyyy').format(transaction.date)} · $cat'
                      : DateFormat('dd/MM/yyyy').format(transaction.date),
                ),
                leading: Icon(
                  isRevenue ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isRevenue ? Colors.green : Colors.red,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.simpleCurrency(locale: 'pt_BR').format(
                        transaction.value,
                      ),
                      style: TextStyle(
                        color: isRevenue ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab({
    required this.transactions,
    required this.categories,
    required this.buildFinanceSummary,
  });

  final List<Transaction> transactions;
  final List<MovementCategory> categories;
  final BuildFinanceSummaryUseCase buildFinanceSummary;

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  AnalyticsChartPeriod _period = const AnalyticsLastMonths(6);
  final BuildCategoryPieSlicesUseCase _pieSlices = BuildCategoryPieSlicesUseCase();

  Future<void> _pickPeriod(BuildContext context) async {
    final next = await showAnalyticsPeriodPicker(
      context,
      current: _period,
    );
    if (next != null && mounted) {
      setState(() => _period = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final now = DateTime.now();
    final summary = widget.buildFinanceSummary(
      widget.transactions,
      now: now,
      chartPeriod: _period,
    );
    final savingsPercent = (summary.savingsRate * 100).toStringAsFixed(1);
    final rangeTx = transactionsInAnalyticsRange(
      widget.transactions,
      _period,
      now,
    );
    final expenseSlices = _pieSlices(
      transactions: rangeTx,
      categories: widget.categories,
      type: TransactionType.expense,
    );
    final revenueSlices = _pieSlices(
      transactions: rangeTx,
      categories: widget.categories,
      type: TransactionType.revenue,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => showCategoryManagerBottomSheet(context),
            icon: const Icon(Icons.category_outlined),
            label: const Text('Gerenciar categorias'),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            MetricCard(
              title: 'Receitas (período)',
              value: money.format(summary.totalRevenue),
              color: Colors.green,
            ),
            MetricCard(
              title: 'Despesas (período)',
              value: money.format(summary.totalExpense),
              color: Colors.red,
            ),
            MetricCard(
              title: 'Saldo (período)',
              value: money.format(summary.netBalance),
              color: summary.netBalance >= 0 ? Colors.blue : Colors.orange,
            ),
            MetricCard(
              title: 'Taxa de poupança',
              value: '$savingsPercent%',
              color: Colors.teal,
            ),
          ],
        ),
        const SizedBox(height: 12),
        MonthlyFlowChart(
          flow: summary.monthlyFlow,
          revenueColor: Colors.green,
          expenseColor: Colors.red,
          onPeriodTap: () => _pickPeriod(context),
          periodLabel: describeAnalyticsPeriod(_period),
        ),
        const SizedBox(height: 12),
        CategoryPieChart(
          title: 'Despesas por categoria',
          slices: expenseSlices,
          money: money,
        ),
        const SizedBox(height: 12),
        CategoryPieChart(
          title: 'Receitas por categoria',
          slices: revenueSlices,
          money: money,
        ),
      ],
    );
  }
}

class _AdvisorTab extends StatelessWidget {
  final InvestmentAdvisorReport? report;
  final bool isGenerating;
  final VoidCallback onRefresh;

  const _AdvisorTab({
    required this.report,
    required this.isGenerating,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agente de IA de investimentos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'O agente analisa evolução de caixa e sugere quando e onde investir.',
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: isGenerating ? null : onRefresh,
                  icon: isGenerating
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_graph),
                  label: const Text('Gerar recomendações'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (report == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Gere o relatório para ver recomendações personalizadas.'),
            ),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(report!.executiveSummary),
            ),
          ),
          if (report!.alerts.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: report!.alerts
                      .map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $alert'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ...report!.recommendations.map(
            (recommendation) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(recommendation.description),
                    const SizedBox(height: 6),
                    Text('Quando: ${recommendation.timing}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CloudTab extends StatefulWidget {
  final UserSession session;
  final VoidCallback? onBackupTap;

  const _CloudTab({required this.session, required this.onBackupTap});

  @override
  State<_CloudTab> createState() => _CloudTabState();
}

class _CloudTabState extends State<_CloudTab> {
  final BiometricLockService _biometric = BiometricLockService();
  bool _lockEnabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshLockPref();
  }

  Future<void> _refreshLockPref() async {
    final v = await _biometric.isLockEnabled();
    if (mounted) {
      setState(() => _lockEnabled = v);
    }
  }

  Future<void> _onLockSwitch(bool value) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      if (value) {
        final hasBio = await _biometric.hasEnrolledBiometrics();
        if (!mounted) {
          return;
        }
        if (!hasBio) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Biometria indisponível'),
              content: const Text(
                'Cadastre impressão digital ou rosto nas configurações de segurança '
                'do aparelho e tente de novo.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ok'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await openAppSettings();
                  },
                  child: const Text('Abrir configurações'),
                ),
              ],
            ),
          );
          return;
        }

        final ok = await _biometric.unlock(
          reason: 'Confirme para ativar o bloqueio com biometria',
        );
        if (!mounted) {
          return;
        }
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autenticação necessária para ativar a proteção.'),
            ),
          );
          return;
        }
        await _biometric.setLockEnabled(true);
        if (mounted) {
          setState(() => _lockEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proteção com biometria ativada.'),
            ),
          );
        }
      } else {
        await _biometric.setLockEnabled(false);
        if (mounted) {
          setState(() => _lockEnabled = false);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationLabel = switch (widget.session.authProvider) {
      AuthProvider.gmail => 'Destino: Google Drive',
      AuthProvider.outlook => 'Destino: OneDrive',
      AuthProvider.deviceLocal => 'Sem nuvem: dados só neste aparelho',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conta logada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(widget.session.email),
                Text(destinationLabel),
                if (widget.session.authProvider == AuthProvider.deviceLocal) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Use Gmail ou Outlook quando precisar de backup na nuvem.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onBackupTap,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Salvar snapshot na nuvem'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile.adaptive(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Bloquear app com biometria'),
            subtitle: const Text(
              'Ao abrir o app ou voltar do segundo plano, será pedida a digital '
              '(ou Face ID). O sistema pode solicitar permissão de uso da biometria.',
            ),
            value: _lockEnabled,
            onChanged: _busy ? null : _onLockSwitch,
          ),
        ),
      ],
    );
  }
}
