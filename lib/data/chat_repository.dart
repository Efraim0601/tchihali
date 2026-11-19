import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';

/// Message de la conversation. `seed` = 1 ou 2 : messages d'exemple (mode démo), traduits par l'écran.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.fromMe,
    this.text,
    this.seed,
    this.time,
    this.photo = false,
    this.photoFileId,
  });
  final int id;
  final bool fromMe;
  final String? text;
  final int? seed;
  final String? time;
  final bool photo;

  /// Photo envoyée par l'API (téléchargée avec le jeton).
  final String? photoFileId;
}

abstract class ChatRepository {
  /// Messages après [afterId] (0 = tous).
  Future<List<ChatMessage>> fetch(String dietitianId, {int afterId = 0});
  Future<ChatMessage> send(
    String dietitianId,
    String text, {
    String? photoFileId,
  });
}

class MockChatRepository implements ChatRepository {
  final _sent = <ChatMessage>[];

  @override
  Future<List<ChatMessage>> fetch(
    String dietitianId, {
    int afterId = 0,
  }) async => [
    const ChatMessage(id: 1, fromMe: true, seed: 1, time: '09:12', photo: true),
    const ChatMessage(id: 2, fromMe: false, seed: 2, time: '10:40'),
    ..._sent,
  ].where((m) => m.id > afterId).toList();

  @override
  Future<ChatMessage> send(
    String dietitianId,
    String text, {
    String? photoFileId,
  }) async {
    final m = ChatMessage(
      id: 100 + _sent.length,
      fromMe: true,
      text: text.trim(),
      photo: photoFileId != null,
    );
    _sent.add(m);
    return m;
  }
}

class ApiChatRepository implements ChatRepository {
  ApiChatRepository(this._api);
  final ApiClient _api;

  ChatMessage _msg(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] as int,
    fromMe: j['from_me'] as bool,
    text: j['body'] as String,
    photoFileId: j['photo_file_id'] as String?,
    time: DateFormat('HH:mm')
        .format(DateTime.parse(j['created_at'] as String).toLocal()),
  );

  @override
  Future<List<ChatMessage>> fetch(String dietitianId, {int afterId = 0}) async {
    final list = await _api.get(
      '/messages',
      query: {'dietitian_id': dietitianId, 'after_id': '$afterId'},
    ) as List;
    return [for (final j in list.cast<Map<String, dynamic>>()) _msg(j)];
  }

  @override
  Future<ChatMessage> send(
    String dietitianId,
    String text, {
    String? photoFileId,
  }) async => _msg(
    await _api.post(
      '/messages',
      body: {
        'dietitian_id': dietitianId,
        'body': text,
        'photo_file_id': ?photoFileId,
      },
    ) as Map<String, dynamic>,
  );
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiChatRepository(ref.watch(apiClientProvider))
      : MockChatRepository(),
);
