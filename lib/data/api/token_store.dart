import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Jetons de session, chiffrés sur le téléphone (Keystore Android).
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;

  String? access;
  String? refresh;

  Future<void> load() async {
    access = await _s.read(key: 'access_token');
    refresh = await _s.read(key: 'refresh_token');
  }

  Future<void> save(String accessToken, String refreshToken) async {
    access = accessToken;
    refresh = refreshToken;
    await _s.write(key: 'access_token', value: accessToken);
    await _s.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clear() async {
    access = null;
    refresh = null;
    await _s.delete(key: 'access_token');
    await _s.delete(key: 'refresh_token');
  }

  bool get hasSession => refresh != null;
}
