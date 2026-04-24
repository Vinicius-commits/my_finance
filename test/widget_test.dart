import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/application/usecases/analytics_usecases.dart';
import 'package:my_finance/domain/entities/finance_entities.dart';

void main() {
  test('BuildFinanceSummaryUseCase should calculate totals', () {
    final useCase = BuildFinanceSummaryUseCase();

    final transactions = [
      Transaction(
        id: '1',
        description: 'Salario',
        value: 5000,
        date: DateTime(2026, 4, 1),
        type: TransactionType.revenue,
        accountId: 'conta',
      ),
      Transaction(
        id: '2',
        description: 'Aluguel',
        value: 1800,
        date: DateTime(2026, 4, 2),
        type: TransactionType.expense,
        accountId: 'conta',
      ),
    ];

    final summary = useCase(transactions, now: DateTime(2026, 4, 30));

    expect(summary.totalRevenue, 5000);
    expect(summary.totalExpense, 1800);
    expect(summary.netBalance, 3200);
  });
}
