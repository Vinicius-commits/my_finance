enum TransactionType { revenue, expense }

enum AuthProvider { gmail, outlook, deviceLocal }

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
  /// Identificador da categoria (receita/despesa); nulo = sem categoria.
  final String? categoryId;

  Transaction({
    required this.id,
    required this.description,
    required this.value,
    required this.date,
    required this.type,
    required this.accountId,
    this.categoryId,
  });

  Transaction copyWith({
    String? id,
    String? description,
    double? value,
    DateTime? date,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    bool clearCategoryId = false,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      date: date ?? this.date,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
    );
  }
}

/// Categoria configurável pelo usuário (receita ou despesa).
class MovementCategory {
  final String id;
  final String name;
  final TransactionType type;
  /// Cor ARGB em hex sem prefixo, ex.: FF4CAF50
  final String colorArgbHex;

  const MovementCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.colorArgbHex,
  });
}

/// Fatia agregada para gráfico pizza.
class CategorySlice {
  final String label;
  final double total;
  final String colorArgbHex;

  const CategorySlice({
    required this.label,
    required this.total,
    required this.colorArgbHex,
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
