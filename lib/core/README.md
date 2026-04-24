# Core Layer

Esta camada centraliza todas as exportações e tipos do projeto para fácil acesso.

## exports.dart

Arquivo principal que exporta:
- **Enums**: `LancamentoTipo`
- **Entities**: `Conta`, `Lancamento`, `Meta`
- **Repositories**: Interfaces do domínio
- **Failures**: Classes de erro
- **Usecases**: Casos de uso
- **Models**: DTOs para banco de dados
- **Widgets**: Componentes reutilizáveis
- **Pages**: Telas da aplicação
- **Cubits**: Gerenciamento de estado

## Como usar

### Exemplo 1: Importar um enum
```dart
import 'package:my_finance/core/exports.dart';

// Usar diretamente
LancamentoTipo.receita
LancamentoTipo.despesa
```

### Exemplo 2: Importar múltiplas classes
```dart
import 'package:my_finance/core/exports.dart';

// Usar Conta, Lancamento, Meta
final lancamento = Lancamento(
  id: '1',
  descricao: 'Salário',
  valor: 1000,
  data: DateTime.now(),
  tipo: LancamentoTipo.receita,
  contaId: '1',
);
```

### Exemplo 3: Usar Cubits e States
```dart
import 'package:my_finance/core/exports.dart';

class MeuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LancamentoCubit, LancamentoState>(
      builder: (context, state) {
        if (state is LancamentoLoaded) {
          return ListView(
            children: state.lancamentos
                .map((l) => TransactionTile(
                      descricao: l.descricao,
                      valor: l.valor,
                      tipo: l.tipo.name,
                    ))
                .toList(),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

## Benefícios

✅ Importação centralizada  
✅ Menos conflitos de imports  
✅ Facilita refatoração  
✅ Código mais limpo e legível
