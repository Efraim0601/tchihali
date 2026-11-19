import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/patient_repositories.dart';
import '../../l10n/gen/app_localizations.dart';
import 'chat_state.dart';

const _photoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 120" preserveAspectRatio="xMidYMid slice">
<rect width="200" height="120" fill="#D9C7AB"/><circle cx="100" cy="60" r="48" fill="#FFFFFF"/>
<circle cx="100" cy="60" r="38" fill="#F5EFE4"/><circle cx="90" cy="54" r="22" fill="#7A9A3E"/>
<ellipse cx="114" cy="72" rx="16" ry="10" fill="#F2EAD6"/><circle cx="118" cy="44" r="7" fill="#C97B4E"/></svg>''';

/// 12. Messagerie avec la diététicienne.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _draft = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _sendPhoto() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Tch.surface,
      barrierColor: const Color(0x732F3437),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TchButton(
              label: l.photoCamera,
              onPressed: () => Navigator.of(sheet).pop(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            TchButton(
              label: l.photoGallery,
              style: TchButtonStyle.secondary,
              onPressed: () => Navigator.of(sheet).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (x == null) return;
      final id = await ref
          .read(journalRepositoryProvider)
          .uploadPhoto(
            await x.readAsBytes(),
            kind: 'chat_photo',
            filename: x.name,
          );
      await ref.read(chatProvider.notifier).send('', photoFileId: id);
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    } catch (_) {
      // Permission refusée ou appareil photo indisponible : rien n'est envoyé.
    }
  }

  Future<void> _send() async {
    final text = _draft.text;
    if (text.trim().isEmpty) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(chatProvider.notifier).send(text);
    } on ApiException catch (e) {
      // Le texte reste dans le champ pour pouvoir réessayer.
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    _draft.clear();
    if (mounted) setState(() {});
    // La liste est inversée : 0 = dernier message.
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chat = ref.watch(chatProvider);
    final messages = chat.value ?? const <ChatMessage>[];
    String textOf(ChatMessage m) => switch (m.seed) {
      1 => l.msgM1,
      2 => l.msgM2,
      _ => m.text ?? '',
    };

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, Tch.topInset(context) - 4, 16, 12),
          decoration: const BoxDecoration(
            color: Tch.surface,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0D2F3437),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const TchAvatar(initials: 'EM', size: 48, radius: 16),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F9A5E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Tch.surface, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estelle Mbarga',
                      style: Tch.style(16, weight: FontWeight.w600),
                    ),
                    Text(
                      l.msgOnline,
                      style: Tch.style(12, color: Tch.greenDark2),
                    ),
                  ],
                ),
              ),
              PressScale(
                semanticLabel: l.msgCall,
                onTap: () => context.push('/video/waiting'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Tch.greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: TchIcon(
                      TchIcons.video,
                      size: 22,
                      color: Tch.greenDark2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: !chat.hasValue
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(Tch.pagePadding),
                  child: AsyncView<List<ChatMessage>>(
                    value: chat,
                    onRetry: () => ref.invalidate(chatProvider),
                    builder: (_) => const SizedBox.shrink(),
                  ),
                )
              : ListView.separated(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  // Index 0 = dernier message ; le dernier index = pastille « Aujourd'hui ».
                  itemCount: messages.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == messages.length) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Tch.segmented,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l.today,
                            style: Tch.style(
                              12,
                              weight: FontWeight.w500,
                              color: Tch.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }
                    final m = messages[messages.length - 1 - i];
                    return _Bubble(message: m, text: textOf(m));
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Row(
            children: [
              PressScale(
                semanticLabel: l.msgPhoto,
                onTap: _sendPhoto,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Tch.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D2F3437),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: TchIcon(
                      TchIcons.camera,
                      size: 22,
                      color: Tch.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TchTextField(
                  controller: _draft,
                  height: 48,
                  hint: l.msgWrite,
                  semanticLabel: l.msgWrite,
                  fontSize: 15,
                  horizontalPadding: 14,
                  onChanged: (_) => setState(() {}),
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
                    child: TchIcon(
                      TchIcons.send,
                      size: 20,
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends ConsumerWidget {
  const _Bubble({required this.message, required this.text});
  final ChatMessage message;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = message.fromMe;
    final maxW = MediaQuery.of(context).size.width * (mine ? 0.78 : 0.80);
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? Tch.green : Tch.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 6),
          bottomRight: Radius.circular(mine ? 6 : 18),
        ),
        boxShadow: mine
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D2F3437),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: Tch.style(
          15,
          color: mine ? Colors.white : Tch.text,
          height: 1.45,
        ),
      ),
    );
    return FadeSlideIn(
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.photo || message.photoFileId != null) ...[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(6),
                  ),
                  child: SizedBox(
                    width: 190,
                    height: 112,
                    child: message.photoFileId == null
                        ? SvgPicture.string(_photoSvg, fit: BoxFit.cover)
                        : ref
                              .watch(photoProvider(message.photoFileId!))
                              .maybeWhen(
                                data: (b) => b.isEmpty
                                    ? SvgPicture.string(
                                        _photoSvg,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.memory(
                                        b,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      ),
                                orElse: () =>
                                    const ColoredBox(color: Tch.segmented),
                              ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (text.isNotEmpty) bubble,
              if (message.time != null) ...[
                const SizedBox(height: 4),
                Text(
                  message.time!,
                  style: Tch.style(11, color: Tch.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
