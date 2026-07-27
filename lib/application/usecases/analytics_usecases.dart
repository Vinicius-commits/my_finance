import '../../domain/entities/finance_entities.dart';
import '../contracts/advisor_contracts.dart';

sealed class AnalyticsChartPeriod {
  const AnalyticsChartPeriod();
}

final class AnalyticsLastMonths extends AnalyticsChartPeriod {
  final int months;
  const AnalyticsLastMonths(this.months);
}

final class AnalyticsMonthRange extends AnalyticsChartPeriod {
  final DateTime startMonth;
  final DateTime endMonth;
  const AnalyticsMonthRange({
    required this.startMonth,
    required this.endMonth,
  });
}

({DateTime start, DateTime end}) resolveAnalyticsRange(
  AnalyticsChartPeriod period,
  DateTime reference,
) {
  switch (period) {
    case AnalyticsLastMonths(:final months):
      final m = months < 1 ? 1 : (months > 60 ? 60 : months);
      final start = DateTime(reference.year, reference.month - (m - 1), 1);
      final end = DateTime(
        reference.year,
        reference.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
      return (start: start, end: end);
    case AnalyticsMonthRange(:final startMonth, :final endMonth):
      var s = DateTime(startMonth.year, startMonth.month, 1);
      var eLast = DateTime(endMonth.year, endMonth.month + 1, 0, 23, 59, 59, 999);
      if (eLast.isBefore(s)) {
        final t = s;
        s = DateTime(endMonth.year, endMonth.month, 1);
        eLast = DateTime(t.year, t.month + 1, 0, 23, 59, 59, 999);
      }
      return (start: s, end: eLast);
  }
}

List<Transaction> transactionsInAnalyticsRange(
  List<Transaction> transactions,
  AnalyticsChartPeriod period, [
  DateTime? reference,
]) {
  final ref = reference ?? DateTime.now();
  final (:start, :end) = resolveAnalyticsRange(period, ref);
  return transactions
      .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
      .toList();
}

class BuildFinanceSummaryUseCase {
  FinanceSummary call(
    List<Transaction> transactions, {
    DateTime? now,
    AnalyticsChartPeriod? chartPeriod,
  }) {
    final referenceDate = now ?? DateTime.now();
    final period = chartPeriod ?? const AnalyticsLastMonths(6);
    final (start: rangeStart, end: rangeEnd) = resolveAnalyticsRange(
      period,
      referenceDate,
    );

    final filtered = transactions
        .where(
          (t) => !t.date.isBefore(rangeStart) && !t.date.isAfter(rangeEnd),
        )
        .toList();

    final monthlyMap = <DateTime, _MonthAccumulator>{};
    for (
      var cursor = DateTime(rangeStart.year, rangeStart.month, 1);
      !DateTime(
        cursor.year,
        cursor.month,
        1,
      ).isAfter(DateTime(rangeEnd.year, rangeEnd.month, 1));
      cursor = DateTime(cursor.year, cursor.month + 1, 1)
    ) {
      monthlyMap[DateTime(cursor.year, cursor.month, 1)] =
          _MonthAccumulator.zero();
    }

    var totalRevenue = 0.0;
    var totalExpense = 0.0;

    for (final tx in filtered) {
      if (tx.type == TransactionType.revenue) {
        totalRevenue += tx.value;
      } else {
        totalExpense += tx.value;
      }

      final monthKey = DateTime(tx.date.year, tx.date.month, 1);
      final bucket = monthlyMap[monthKey];
      if (bucket == null) {
        continue;
      }
      if (tx.type == TransactionType.revenue) {
        bucket.revenue += tx.value;
      } else {
        bucket.expense += tx.value;
      }
    }

    final net = totalRevenue - totalExpense;
    final savingsRate = totalRevenue > 0 ? (net / totalRevenue) : 0.0;
    final monthlyFlow = monthlyMap.entries
        .map(
          (entry) => MonthlyFlow(
            month: entry.key,
            revenue: entry.value.revenue,
            expense: entry.value.expense,
          ),
        )
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return FinanceSummary(
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
      netBalance: net,
      savingsRate: savingsRate,
      monthlyFlow: monthlyFlow,
    );
  }
}

class BuildCategoryPieSlicesUseCase {
  List<CategorySlice> call({
    required List<Transaction> transactions,
    required List<MovementCategory> categories,
    required TransactionType type,
  }) {
    final byId = {for (final c in categories) c.id: c};
    final totals = <String, double>{};

    for (final tx in transactions) {
      if (tx.type != type) {
        continue;
      }
      final key = tx.categoryId ?? '';
      totals[key] = (totals[key] ?? 0) + tx.value;
    }

    final slices = <CategorySlice>[];
    for (final e in totals.entries) {
      if (e.value <= 0) {
        continue;
      }
      final id = e.key;
      if (id.isEmpty) {
        slices.add(
          CategorySlice(
            label: 'Sem categoria',
            total: e.value,
            colorArgbHex: 'FF78909C',
          ),
        );
      } else {
        final c = byId[id];
        slices.add(
          CategorySlice(
            label: c?.name ?? 'Categoria removida',
            total: e.value,
            colorArgbHex: c?.colorArgbHex ?? 'FF9E9E9E',
          ),
        );
      }
    }
    slices.sort((a, b) => b.total.compareTo(a.total));
    return slices;
  }
}

class GenerateInvestmentAdvisorReportUseCase {
  final IInvestmentAdvisorAgent _agent;

  GenerateInvestmentAdvisorReportUseCase(this._agent);

  Future<InvestmentAdvisorReport> call({
    required FinanceSummary summary,
    required List<Transaction> transactions,
    DateTime? referenceDate,
  }) async {
    return _agent.generateReport(
      summary: summary,
      transactions: transactions,
      referenceDate: referenceDate,
    );
  }
}

class _MonthAccumulator {
  double revenue;
  double expense;

  _MonthAccumulator({
    required this.revenue,
    required this.expense,
  });

  factory _MonthAccumulator.zero() {
    return _MonthAccumulator(revenue: 0, expense: 0);
  }
}
