import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/locale_provider.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_pill_switch.dart';
import '../../data/auth_repository.dart';
import '../../l10n/gen/app_localizations.dart';

/// Largeur à partir de laquelle le menu passe à gauche (sinon au-dessus du contenu).
const proWideBreakpoint = 820.0;

const _logo = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28"><circle cx="14" cy="14" r="14" fill="#4F7A5A"/>
<path d="M9 18c0-6 4-9 10-9 0 6-3 10-9 10" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>''';

/// Espace praticien : menu latéral commun + contenu (page web fluide).
class ProShell extends StatelessWidget {
  const ProShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Tch.background,
    body: LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= proWideBreakpoint;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 240,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: IntrinsicHeight(
                      child: _Sidebar(location: location, wide: true),
                    ),
                  ),
                ),
              ),
              Expanded(child: SingleChildScrollView(child: child)),
            ],
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              _Sidebar(location: location, wide: false),
              child,
            ],
          ),
        );
      },
    ),
  );
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.location, required this.wide});
  final String location;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(localeProvider).languageCode;
    final items = [
      (TchIcons.agenda, l.proAgenda, '/pro/agenda', '/pro/agenda'),
      (TchIcons.patients, l.proPatients, '/pro/patients', '/pro/patients'),
      (TchIcons.report, l.proReports, '/pro/reports', '/pro/reports'),
      (TchIcons.messages, l.proMessages, '/pro/messages', '/pro/messages'),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        wide ? 28 : MediaQuery.of(context).padding.top + 20,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        color: Tch.surface,
        border: Border(right: BorderSide(color: Tch.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.string(_logo, width: 32, height: 32),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.appName,
                    style: Tch.style(15, weight: FontWeight.w700),
                  ),
                  Text(
                    l.proSpace,
                    style: Tch.style(12, color: Tch.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final it in items) ...[
            _NavLink(
              icon: it.$1,
              label: it.$2,
              active: location.startsWith(it.$4),
              onTap: () => context.go(it.$3),
            ),
            const SizedBox(height: 4),
          ],
          if (wide) const Spacer() else const SizedBox(height: 20),
          TchPillSwitch(
            semanticLabel: l.profileLanguage,
            expand: true,
            labels: const ['Français', 'English'],
            selectedIndex: lang == 'fr' ? 0 : 1,
            onChanged: (i) => ref
                .read(localeProvider.notifier)
                .set(Locale(i == 0 ? 'fr' : 'en')),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Tch.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const TchAvatar(initials: 'EM', size: 42, radius: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estelle Mbarga',
                        style: Tch.style(14, weight: FontWeight.w600),
                      ),
                      Text(
                        l.proRole,
                        style: Tch.style(12, color: Tch.textSecondary),
                      ),
                    ],
                  ),
                ),
                PressScale(
                  semanticLabel: l.profileLogout,
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) context.go('/onboarding/1');
                  },
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: TchIcon(
                        TchIcons.logout,
                        size: 20,
                        color: Tch.coralText,
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

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Tch.greenDark : const Color(0xFF4A5054);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Tch.selectDuration,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? Tch.greenLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            TchIcon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: Tch.style(
                15,
                weight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
