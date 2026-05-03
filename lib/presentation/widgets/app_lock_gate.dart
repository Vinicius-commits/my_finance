import 'package:flutter/material.dart';

import '../../infrastructure/services/biometric_lock_service.dart';

/// Exige autenticação local ao abrir o app e ao voltar do segundo plano, se a opção estiver ativa.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final BiometricLockService _lock = BiometricLockService();
  bool _locked = false;
  bool _ready = false;
  bool _fromBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _fromBackground = true;
    } else if (state == AppLifecycleState.resumed && _fromBackground) {
      _fromBackground = false;
      _lockAfterResume();
    }
  }

  Future<void> _bootstrap() async {
    final enabled = await _lock.isLockEnabled();
    if (!mounted) {
      return;
    }
    if (enabled) {
      setState(() {
        _locked = true;
        _ready = true;
      });
      await _promptUnlock();
    } else {
      setState(() {
        _locked = false;
        _ready = true;
      });
    }
  }

  Future<void> _lockAfterResume() async {
    final enabled = await _lock.isLockEnabled();
    if (!enabled || !mounted) {
      return;
    }
    setState(() => _locked = true);
    await _promptUnlock();
  }

  Future<void> _promptUnlock() async {
    final ok = await _lock.unlock();
    if (!mounted) {
      return;
    }
    setState(() => _locked = !ok);
    if (!ok) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Autenticação necessária para usar o app.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        IgnorePointer(ignoring: _locked, child: widget.child),
        if (_locked)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.92),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'App bloqueado',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Use sua biometria para continuar.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _promptUnlock,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Desbloquear'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
