// Modelos para serialização com Sqflite (fromMap/toMap)
import 'package:my_finance/core/exports.dart';
import 'package:my_finance/core/lancamento_tipo_extension.dart';

// Modelo Conta
class ContaModel {
  final String id;
  final String name;
  final double currency;

  ContaModel({required this.id, required this.name, required this.currency});

  factory ContaModel.fromMap(Map<String, dynamic> map) {
    return ContaModel(
      id: map['id']?.toString() ?? '',
      name: map['nome']?.toString() ?? '',
      currency: _parseDouble(map['saldo']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': name, 'saldo': currency};
  }
}

// Modelo Lançamento
class TransactionModel {
  final String id;
  final String description;
  final double value;
  final DateTime date;
  final TransactionType type;
  final String accountId;
  final String? categoryId;

  TransactionModel({
    required this.id,
    required this.description,
    required this.value,
    required this.date,
    required this.type,
    required this.accountId,
    this.categoryId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final rawCat = map['categoriaId']?.toString();
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      description: map['descricao']?.toString() ?? '',
      value: _parseDouble(map['valor']),
      date: DateTime.tryParse(map['data']?.toString() ?? '') ?? DateTime.now(),
      type: TransactionTypeExtension.fromString(map['tipo']?.toString() ?? ''),
      accountId: map['contaId']?.toString() ?? '',
      categoryId: (rawCat == null || rawCat.isEmpty) ? null : rawCat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': description,
      'valor': value,
      'data': date.toIso8601String(),
      'tipo': type.name,
      'contaId': accountId,
      'categoriaId': categoryId,
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final String colorArgbHex;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.colorArgbHex,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['nome']?.toString() ?? '',
      type: TransactionTypeExtension.fromString(map['tipo']?.toString() ?? ''),
      colorArgbHex: map['cor']?.toString() ?? 'FF9E9E9E',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': name,
      'tipo': type.name,
      'cor': colorArgbHex,
    };
  }
}

// Modelo Meta
class MetaModel {
  final String id;
  final String titulo;
  final double valorAlvo;
  final double valorAtual;
  final DateTime dataLimite;

  MetaModel({
    required this.id,
    required this.titulo,
    required this.valorAlvo,
    required this.valorAtual,
    required this.dataLimite,
  });

  factory MetaModel.fromMap(Map<String, dynamic> map) {
    return MetaModel(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      valorAlvo: _parseDouble(map['valorAlvo']),
      valorAtual: _parseDouble(map['valorAtual']),
      dataLimite:
          DateTime.tryParse(map['dataLimite']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'valorAlvo': valorAlvo,
      'valorAtual': valorAtual,
      'dataLimite': dataLimite.toIso8601String(),
    };
  }
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}
