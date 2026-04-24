/// Extensões e helpers para uso do enum LancamentoTipo

import 'exports.dart';

extension TransactionTypeExtension on TransactionType {
  /// Retorna a representação em string do tipo
  String get displayName {
    switch (this) {
      case TransactionType.revenue:
        return 'revenue';
      case TransactionType.expense:
        return 'expense';
    }
  }

  /// Retorna a cor associada ao tipo
  String get colorHex {
    switch (this) {
      case TransactionType.revenue:
        return '#10B981'; // Verde
      case TransactionType.expense:
        return '#EF4444'; // Vermelho
    }
  }

  /// Retorna o símbolo (+/-)
  String get symbol {
    switch (this) {
      case TransactionType.revenue:
        return '+';
      case TransactionType.expense:
        return '-';
    }
  }

  /// Parse de string para enum
  static TransactionType fromString(String tipo) {
    return TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == tipo,
      orElse: () => TransactionType.expense,
    );
  }
}
