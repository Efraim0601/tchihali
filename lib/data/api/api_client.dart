import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_store.dart';

/// Erreur renvoyée par l'API. `status` 0 = pas de réseau.
class ApiException implements Exception {
  ApiException(this.status, this.message);
  final int status;
  final String message;

  bool get isNetwork => status == 0;
  bool get isConflict => status == 409;
  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'ApiException($status): $message';
}

/// Client HTTP de l'API : ajoute le jeton, le renouvelle automatiquement en cas de 401.
class ApiClient {
  ApiClient(this.tokens, {http.Client? client, String? baseUrl})
    : _http = client ?? http.Client(),
      _base = baseUrl ?? ApiConfig.baseUrl;

  final TokenStore tokens;
  final http.Client _http;
  final String _base;

  /// Appelé quand la session ne peut plus être renouvelée (déconnexion forcée).
  void Function()? onSessionLost;

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);
  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);
  Future<dynamic> delete(String path, {Map<String, String>? query}) =>
      _send('DELETE', path, query: query);

  /// Télécharge un fichier protégé (photo, PDF) avec le jeton de session.
  Future<Uint8List> getBytes(String path) async {
    Future<http.Response> once() async {
      final req = http.Request('GET', Uri.parse('$_base/v1$path'))
        ..headers.addAll({
          if (tokens.access != null) 'Authorization': 'Bearer ${tokens.access}',
        });
      try {
        return await http.Response.fromStream(
          await _http.send(req).timeout(const Duration(seconds: 30)),
        );
      } on TimeoutException {
        throw ApiException(0, 'timeout');
      } on http.ClientException catch (e) {
        throw ApiException(0, e.message);
      }
    }

    var res = await once();
    if (res.statusCode == 401 && tokens.refresh != null && await _refresh()) {
      res = await once();
    }
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, 'Erreur ${res.statusCode}');
    }
    return res.bodyBytes;
  }

  /// Envoie une photo (multipart) ; renvoie l'identifiant du fichier créé.
  Future<String> uploadImage(
    Uint8List bytes, {
    required String kind,
    required String filename,
  }) async {
    Future<http.Response> once() async {
      final req = http.MultipartRequest('POST', Uri.parse('$_base/v1/files'))
        ..fields['kind'] = kind
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        )
        ..headers.addAll({
          if (tokens.access != null) 'Authorization': 'Bearer ${tokens.access}',
        });
      try {
        return await http.Response.fromStream(
          await _http.send(req).timeout(const Duration(seconds: 60)),
        );
      } on TimeoutException {
        throw ApiException(0, 'timeout');
      } on http.ClientException catch (e) {
        throw ApiException(0, e.message);
      }
    }

    var res = await once();
    if (res.statusCode == 401 && tokens.refresh != null && await _refresh()) {
      res = await once();
    }
    final json = _decode(res);
    return (json as Map<String, dynamic>)['id'] as String;
  }

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    var res = await _raw(method, path, body: body, query: query, auth: auth);
    if (res.statusCode == 401 && auth && tokens.refresh != null) {
      if (await _refresh()) {
        res = await _raw(method, path, body: body, query: query, auth: auth);
      } else {
        await tokens.clear();
        onSessionLost?.call();
      }
    }
    return _decode(res);
  }

  Future<http.Response> _raw(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_base/v1$path').replace(queryParameters: query);
    final headers = {
      'Content-Type': 'application/json',
      if (auth && tokens.access != null)
        'Authorization': 'Bearer ${tokens.access}',
    };
    final req = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) req.body = jsonEncode(body);
    try {
      final streamed = await _http
          .send(req)
          .timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException(0, 'timeout');
    } on http.ClientException catch (e) {
      throw ApiException(0, e.message);
    }
  }

  Completer<bool>? _refreshing;

  /// Une seule requête de renouvellement à la fois, même si plusieurs appels échouent ensemble.
  Future<bool> _refresh() {
    final running = _refreshing;
    if (running != null) return running.future;
    final c = _refreshing = Completer<bool>();
    () async {
      try {
        final res = await _raw(
          'POST',
          '/auth/refresh',
          body: {'refresh_token': tokens.refresh},
          auth: false,
        );
        if (res.statusCode == 200) {
          final j = jsonDecode(res.body) as Map<String, dynamic>;
          await tokens.save(
            j['access_token'] as String,
            j['refresh_token'] as String,
          );
          c.complete(true);
        } else {
          c.complete(false);
        }
      } catch (_) {
        c.complete(false);
      } finally {
        _refreshing = null;
      }
    }();
    return c.future;
  }

  dynamic _decode(http.Response res) {
    final text = utf8.decode(res.bodyBytes);
    final json = text.isEmpty ? null : jsonDecode(text);
    if (res.statusCode >= 400) {
      var msg = 'Erreur ${res.statusCode}';
      if (json is Map && json['detail'] is String) {
        msg = json['detail'] as String;
      } else if (json is Map &&
          json['detail'] is List &&
          (json['detail'] as List).isNotEmpty) {
        msg = ((json['detail'] as List).first['msg'] ?? msg).toString();
      }
      throw ApiException(res.statusCode, msg);
    }
    return json;
  }
}
