import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/signup_state.dart';
import 'video_art.dart';
import 'video_state.dart';

/// Bouton rond micro / caméra : blanc quand actif, rouge quand coupé.
class CallToggle extends StatelessWidget {
  const CallToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });
  final String icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
        semanticLabel: label,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Tch.selectDuration,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: on ? Colors.white.withValues(alpha: 0.92) : Tch.danger,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: TchIcon(icon, color: on ? Tch.text : Colors.white)),
        ),
      );
}

String _initials(String name) {
  final p = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (p.isEmpty) return '';
  return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
}

/// 13. Salle d'attente : aperçu caméra, micro / caméra, arrivée de la diététicienne.
class WaitingRoomScreen extends ConsumerWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = ref.watch(callControlsProvider);
    final n = ref.read(callControlsProvider.notifier);
    final name = ref.watch(signupProvider).name;

    return Scaffold(
      backgroundColor: Tch.background,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, Tch.topInset(context) - 4, 20, 16 + MediaQuery.of(context).padding.bottom.clamp(18, 40)),
                child: Column(
                  children: [
                    FadeSlideIn(
                      child: Row(
                        children: [
                          PressScale(
                            semanticLabel: l.waitLeave,
                            onTap: () {
                              n.reset();
                              context.go('/home');
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Tch.surface,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: Tch.cardShadow,
                              ),
                              child: const Center(
                                  child: TchIcon(TchIcons.close,
                                      size: 22, color: Tch.text, strokeWidth: 2.2)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(l.waitTitle, style: Tch.style(22, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      index: 1,
                      child: Container(
                        height: 340,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B4A40),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (c.cam)
                              const SelfCamArt()
                            else
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TchAvatar(
                                      initials: _initials(name),
                                      size: 84,
                                      radius: 42,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(l.waitCamOff,
                                        style: Tch.style(14,
                                            weight: FontWeight.w500, color: Colors.white)),
                                  ],
                                ),
                              ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CallToggle(
                                    icon: TchIcons.mic,
                                    label: l.waitMic,
                                    on: c.mic,
                                    onTap: n.toggleMic,
                                  ),
                                  const SizedBox(width: 14),
                                  CallToggle(
                                    icon: TchIcons.video,
                                    label: l.waitCamera,
                                    on: c.cam,
                                    onTap: n.toggleCam,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      index: 2,
                      child: TchCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const TchAvatar(initials: 'EM', size: 52, radius: 18),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.waitComing,
                                      style: Tch.style(16, weight: FontWeight.w600)),
                                  Text(l.waitEta,
                                      style: Tch.style(14, color: Tch.textSecondary)),
                                ],
                              ),
                            ),
                            Pulse(
                              color: const Color(0xFFE9B949),
                              shape: BoxShape.circle,
                              spread: 10,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFE9B949), shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      index: 3,
                      child: TchButton(
                        label: l.waitEnter,
                        height: 58,
                        onPressed: () => context.go('/video/call'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
