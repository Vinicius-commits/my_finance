import '../../application/contracts/advisor_contracts.dart';
import '../../domain/entities/finance_entities.dart';

class RuleBasedInvestmentAdvisorAgent implements IInvestmentAdvisorAgent {
  @override
  Future<InvestmentAdvisorReport> generateReport({
    required FinanceSummary summary,
    required List<Transaction> transactions,
    DateTime? referenceDate,
  }) async {
    final now = referenceDate ?? DateTime.now();

    if (transactions.isEmpty) {
      return InvestmentAdvisorReport(
        executiveSummary:
            'Ainda não há movimentações suficientes para gerar recomendações confiáveis.',
        alerts: const [
          'Adicione receitas e despesas das próximas semanas para liberar análises.',
        ],
        recommendations: const [
          InvestmentRecommendation(
            title: 'Primeiro passo',
            description:
                'Registre ao menos 30 dias de movimentações para calcular perfil de caixa.',
            timing: 'Comece hoje',
            priority: 1,
          ),
        ],
        generatedAt: now,
        nextReviewDate: DateTime(now.year, now.month + 1, 1),
      );
    }

    final avgMonthlyExpense = _averageMonthlyExpense(summary.monthlyFlow);
    final reserveMonths = avgMonthlyExpense > 0
        ? (summary.netBalance / avgMonthlyExpense)
        : 0.0;
    final cashflowTrend = _cashflowTrend(summary.monthlyFlow);

    final recommendations = <InvestmentRecommendation>[];
    final alerts = <String>[];

    if (summary.savingsRate < 0) {
      alerts.add(
        'Você está fechando meses no vermelho. Priorize reequilíbrio antes de investir risco.',
      );
      recommendations.add(
        const InvestmentRecommendation(
          title: 'Ajustar gastos fixos',
          description:
              'Revisar assinaturas e despesas recorrentes para recuperar fluxo positivo.',
          timing: 'Nos próximos 7 dias',
          priority: 1,
        ),
      );
      recommendations.add(
        const InvestmentRecommendation(
          title: 'Reserva de curto prazo',
          description:
              'Enquanto ajusta o orçamento, mantenha caixa em renda fixa líquida.',
          timing: 'Imediato',
          priority: 2,
        ),
      );
    } else {
      if (reserveMonths < 6) {
        recommendations.add(
          const InvestmentRecommendation(
            title: 'Construir reserva de emergência',
            description:
                'Direcione aportes para Tesouro Selic/CDB com liquidez diária até 6 meses de despesas.',
            timing: 'Próximos 3 a 6 meses',
            priority: 1,
          ),
        );
      } else {
        recommendations.add(
          const InvestmentRecommendation(
            title: 'Aporte recorrente diversificado',
            description:
                'Com reserva já sólida, combine renda fixa e ETFs para crescer patrimônio com risco controlado.',
            timing: 'A partir deste mês',
            priority: 1,
          ),
        );
      }

      if (summary.savingsRate >= 0.25) {
        recommendations.add(
          const InvestmentRecommendation(
            title: 'Escalonar aporte',
            description:
                'Automatize aporte mensal de pelo menos 20% da renda para acelerar objetivos de médio prazo.',
            timing: 'No próximo fechamento mensal',
            priority: 2,
          ),
        );
      } else {
        alerts.add(
          'Sua taxa de poupança está abaixo de 25%. Há espaço para aumentar o valor investido.',
        );
      }
    }

    if (cashflowTrend < 0) {
      alerts.add(
        'Tendência de piora no saldo mensal detectada. Monitore despesas variáveis semanalmente.',
      );
    }

    final summaryText = _buildSummaryText(
      summary: summary,
      reserveMonths: reserveMonths,
      trend: cashflowTrend,
    );

    return InvestmentAdvisorReport(
      executiveSummary: summaryText,
      alerts: alerts,
      recommendations: recommendations
        ..sort((a, b) => a.priority.compareTo(b.priority)),
      generatedAt: now,
      nextReviewDate: DateTime(now.year, now.month + 1, 1),
    );
  }

  double _averageMonthlyExpense(List<MonthlyFlow> flow) {
    if (flow.isEmpty) {
      return 0;
    }
    final sum = flow.fold<double>(
      0,
      (acc, item) => acc + item.expense,
    );
    return sum / flow.length;
  }

  double _cashflowTrend(List<MonthlyFlow> flow) {
    if (flow.length < 4) {
      return 0;
    }

    final sorted = List<MonthlyFlow>.from(flow)
      ..sort((a, b) => a.month.compareTo(b.month));
    final recent = sorted.sublist(sorted.length - 3);
    final previous = sorted.sublist(sorted.length - 4, sorted.length - 1);

    final recentAvg =
        recent.fold<double>(0, (acc, item) => acc + item.netBalance) /
        recent.length;
    final previousAvg =
        previous.fold<double>(0, (acc, item) => acc + item.netBalance) /
        previous.length;
    return recentAvg - previousAvg;
  }

  String _buildSummaryText({
    required FinanceSummary summary,
    required double reserveMonths,
    required double trend,
  }) {
    final savingsPercent = (summary.savingsRate * 100).toStringAsFixed(1);
    final trendText = trend >= 0 ? 'estável/positiva' : 'negativa';
    final reserveText = reserveMonths.isFinite
        ? reserveMonths.toStringAsFixed(1)
        : '0';

    return 'Taxa de poupança de $savingsPercent% com tendência de caixa '
        '$trendText. Reserva estimada em $reserveText meses de despesas.';
  }
}
