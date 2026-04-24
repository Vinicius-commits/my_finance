import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class MonthlyFlowChart extends StatelessWidget {
  final List<MonthlyFlow> flow;
  final Color revenueColor;
  final Color expenseColor;

  const MonthlyFlowChart({
    super.key,
    required this.flow,
    required this.revenueColor,
    required this.expenseColor,
  });

  @override
  Widget build(BuildContext context) {
    if (flow.isEmpty) {
      return const Center(child: Text('Sem dados para o gráfico mensal.'));
    }

    final maxValue = flow
        .map((item) => item.revenue > item.expense ? item.revenue : item.expense)
        .fold<double>(0, (prev, value) => value > prev ? value : prev);

    final dateFormat = DateFormat('MM/yy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução mensal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: flow.map((item) {
                  final revenueFactor = maxValue == 0 ? 0.0 : item.revenue / maxValue;
                  final expenseFactor = maxValue == 0 ? 0.0 : item.expense / maxValue;
                  return Expanded(
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
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
    );
  }
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
