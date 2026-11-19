import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_client.dart';
import '../../data/chat_repository.dart';

export '../../data/chat_repository.dart' show ChatMessage;

/// Diététicienne avec qui la patiente échange (une seule conversation pour l'instant).
const chatDietitianId = 'estelle';

/// Conversation : se rafraîchit toute seule toutes les 5 s tant que l'écran est ouvert.
class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  Timer? _timer;

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() => _timer?.cancel());
    final first = await ref.read(chatRepositoryProvider).fetch(chatDietitianId);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    return first;
  }

  Future<void> _poll() async {
    final current = state.value;
    if (current == null) return;
    try {
      final last = current.isEmpty ? 0 : current.last.id;
      final fresh = await ref.read(chatRepositoryProvider).fetch(chatDietitianId, afterId: last);
      if (fresh.isNotEmpty) state = AsyncData([...current, ...fresh]);
    } on ApiException {
      // Réseau coupé : on réessaiera au prochain tour.
    }
  }

  /// Envoie un message ; lève [ApiException] si l'envoi échoue (le texte n'est alors pas perdu côté écran).
  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final sent = await ref.read(chatRepositoryProvider).send(chatDietitianId, t);
    state = AsyncData([...?state.value, sent]);
  }
}

final chatProvider =
    AsyncNotifierProvider.autoDispose<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
