enum TransactionType { revenue, expense }

enum AuthProvider { gmail, outlook }

enum CloudProvider { googleDrive, oneDrive }

class UserSession {
  final String userId;
  final String displayName;
  final String email;
  final AuthProvider authProvider;
  final String? oneDriveAccessToken;
  final DateTime loggedAt;

  const UserSession({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.authProvider,
    required this.loggedAt,
    this.oneDriveAccessToken,
  });

  UserSession copyWith({
    String? userId,
    String? displayName,
    String? email,
    AuthProvider? authProvider,
    String? oneDriveAccessToken,
    DateTime? loggedAt,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      oneDriveAccessToken: oneDriveAccessToken ?? this.oneDriveAccessToken,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}

// Entidade Conta
class Conta {
  final String id;
  final String name;
  final double currency;

  Conta({required this.id, required this.name, required this.currency});
}

class Transaction {
  final String id;
  final String description;
  final double value;
  final DateTime date;
  final TransactionType type;
  final String accountId;

  Transaction({
    required this.id,
    required this.description,
    required this.value,
    required this.date,
    required this.type,
    required this.accountId,
  });
}

class MonthlyFlow {
  final DateTime month;
  final double revenue;
  final double expense;

  const MonthlyFlow({
    required this.month,
    required this.revenue,
    required this.expense,
  });

  double get netBalance => revenue - expense;
}

class FinanceSummary {
  final double totalRevenue;
  final double totalExpense;
  final double netBalance;
  final double savingsRate;
  final List<MonthlyFlow> monthlyFlow;

  const FinanceSummary({
    required this.totalRevenue,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate,
    required this.monthlyFlow,
  });
}

class InvestmentRecommendation {
  final String title;
  final String description;
  final String timing;
  final int priority;

  const InvestmentRecommendation({
    required this.title,
    required this.description,
    required this.timing,
    required this.priority,
  });
}

class InvestmentAdvisorReport {
  final String executiveSummary;
  final List<String> alerts;
  final List<InvestmentRecommendation> recommendations;
  final DateTime generatedAt;
  final DateTime nextReviewDate;

  const InvestmentAdvisorReport({
    required this.executiveSummary,
    required this.alerts,
    required this.recommendations,
    required this.generatedAt,
    required this.nextReviewDate,
  });
}

// Entidade Meta
class Meta {
  final String id;
  final String name;
  final double targetvalue;
  final double currentValue;
  final DateTime deadline;

  Meta({
    required this.id,
    required this.name,
    required this.targetvalue,
    required this.currentValue,
    required this.deadline,
  });
}
