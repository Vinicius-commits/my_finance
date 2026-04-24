import '../../domain/entities/finance_entities.dart';

abstract class IInvestmentAdvisorAgent {
  Future<InvestmentAdvisorReport> generateReport({
    required FinanceSummary summary,
    required List<Transaction> transactions,
    DateTime? referenceDate,
  });
}
