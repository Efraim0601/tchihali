import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/chat_repository.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

EdgeInsets _pad(BuildContext context) {
  final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
  return EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28);
}

/// Liste des conversations avec les patients.
class ProConversationsScreen extends ConsumerWidget {
  const ProConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: _pad(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text(
              l.proMessages,
              style: Tch.style(30, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 18),
          AsyncView<List<Conversation>>(
            value: ref.watch(proConversationsProvider),
            onRetry: () => ref.invalidate(proConversationsProvider),
            builder: (list) => list.isEmpty
                ? TchCard(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        l.proNoConversations,
                        textAlign: TextAlign.center,
                        style: Tch.style(15, color: Tch.textSecondary),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        PressScale(
                          onTap: () =>
                              context.go('/pro/messages/${list[i].patientId}'),
                          child: TchCard(
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                TchAvatar(
                                  initials: list[i].patient.isEmpty
                                      ? '?'
                                      : list[i].patient[0].toUpperCase(),
                                  size: 44,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        list[i].patient,
                                        style: Tch.style(
                                          15,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        list[i].last.isEmpty
                                            ? '📷'
                                            : list[i].last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Tch.style(
                                          13,
                                          weight: list[i].fromPatient
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: Tch.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat.MMMd(locale).format(list[i].at),
                                  style: Tch.style(
                                    12,
                                    color: Tch.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Conversation avec un patient (rafraîchie toutes les 5 s).
class ProChatScreen extends ConsumerStatefulWidget {
  const ProChatScreen({super.key, required this.patientId});
  final String patientId;

  @override
  ConsumerState<ProChatScreen> createState() => _ProChatScreenState();
}

class _ProChatScreenState extends ConsumerState<ProChatScreen> {
  final _draft = TextEditingController();
  List<ChatMessage>? _messages;
  Object? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _draft.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final m = await ref
          .read(proRepositoryProvider)
          .messages(widget.patientId);
      if (mounted) setState(() => _messages = m);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _poll() async {
    final cur = _messages;
    if (cur == null) return;
    try {
      final fresh = await ref
          .read(proRepositoryProvider)
          .messages(widget.patientId, afterId: cur.isEmpty ? 0 : cur.last.id);
      if (fresh.isNotEmpty && mounted) {
        setState(() => _messages = [...cur, ...fresh]);
      }
    } on ApiException {
      // Réseau coupé : prochain tour.
    }
  }

  Future<void> _send() async {
    final text = _draft.text.trim();
    if (text.isEmpty) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final m = await ref
          .read(proRepositoryProvider)
          .sendMessage(widget.patientId, text);
      _draft.clear();
      if (mounted) setState(() => _messages = [...?_messages, m]);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final msgs = _messages;
    return Padding(
      padding: _pad(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PressScale(
                semanticLabel: l.back,
                onTap: () => context.go('/pro/messages'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Tch.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: Tch.cardShadow,
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back, size: 22, color: Tch.text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.proMessages,
                style: Tch.style(24, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (msgs == null)
            AsyncView<void>(
              value: _error == null
                  ? const AsyncLoading<void>()
                  : AsyncError<void>(_error!, StackTrace.empty),
              onRetry: () {
                setState(() => _error = null);
                _load();
              },
              builder: (_) => const SizedBox.shrink(),
            )
          else
            for (final m in msgs)
              Align(
                alignment: m.fromMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: m.fromMe ? Tch.green : Tch.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: m.fromMe ? null : Tch.cardShadow,
                  ),
                  child: Text(
                    m.text?.isNotEmpty == true ? m.text! : '📷',
                    style: Tch.style(
                      15,
                      color: m.fromMe ? Colors.white : Tch.text,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TchTextField(
                  controller: _draft,
                  height: 48,
                  hint: l.msgWrite,
                  semanticLabel: l.msgWrite,
                  fontSize: 15,
                  horizontalPadding: 14,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              PressScale(
                semanticLabel: l.msgSend,
                onTap: _send,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Tch.coral,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.send, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
