import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'application/contracts/auth_contracts.dart';
import 'application/usecases/analytics_usecases.dart';
import 'application/usecases/cloud_sync_usecases.dart';
import 'application/usecases/finance_usecases.dart';
import 'infrastructure/config/google_oauth_config.dart';
import 'infrastructure/datasources/finance_datasource.dart';
import 'infrastructure/repositories/finance_repository_impl.dart';
import 'infrastructure/services/auth_service.dart';
import 'infrastructure/services/google_auth_session.dart';
import 'infrastructure/services/google_drive_backup_service.dart';
import 'infrastructure/services/onedrive_backup_service.dart';
import 'infrastructure/services/rule_based_investment_advisor_agent.dart';
import 'presentation/bloc/finance_cubits.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/widgets/app_lock_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final datasource = SqfliteFinanceDatasource();
  final lancamentoRepo = TransactionRepositoryImpl(datasource);
  final contaRepo = ContaRepositoryImpl(datasource);

  final getLancamentos = GetLancamentosUseCase(lancamentoRepo);
  final addLancamento = AddLancamentoUseCase(lancamentoRepo);
  final getContas = GetContasUseCase(contaRepo);
  final addConta = AddContaUseCase(contaRepo);

  final googleAuthSession = GoogleAuthSession();
  final googleSignIn = GoogleSignIn(
    scopes: googleOAuthDriveScopes(),
  );

  final authService = AuthService(
    googleSignIn: googleSignIn,
    googleAuthSession: googleAuthSession,
  );
  final cloudBackupGateway = CloudBackupGateway(
    googleDriveBackupService: GoogleDriveBackupService(
      googleSignIn,
      googleAuthSession,
    ),
    oneDriveBackupService: OneDriveBackupService(),
  );

  final backupFinanceSnapshotUseCase = BackupFinanceSnapshotUseCase(
    transactionRepository: lancamentoRepo,
    contaRepository: contaRepo,
    cloudBackupGateway: cloudBackupGateway,
  );

  final buildFinanceSummaryUseCase = BuildFinanceSummaryUseCase();
  final advisorAgent = RuleBasedInvestmentAdvisorAgent();
  final generateInvestmentAdvisorReportUseCase =
      GenerateInvestmentAdvisorReportUseCase(advisorAgent);

  final lancamentoCubit = LancamentoCubit(
    getLancamentos: getLancamentos,
    addLancamento: addLancamento,
  );

  final contaCubit = ContaCubit(
    getContas: getContas,
    addConta: addConta,
  );

  runApp(
    FinanceApp(
      lancamentoCubit: lancamentoCubit,
      contaCubit: contaCubit,
      authService: authService,
      backupFinanceSnapshotUseCase: backupFinanceSnapshotUseCase,
      buildFinanceSummaryUseCase: buildFinanceSummaryUseCase,
      generateInvestmentAdvisorReportUseCase:
          generateInvestmentAdvisorReportUseCase,
    ),
  );
}

class FinanceApp extends StatefulWidget {
  final LancamentoCubit lancamentoCubit;
  final ContaCubit contaCubit;
  final IAuthService authService;
  final BackupFinanceSnapshotUseCase backupFinanceSnapshotUseCase;
  final BuildFinanceSummaryUseCase buildFinanceSummaryUseCase;
  final GenerateInvestmentAdvisorReportUseCase
  generateInvestmentAdvisorReportUseCase;

  const FinanceApp({
    super.key,
    required this.lancamentoCubit,
    required this.contaCubit,
    required this.authService,
    required this.backupFinanceSnapshotUseCase,
    required this.buildFinanceSummaryUseCase,
    required this.generateInvestmentAdvisorReportUseCase,
  });

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void changeTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.lancamentoCubit),
        BlocProvider.value(value: widget.contaCubit),
      ],
      child: MaterialApp(
        builder: (context, child) =>
            AppLockGate(child: child ?? const SizedBox.shrink()),
        title: 'Finanças Simples',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.indigo,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.teal,
        ),
        themeMode: _themeMode,
        home: LoginPage(
          authService: widget.authService,
          backupFinanceSnapshotUseCase: widget.backupFinanceSnapshotUseCase,
          buildFinanceSummaryUseCase: widget.buildFinanceSummaryUseCase,
          generateInvestmentAdvisorReportUseCase:
              widget.generateInvestmentAdvisorReportUseCase,
        ),
      ),
    );
  }
}
