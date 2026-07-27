import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../application/usecases/analytics_usecases.dart';
import '../../domain/entities/finance_entities.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String describeAnalyticsPeriod(AnalyticsChartPeriod period) {
  switch (period) {
    case AnalyticsLastMonths(:final months):
      return months == 1
          ? 'Último mês'
          : 'Últimos $months meses';
    case AnalyticsMonthRange(:final startMonth, :final endMonth):
      final a = DateFormat('MMM/yyyy', 'pt_BR').format(startMonth);
      final b = DateFormat('MMM/yyyy', 'pt_BR').format(endMonth);
      return '$a — $b';
  }
}

Future<AnalyticsChartPeriod?> showAnalyticsPeriodPicker(
  BuildContext context, {
  required AnalyticsChartPeriod current,
}) async {
  return showDialog<AnalyticsChartPeriod>(
    context: context,
    builder: (ctx) {
      return _AnalyticsPeriodDialogBody(initial: current);
    },
  );
}

class _AnalyticsPeriodDialogBody extends StatefulWidget {
  const _AnalyticsPeriodDialogBody({required this.initial});

  final AnalyticsChartPeriod initial;

  @override
  State<_AnalyticsPeriodDialogBody> createState() =>
      _AnalyticsPeriodDialogBodyState();
}

class _AnalyticsPeriodDialogBodyState extends State<_AnalyticsPeriodDialogBody> {
  late Object _choice; // int months OR 'custom'
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    switch (widget.initial) {
      case AnalyticsLastMonths(:final months):
        _choice = months;
      case AnalyticsMonthRange(:final startMonth, :final endMonth):
        _choice = 'custom';
        _customStart = DateTime(startMonth.year, startMonth.month, 1);
        _customEnd = DateTime(endMonth.year, endMonth.month, 1);
    }
  }

  Future<void> _pickMonth({required bool isStart}) async {
    final initial = isStart
        ? (_customStart ?? DateTime.now())
        : (_customEnd ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      helpText: isStart ? 'Mês inicial' : 'Mês final',
    );
    if (picked != null) {
      setState(() {
        final m = DateTime(picked.year, picked.month, 1);
        if (isStart) {
          _customStart = m;
        } else {
          _customEnd = m;
        }
      });
    }
  }

  void _submit() {
    if (_choice == 'custom') {
      final s = _customStart;
      final e = _customEnd;
      if (s == null || e == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escolha mês inicial e final.')),
        );
        return;
      }
      Navigator.pop(
        context,
        AnalyticsMonthRange(startMonth: s, endMonth: e),
      );
      return;
    }
    final months = _choice as int;
    Navigator.pop(context, AnalyticsLastMonths(months));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Período dos gráficos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Presets'),
            RadioListTile<int>(
              title: const Text('3 meses'),
              value: 3,
              groupValue: _choice is int ? _choice as int? : null,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _choice = v);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('6 meses'),
              value: 6,
              groupValue: _choice is int ? _choice as int? : null,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _choice = v);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('12 meses'),
              value: 12,
              groupValue: _choice is int ? _choice as int? : null,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _choice = v);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('24 meses'),
              value: 24,
              groupValue: _choice is int ? _choice as int? : null,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _choice = v);
                }
              },
            ),
            RadioListTile<Object>(
              title: const Text('Intervalo personalizado'),
              value: 'custom',
              groupValue: _choice,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _choice = v);
                }
              },
            ),
            if (_choice == 'custom') ...[
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Mês inicial'),
                subtitle: Text(
                  _customStart != null
                      ? DateFormat('MMMM yyyy', 'pt_BR').format(_customStart!)
                      : 'Escolher',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _pickMonth(isStart: true),
              ),
              ListTile(
                title: const Text('Mês final'),
                subtitle: Text(
                  _customEnd != null
                      ? DateFormat('MMMM yyyy', 'pt_BR').format(_customEnd!)
                      : 'Escolher',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => _pickMonth(isStart: false),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class MonthlyFlowChart extends StatelessWidget {
  final List<MonthlyFlow> flow;
  final Color revenueColor;
  final Color expenseColor;
  final VoidCallback? onPeriodTap;
  final String periodLabel;

  const MonthlyFlowChart({
    super.key,
    required this.flow,
    required this.revenueColor,
    required this.expenseColor,
    this.onPeriodTap,
    this.periodLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    if (flow.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Sem dados para o gráfico mensal.')),
        ),
      );
    }

    final maxValue = flow
        .map((item) => item.revenue > item.expense ? item.revenue : item.expense)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    final dateFormat = DateFormat('MM/yy');
    final barWidth = flow.length > 14 ? 28.0 : 40.0;
    final chartWidth = math.max(
      flow.length * (barWidth + 6),
      MediaQuery.sizeOf(context).width - 64,
    );

    return Card(
      child: InkWell(
        onTap: onPeriodTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Evolução mensal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onPeriodTap != null)
                    Icon(
                      Icons.tune,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              if (periodLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  periodLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Toque para mudar o período',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: 170,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: flow.map((item) {
                      final revenueFactor =
                          maxValue == 0 ? 0.0 : item.revenue / maxValue;
                      final expenseFactor =
                          maxValue == 0 ? 0.0 : item.expense / maxValue;
                      return SizedBox(
                        width: barWidth + 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: revenueFactor.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: revenueColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: expenseFactor.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: expenseColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateFormat.format(item.month),
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _LegendDot(color: revenueColor, label: 'Receitas'),
                  const SizedBox(width: 16),
                  _LegendDot(color: expenseColor, label: 'Despesas'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final String title;
  final List<CategorySlice> slices;
  final NumberFormat money;

  const CategoryPieChart({
    super.key,
    required this.title,
    required this.slices,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (slices.isEmpty)
              Text(
                'Sem valores neste período.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final side = math.min(c.maxWidth, c.maxHeight);
                          return CustomPaint(
                            size: Size(side, side),
                            painter: _PieChartPainter(slices: slices),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: slices.map((s) {
                          final total = slices.fold<double>(
                            0,
                            (a, e) => a + e.total,
                          );
                          final pct = total > 0 ? (s.total / total * 100) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 4, right: 8),
                                  decoration: BoxDecoration(
                                    color: _colorFromArgbHex(s.colorArgbHex),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        '${money.format(s.total)}  (${pct.toStringAsFixed(0)}%)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Color _colorFromArgbHex(String hex) {
  final h = hex.replaceAll('#', '');
  final v = int.tryParse(h, radix: 16);
  if (v == null) {
    return Colors.grey;
  }
  return Color(v);
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.slices});

  final List<CategorySlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (a, s) => a + s.total);
    if (total <= 0) {
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.92;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.total / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _colorFromArgbHex(s.colorArgbHex);
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
