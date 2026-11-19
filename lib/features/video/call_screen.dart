import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_icons.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/signup_state.dart';
import 'video_art.dart';
import 'video_state.dart';

/// 14. Téléconsultation (interface seulement : la vidéo viendra avec le backend).
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  // Le minuteur de la maquette affiche 12:48 ; il avance chaque seconde.
  int _seconds = 12 * 60 + 48;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = ref.watch(callControlsProvider);
    final n = ref.read(callControlsProvider.notifier);
    final name = ref.watch(signupProvider).name;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF2F3A33),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DietitianSceneArt(),
          Positioned(
            left: 16,
            right: 16,
            top: Tch.topInset(context) - 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB82F3437),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estelle Mbarga',
                        style: Tch.style(
                          15,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Pulse(
                            color: const Color(0xFFE8775F),
                            shape: BoxShape.circle,
                            spread: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8775F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${l.callLive} · $_clock',
                            style: Tch.style(12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 100,
                  height: 136,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B4A40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: c.cam
                      ? const SelfThumbArt()
                      : Center(
                          child: TchAvatar(
                            initials: initials,
                            size: 44,
                            radius: 22,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40 + (bottom > 40 ? bottom - 40 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundControl(
                  icon: TchIcons.mic,
                  label: l.waitMic,
                  on: c.mic,
                  onTap: n.toggleMic,
                ),
                _RoundControl(
                  icon: TchIcons.video,
                  label: l.waitCamera,
                  on: c.cam,
                  onTap: n.toggleCam,
                ),
                _RoundControl(
                  icon: TchIcons.messages,
                  label: l.navMessages,
                  on: true,
                  onTap: () => context.go('/messages'),
                ),
                PressScale(
                  semanticLabel: l.callHang,
                  onTap: () {
                    n.reset();
                    context.go('/profile/record');
                  },
                  child: Container(
                    width: 76,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Tch.danger,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: TchIcon(
                        TchIcons.phoneDown,
                        size: 28,
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
      ),
    );
  }
}

/// Bouton rond de la visio : translucide sombre, blanc avec icône rouge quand coupé.
class _RoundControl extends StatelessWidget {
  const _RoundControl({
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
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: on ? const Color(0x992F3437) : Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: TchIcon(icon, color: on ? Colors.white : Tch.danger),
      ),
    ),
  );
}
