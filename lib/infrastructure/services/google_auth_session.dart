import 'package:googleapis_auth/googleapis_auth.dart';

/// Mantém o cliente OAuth de desktop (Windows/Linux) até o logout.
class GoogleAuthSession {
  AutoRefreshingAuthClient? _desktop;

  bool get hasDesktopSession => _desktop != null;

  AutoRefreshingAuthClient? get desktopClient => _desktop;

  void adoptDesktopClient(AutoRefreshingAuthClient client) {
    closeDesktop();
    _desktop = client;
  }

  void closeDesktop() {
    _desktop?.close();
    _desktop = null;
  }
}
