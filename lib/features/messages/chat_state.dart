import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Message de la conversation. `seed` = 1 ou 2 : messages d'exemple traduits par l'écran.
class ChatMessage {
  const ChatMessage({required this.fromMe, this.text, this.seed, this.time, this.photo = false});
  final bool fromMe;
  final String? text;
  final int? seed;
  final String? time;
  final bool photo;
}

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => const [
        ChatMessage(fromMe: true, seed: 1, time: '09:12', photo: true),
        ChatMessage(fromMe: false, seed: 2, time: '10:40'),
      ];

  void send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    state = [...state, ChatMessage(fromMe: true, text: t)];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
