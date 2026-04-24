/// Arquivo de exportação centralizado para toda a aplicação
/// Use este arquivo para importar todos os tipos, enums e classes importantes

// Enums
export '../domain/entities/finance_entities.dart' show TransactionType;

// Domain - Entities
export '../domain/entities/finance_entities.dart' show Conta, Transaction, Meta;

// Domain - Repositories
export '../domain/repositories/finance_repositories.dart'
    show IContaRepository, ILancamentoRepository, IMetaRepository;

// Domain - Failures
export '../domain/failures/failure.dart' show Failure, ValidationFailure;

// Application - Usecases
export '../application/usecases/finance_usecases.dart'
    show
        AddLancamentoUseCase,
        GetLancamentosUseCase,
        AddContaUseCase,
        GetContasUseCase,
        GetMetasUseCase;
export '../application/usecases/analytics_usecases.dart'
    show BuildFinanceSummaryUseCase, GenerateInvestmentAdvisorReportUseCase;
export '../application/usecases/cloud_sync_usecases.dart'
    show CloudBackupGateway, BackupFinanceSnapshotUseCase;

// Infrastructure - Models
export '../infrastructure/models/finance_models.dart'
    show ContaModel, TransactionModel, MetaModel;

// Presentation - Widgets
export '../presentation/widgets/finance_widgets.dart'
    show SaldoCard, TransactionTile;

// Presentation - Pages
export '../presentation/pages/dashboard_page.dart' show DashboardPage;
export '../presentation/pages/login_page.dart' show LoginPage;

// Presentation - Cubits
export '../presentation/bloc/finance_cubits.dart'
    show
        LancamentoState,
        LancamentoInitial,
        LancamentoLoading,
        LancamentoLoaded,
        LancamentoError,
        LancamentoCubit,
        ContaState,
        ContaInitial,
        ContaLoaded,
        ContaError,
        ContaCubit;
