import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../application/contracts/auth_contracts.dart';
import '../../domain/entities/finance_entities.dart';
import '../config/google_oauth_config.dart';
import 'google_auth_session.dart';
import 'google_desktop_sign_in.dart'
    if (dart.library.html) 'google_desktop_sign_in_stub.dart' as google_desktop;

class AuthService implements IAuthService {
  AuthService({
    required GoogleSignIn googleSignIn,
    required GoogleAuthSession googleAuthSession,
  }) : _googleSignIn = googleSignIn,
       _googleAuthSession = googleAuthSession;

  final GoogleSignIn _googleSignIn;
  final GoogleAuthSession _googleAuthSession;

  GoogleSignIn get googleSignIn => _googleSignIn;

  bool _useDesktopOAuth() {
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

  Future<({String id, String email, String displayName})> _userInfoFromClient(
    AuthClient client,
  ) async {
    final response = await client.get(
      Uri.https('www.googleapis.com', '/oauth2/v2/userinfo'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Não foi possível obter o perfil Google (HTTP ${response.statusCode}).',
      );
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final email = map['email'] as String? ?? '';
    final id = map['id'] as String? ?? email;
    final name = map['name'] as String? ?? email.split('@').first;
    return (id: id, email: email, displayName: name);
  }

  @override
  Future<UserSession> loginWithGmail() async {
    if (_useDesktopOAuth()) {
      final clientId = readGoogleOAuthDesktopClientId();
      if (clientId == null) {
        throw Exception(
          'No Windows/Linux defina o cliente OAuth Desktop ao compilar, por exemplo:\n'
          'flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID=XXXX.apps.googleusercontent.com\n'
          '(Crie um ID do tipo "Desktop" em APIs e serviços > Credenciais no Google Cloud.)',
        );
      }

      final client = await google_desktop.signInWithGoogleForDrive(
        clientId: clientId,
        scopes: googleOAuthDriveScopes(),
      );
      try {
        final info = await _userInfoFromClient(client);
        final session = UserSession(
          userId: info.id,
          displayName: info.displayName,
          email: info.email,
          authProvider: AuthProvider.gmail,
          loggedAt: DateTime.now(),
        );
        _googleAuthSession.adoptDesktopClient(client);
        return session;
      } catch (_) {
        client.close();
        rethrow;
      }
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Login com Gmail cancelado.');
    }

    return UserSession(
      userId: account.id,
      displayName: account.displayName ?? account.email.split('@').first,
      email: account.email,
      authProvider: AuthProvider.gmail,
      loggedAt: DateTime.now(),
    );
  }

  @override
  Future<UserSession> loginWithOutlook({
    required String email,
    required String oneDriveAccessToken,
  }) async {
    if (email.trim().isEmpty) {
      throw Exception('Informe o e-mail da conta Outlook.');
    }
    if (oneDriveAccessToken.trim().isEmpty) {
      throw Exception('Informe o token do OneDrive para habilitar o backup.');
    }

    return UserSession(
      userId: email.trim().toLowerCase(),
      displayName: email.trim().split('@').first,
      email: email.trim(),
      authProvider: AuthProvider.outlook,
      loggedAt: DateTime.now(),
      oneDriveAccessToken: oneDriveAccessToken.trim(),
    );
  }

  @override
  Future<void> logout() async {
    _googleAuthSession.closeDesktop();
    if (!_useDesktopOAuth()) {
      await _googleSignIn.signOut();
    }
  }
}
