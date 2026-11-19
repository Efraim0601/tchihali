import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/locale_provider.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_pill_switch.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../data/auth_repository.dart';
import '../auth/signup_state.dart';

const _menuPaths = [
  'M4 18l5-6 4 3 7-9',
  'M6 3h9l4 4v14H6zM9 12h7M9 16h5',
  'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z',
  'M6 9a6 6 0 0 1 12 0c0 6 2 7 2 7H4s2-1 2-7M10 20a2 2 0 0 0 4 0',
  'M12 17v.01M12 13a2 2 0 1 0-2-2M12 3a9 9 0 1 1 0 18 9 9 0 0 1 0-18z',
];
const _menuTints = [
  (Tch.greenLight, Tch.greenDark),
  (Tch.yellow, Tch.yellowText),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
  (Color(0xFFF3EFE8), Color(0xFF4A5054)),
];
// Destinations : progrès, carnet, infos de santé (questionnaire), notifications (reste ici), aide (messages).
const _menuRoutes = [
  '/profile/progress',
  '/profile/record',
  '/questionnaire/1',
  null,
  '/messages',
];

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
}

/// 18. Profil : identité, langue, liste, déconnexion.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _askLogout(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Tch.surface,
      barrierColor: const Color(0x732F3437),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Tch.border,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.profileSureTitle,
                textAlign: TextAlign.center,
                style: Tch.style(20, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            Text(l.profileSureText,
                textAlign: TextAlign.center,
                style: Tch.style(15, color: Tch.textSecondary, height: 1.5)),
            const SizedBox(height: 14),
            TchButton(
              label: l.profileLogout,
              style: TchButtonStyle.danger,
              height: 54,
              onPressed: () => Navigator.of(sheet).pop(true),
            ),
            const SizedBox(height: 14),
            TchButton(
              label: l.profileCancel,
              style: TchButtonStyle.neutral,
              height: 54,
              onPressed: () => Navigator.of(sheet).pop(false),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go('/onboarding/1');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(signupProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final labels = [
      l.profileProgress,
      l.profileRecord,
      l.profileHealth,
      l.profileNotifications,
      l.profileHelp,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          Tch.pagePadding, Tch.topInset(context), Tch.pagePadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text(l.profileTitle, style: Tch.style(28, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 1,
            child: TchCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TchAvatar(
                      initials: _initials(user.name), size: 60, radius: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: Tch.style(17, weight: FontWeight.w600)),
                        Text('+237 ${user.phone}',
                            style: Tch.style(13, color: Tch.textSecondary)),
                      ],
                    ),
                  ),
                  PressScale(
                    semanticLabel: l.profileEdit,
                    onTap: () => context.go('/signup'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                          child: TchIcon(TchIcons.edit, size: 20, color: Tch.text)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 2,
            child: TchCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _IconBox(TchIcons.globe, const Color(0xFFE3E8EE),
                          const Color(0xFF34495E)),
                      const SizedBox(width: 12),
                      Text(l.profileLanguage,
                          style: Tch.style(15, weight: FontWeight.w500)),
                    ],
                  ),
                  TchPillSwitch(
                    semanticLabel: l.profileLanguage,
                    labels: const ['Français', 'English'],
                    selectedIndex: lang == 'fr' ? 0 : 1,
                    onChanged: (i) => ref
                        .read(localeProvider.notifier)
                        .set(Locale(i == 0 ? 'fr' : 'en')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 3,
            child: TchCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    _MenuRow(
                      label: labels[i],
                      path: _menuPaths[i],
                      tint: _menuTints[i],
                      last: i == labels.length - 1,
                      onTap: _menuRoutes[i] == null
                          ? null
                          : () => context.go(_menuRoutes[i]!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 4,
            child: TchButton(
              label: l.profileLogout,
              style: TchButtonStyle.outlineSoft,
              height: 54,
              icon: const TchIcon(TchIcons.logout, size: 20, color: Tch.coralText),
              onPressed: () => _askLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.inner, this.bg, this.fg);
  final String inner;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
        child: TchIcon(inner, size: 20, color: fg),
      );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.path,
    required this.tint,
    required this.last,
    required this.onTap,
  });
  final String label;
  final String path;
  final (Color, Color) tint;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PressScale(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFF0EBE3))),
          ),
          child: Row(
            children: [
              _IconBox('<path d="$path"/>', tint.$1, tint.$2),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: Tch.style(15, weight: FontWeight.w500))),
              const TchIcon(TchIcons.chevronRight,
                  size: 18, color: Color(0xFFA7AAA6), strokeWidth: 2.2),
            ],
          ),
        ),
      );
}
