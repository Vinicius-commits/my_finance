Esta é a pasta mais importante para a modularidade. Cada subpasta aqui representa uma funcionalidade independente do seu aplicativo. 
Dentro de cada feature, a estrutura segue a Clean Architecture (data, domain, presentation).

Exemplo: lib/features/auth/ (Autenticação)

•
lib/features/auth/data/: Implementações de como os dados de autenticação são obtidos e armazenados.

•
datasources/: Implementações concretas de fontes de dados.

•
auth_remote_datasource.dart: Lida com a interação com FirebaseAuth e GoogleSignIn.



•
models/: Modelos de dados específicos da camada de dados (se houver necessidade de mapeamento de dados de API/Firebase para objetos internos).

•
repositories/: Implementação concreta da interface do repositório de autenticação.

•
auth_repository_impl.dart: Implementa AuthRepository (do domínio) usando AuthRemoteDataSource.





•
lib/features/auth/domain/: Lógica de negócios pura para autenticação.

•
entities/: Entidades de domínio.

•
user_entity.dart: Representa o usuário autenticado, independente de como ele foi autenticado.



•
repositories/: Interface abstrata do repositório de autenticação.

•
auth_repository.dart: Define o contrato para operações de autenticação (ex: signInWithGoogle, signOut).



•
usecases/: Casos de uso de autenticação.

•
sign_in_with_google.dart: Orquestra o processo de login com Google.

•
sign_out.dart: Orquestra o processo de logout.

•
get_current_user.dart: Obtém o usuário atualmente logado.





•
lib/features/auth/presentation/: UI e gerenciamento de estado para autenticação.

•
pages/: Telas completas da funcionalidade.

•
login_page.dart: Tela de login. (Refatorar: Mover log_in_page.dart da raiz lib/pages/ para cá)

•
register_page.dart: Tela de registro. (Refatorar: Mover register.dart da raiz lib/pages/ para cá)



•
providers/: Provedores Riverpod específicos da funcionalidade de autenticação.

•
auth_providers.dart: Provedores para SignInWithGoogleUseCase, SignOutUseCase, e o estado de autenticação do usuário.



•
widgets/: Widgets reutilizáveis específicos da funcionalidade (ex: um botão de login com Google estilizado).



Exemplo: lib/features/transactions/ (Transações)

•
lib/features/transactions/data/: Implementações de como os dados de transação são obtidos e armazenados.

•
datasources/: Fontes de dados.

•
transaction_local_datasource.dart: Interage com o Drift para transações.

•
transaction_remote_datasource.dart: Interage com o Firestore para transações.

•
open_finance_api_datasource.dart: Interage com APIs de Open Finance para transações automáticas.



•
models/: Modelos de dados específicos da camada de dados.

•
transaction_model.dart: Mapeia dados do Drift/Firestore para objetos Dart.



•
repositories/: Implementação concreta do repositório de transações.

•
transaction_repository_impl.dart: Implementa TransactionRepository usando os datasources.





•
lib/features/transactions/domain/: Lógica de negócios pura para transações.

•
entities/: Entidades de domínio.

•
transaction_entity.dart: Representa uma transação.



•
repositories/: Interface abstrata do repositório de transações.

•
transaction_repository.dart: Define o contrato para operações de transação.



•
usecases/: Casos de uso de transações.

•
add_transaction.dart: Adiciona uma nova transação.

•
get_transactions.dart: Obtém a lista de transações.

•
update_transaction.dart, delete_transaction.dart.

•
process_automatic_transaction.dart: Lógica para processar transações de Open Finance.





•
lib/features/transactions/presentation/: UI e gerenciamento de estado para transações.

•
pages/: Telas completas da funcionalidade.

•
add_transaction_page.dart: Tela para adicionar transações. (Já está aqui, ótimo!)

•
transactions_list_page.dart: Tela que lista as transações.

•
transaction_detail_page.dart: Tela de detalhes de uma transação.



•
providers/: Provedores Riverpod específicos da funcionalidade de transações.

•
transaction_providers.dart: Provedores para AddTransactionUseCase, GetTransactionsUseCase, e o estado da lista de transações.



•
widgets/: Widgets reutilizáveis específicos da funcionalidade (ex: TransactionListItem, TransactionForm).



Outras Funcionalidades (lib/features/accounts/, lib/features/reports/, lib/features/installments/, lib/features/wallet/)

Cada uma dessas pastas de funcionalidade deve seguir a mesma estrutura interna (data/, domain/, presentation/) para manter a consistência e modularidade. Por exemplo:

•
lib/features/accounts/: Gerenciamento de contas bancárias.

•
pages/: accounts_list_page.dart, add_account_page.dart.



•
lib/features/reports/: Geração de relatórios e análises.

•
pages/: reports_page.dart, expense_analysis_page.dart.



•
lib/features/installments/: Gerenciamento de parcelamentos.

•
pages/: installments_list_page.dart.



•
lib/features/wallet/: Funcionalidade futura de carteira digital.

•
pages/: wallet_page.dart, card_details_page.dart.



