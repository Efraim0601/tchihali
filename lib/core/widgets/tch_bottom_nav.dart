import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'tch_icons.dart';

/// Barre du bas : Accueil, Agenda, Journal, Messages, Profil.
class TchBottomNav extends StatelessWidget {
  const TchBottomNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (TchIcons.home, l.navHome),
      (TchIcons.agenda, l.navAgenda),
      (TchIcons.journal, l.navJournal),
      (TchIcons.messages, l.navMessages),
      (TchIcons.profile, l.navProfile),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(
          6, 8, 6, 8 + MediaQuery.of(context).padding.bottom.clamp(0, 16)),
      decoration: const BoxDecoration(
        color: Tch.surface,
        border: Border(top: BorderSide(color: Tch.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavItem(
              icon: items[i].$1,
              label: items[i].$2,
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
    final color = active ? Tch.greenDark2 : Tch.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Tch.selectDuration,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: active ? Tch.greenLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TchIcon(icon, color: color),
            ),
            const SizedBox(height: 3),
            Text(label,
                style: Tch.style(11,
                    weight: active ? FontWeight.w700 : FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
