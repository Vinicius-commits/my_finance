# 📊 Enum LancamentoTipo - Guia de Uso

## ✅ O que foi feito

1. **Criada a pasta `lib/core/`** - Camada central do projeto
2. **Enum `LancamentoTipo`** - Centralizado em `finance_entities.dart`
   - ✅ `LancamentoTipo.receita`
   - ✅ `LancamentoTipo.despesa`
3. **Arquivo `lib/core/exports.dart`** - Exportação centralizada de todo o projeto
4. **Extension `LancamentoTipoExtension`** - Métodos auxiliares do enum
5. **Arquivo de exemplo** - Como usar em diferentes contextos

---

## 🚀 Como usar em qualquer lugar do projeto

### Opção 1: Importar específico (Recomendado)
```dart
import 'package:my_finance/core/exports.dart';

// Usar o enum
final tipo = LancamentoTipo.receita;
```

### Opção 2: Importar direto do entities
```dart
import 'package:my_finance/domain/entities/finance_entities.dart';

final tipo = LancamentoTipo.despesa;
```

### Opção 3: Importar com extension
```dart
import 'package:my_finance/core/exports.dart';
import 'package:my_finance/core/lancamento_tipo_extension.dart';

final tipo = LancamentoTipo.receita;
print(tipo.displayName); // "Receita"
print(tipo.colorHex);   // "#10B981"
print(tipo.symbol);      // "+"
```

---

## 📁 Estrutura atualizada

```
lib/
├── core/                           # ← NOVO: Camada central
│   ├── exports.dart               # Exportação centralizada
│   ├── lancamento_tipo_extension.dart  # Extensions do enum
│   ├── exemplo_uso_lancamento_tipo.dart # Exemplos práticos
│   └── README.md
├── domain/
│   ├── entities/
│   │   └── finance_entities.dart   # ✅ Enum definido aqui
│   ├── repositories/
│   ├── failures/
│   └── README.md
├── application/
│   ├── usecases/
│   └── README.md
├── infrastructure/
│   ├── repositories/
│   ├── datasources/
│   ├── models/
│   └── README.md
└── presentation/
    ├── pages/
    ├── widgets/
    ├── bloc/
    └── README.md
```

---

## 💡 Exemplos de uso

### Em uma Entity
```dart
final lancamento = Lancamento(
  id: 'L1',
  descricao: 'Salário',
  valor: 5000,
  data: DateTime.now(),
  tipo: LancamentoTipo.receita,  // ✅ Enum fortemente tipado
  contaId: 'C1',
);
```

### Em um Cubit/Widget
```dart
class LancamentoCubit extends Cubit<LancamentoState> {
  void filterByTipo(LancamentoTipo tipo) {
    final filtered = lancamentos
        .where((l) => l.tipo == tipo)
        .toList();
  }
}
```

### Em um Widget de Exibição
```dart
class TransactionTile extends StatelessWidget {
  final String descricao;
  final double valor;
  final LancamentoTipo tipo;  // ✅ Usando enum

  @override
  Widget build(BuildContext context) {
    final displayName = tipo.displayName;  // "Receita" ou "Despesa"
    final color = tipo.colorHex;           // Cor correspondente
    
    return ListTile(
      title: Text(descricao),
      subtitle: Text(displayName),
      trailing: Text('${tipo.symbol}R\$ $valor'),
    );
  }
}
```

### Em Model/Serialização
```dart
class LancamentoModel {
  // Converter entity para map
  Map<String, dynamic> toMap() {
    return {
      'tipo': lancamento.tipo.name,  // ✅ "receita" ou "despesa"
    };
  }

  // Parse do banco
  factory LancamentoModel.fromMap(Map map) {
    return LancamentoModel(
      tipo: LancamentoTipo.fromString(map['tipo']),  // ✅ Extension
    );
  }
}
```

---

## ✨ Benefícios

| Aspecto | Antes | Depois |
|--------|-------|--------|
| **Type Safety** | String ("receita") | `LancamentoTipo.receita` |
| **Acessibilidade** | Importação específica | `lib/core/exports.dart` |
| **Métodos auxiliares** | Nenhum | Extensions (displayName, colorHex, symbol) |
| **Manutenibilidade** | Espalhado | Centralizado em um único lugar |
| **Refatoração** | Difícil | Fácil (IDE detecta todos os usos) |

---

## 📝 Próximas ações

- [ ] Delete o arquivo `exemplo_uso_lancamento_tipo.dart` após entender o padrão
- [ ] Use `lib/core/exports.dart` em todos os novos imports
- [ ] Atualize imports antigos para usar o arquivo de exportação central
- [ ] Adicione mais enums em `finance_entities.dart` conforme necessário

---

## 🎯 Exemplo prático completo

```dart
import 'package:my_finance/core/exports.dart';
import 'package:my_finance/core/lancamento_tipo_extension.dart';

void main() {
  // Criar lançamento
  final lancamento = Lancamento(
    id: '1',
    descricao: 'Venda de Serviço',
    valor: 1500,
    data: DateTime.now(),
    tipo: LancamentoTipo.receita,
    contaId: 'conta1',
  );

  // Usar extension
  print(lancamento.tipo.displayName); // "Receita"
  print(lancamento.tipo.symbol);      // "+"
  print(lancamento.tipo.colorHex);    // "#10B981"

  // Parse de string
  final parsed = LancamentoTipo.fromString('despesa');
  print(parsed); // LancamentoTipo.despesa
}
```

---

Enum `LancamentoTipo` agora é **visível e acessível em todo o projeto**! 🎉
