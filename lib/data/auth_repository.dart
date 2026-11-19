import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/auth_gate.dart';
import '../features/auth/signup_state.dart';
import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
  });
  final String id;
  final String phone;
  final String fullName;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
    id: j['id'] as String,
    phone: j['phone'] as String,
    fullName: j['full_name'] as String,
    role: j['role'] as String,
  );
}

/// Connexion par code SMS (pas de mot de passe).
abstract class AuthRepository {
  Future<void> requestCode({required String phone, required String name});
  Future<AuthUser> verify({required String phone, required String code});
  Future<AuthUser?> restore();
  Future<void> signOut();
}

/// Mode démo : aucun réseau, tout code de 6 chiffres est accepté.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._name);
  final String Function() _name;

  @override
  Future<void> requestCode({
    required String phone,
    required String name,
  }) async {}

  @override
  Future<AuthUser> verify({
    required String phone,
    required String code,
  }) async =>
      AuthUser(id: 'demo', phone: phone, fullName: _name(), role: 'patient');

  @override
  Future<AuthUser?> restore() async => null;

  @override
  Future<void> signOut() async {}
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> requestCode({
    required String phone,
    required String name,
  }) async {
    await _api.post(
      '/auth/request-code',
      body: {'phone': phone, 'name': name},
      auth: false,
    );
  }

  @override
  Future<AuthUser> verify({required String phone, required String code}) async {
    final j = await _api.post(
      '/auth/verify',
      body: {'phone': phone, 'code': code},
      auth: false,
    ) as Map<String, dynamic>;
    await _api.tokens.save(
      j['access_token'] as String,
      j['refresh_token'] as String,
    );
    final user = AuthUser.fromJson(j['user'] as Map<String, dynamic>);
    authGate.set(signedIn: true, role: user.role);
    return user;
  }

  @override
  Future<AuthUser?> restore() async {
    await _api.tokens.load();
    if (!_api.tokens.hasSession) return null;
    try {
      final j = await _api.get('/me') as Map<String, dynamic>;
      final user = AuthUser.fromJson(j);
      authGate.set(signedIn: true, role: user.role);
      return user;
    } on ApiException catch (e) {
      // Réseau coupé : on garde la session, on réessaiera. Session refusée : on repart de zéro.
      if (e.isNetwork) {
        authGate.set(signedIn: true);
        return null;
      }
      await _api.tokens.clear();
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final refresh = _api.tokens.refresh;
    if (refresh != null) {
      try {
        await _api.post('/auth/logout', body: {'refresh_token': refresh});
      } on ApiException {
        // Hors ligne : on supprime quand même la session sur ce téléphone.
      }
    }
    await _api.tokens.clear();
    authGate.set(signedIn: false);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ApiConfig.isConfigured) {
    final api = ref.watch(apiClientProvider);
    api.onSessionLost = () => authGate.set(signedIn: false);
    return ApiAuthRepository(api);
  }
  return MockAuthRepository(() => ref.read(signupProvider).name);
});
