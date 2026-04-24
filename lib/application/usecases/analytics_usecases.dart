import '../../domain/entities/finance_entities.dart';
import '../contracts/advisor_contracts.dart';

class BuildFinanceSummaryUseCase {
  FinanceSummary call(
    List<Transaction> transactions, {
    int monthsWindow = 6,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final startMonth = DateTime(
      referenceDate.year,
      referenceDate.month - (monthsWindow - 1),
      1,
    );

    final monthlyMap = <DateTime, _MonthAccumulator>{};
    for (var i = 0; i < monthsWindow; i++) {
      final month = DateTime(startMonth.year, startMonth.month + i, 1);
      monthlyMap[month] = _MonthAccumulator.zero();
    }

    double totalRevenue = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
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
