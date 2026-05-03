import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../application/contracts/auth_contracts.dart';
import '../../core/network_connectivity.dart';
import '../../application/usecases/analytics_usecases.dart';
import '../../application/usecases/cloud_sync_usecases.dart';
import '../../domain/entities/finance_entities.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  final IAuthService authService;
  final BackupFinanceSnapshotUseCase backupFinanceSnapshotUseCase;
  final BuildFinanceSummaryUseCase buildFinanceSummaryUseCase;
  final GenerateInvestmentAdvisorReportUseCase
  generateInvestmentAdvisorReportUseCase;

  const LoginPage({
    super.key,
    required this.authService,
    required this.backupFinanceSnapshotUseCase,
    required this.buildFinanceSummaryUseCase,
    required this.generateInvestmentAdvisorReportUseCase,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool get _showDesktopGoogleOAuthHint {
  if (kIsWeb) {
    return false;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.fuchsia:
      return false;
  }
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _outlookEmailController = TextEditingController();
  final TextEditingController _oneDriveTokenController = TextEditingController();

  @override
  void dispose() {
    _outlookEmailController.dispose();
    _oneDriveTokenController.dispose();
    super.dispose();
  }

  Future<void> _loginWithGmail() async {
    final proceed = await _confirmGoogleDriveAccess();
    if (!proceed) {
      return;
    }

    await _runLogin(
      action: () async {
        await assertDeviceOnline();
        return widget.authService.loginWithGmail();
      },
      fallbackMessage: 'Falha no login com Gmail.',
    );
  }

  /// Explica o uso do Google Drive e pede confirmação antes do OAuth (escopos Drive).
  Future<bool> _confirmGoogleDriveAccess() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Acesso ao Google Drive'),
          content: const SingleChildScrollView(
            child: Text(
              'O app precisa da internet e da sua conta Google para gravar backups '
              'na pasta de dados do aplicativo no Google Drive (não na sua galeria '
              'nem em “Todos os arquivos”). '
              'Na próxima tela, o Google pode pedir que você autorize esse acesso.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _loginWithOutlook() async {
    final confirmed = await _showOutlookDialog();
    if (!confirmed) {
      return;
    }

    await _runLogin(
      action: () => widget.authService.loginWithOutlook(
        email: _outlookEmailController.text,
        oneDriveAccessToken: _oneDriveTokenController.text,
      ),
      fallbackMessage: 'Falha no login com Outlook.',
    );
  }

  Future<void> _runLogin({
    required Future<UserSession> Function() action,
    required String fallbackMessage,
  }) async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await action();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DashboardPage(
            session: session,
            backupFinanceSnapshotUseCase: widget.backupFinanceSnapshotUseCase,
            buildFinanceSummaryUseCase: widget.buildFinanceSummaryUseCase,
            generateInvestmentAdvisorReportUseCase:
                widget.generateInvestmentAdvisorReportUseCase,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? fallbackMessage : message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showOutlookDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Entrar com Outlook'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _outlookEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail Outlook',
                        hintText: 'seuemail@outlook.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _oneDriveTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Token OneDrive (Graph API)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Este token permite enviar o backup JSON para a pasta Apps/MyFinance no OneDrive.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'My Finance',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha como entrar no app e para onde enviar seus backups.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login com Gmail',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text('Sincroniza backup no Google Drive.'),
                          if (_showDesktopGoogleOAuthHint) ...[
                            const SizedBox(height: 8),
                            Text(
                              'No Windows/Linux o login abre no navegador. '
                              'Compile com --dart-define=GOOGLE_OAUTH_CLIENT_ID=... '
                              '(tipo Desktop no Google Cloud; veja google_oauth_config.dart).',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _loginWithGmail,
                              icon: const Icon(Icons.mail_outline),
                              label: const Text('Entrar com Gmail'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login com Outlook',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text('Sincroniza backup no OneDrive.'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _loginWithOutlook,
                              icon: const Icon(Icons.cloud_sync),
                              label: const Text('Entrar com Outlook'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 18),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
