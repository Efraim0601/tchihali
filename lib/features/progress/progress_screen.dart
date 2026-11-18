import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_curve.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_segmented.dart';
import '../../data/progress_data.dart';
import '../../l10n/gen/app_localizations.dart';

/// 11. Progrès : poids / IMC / tour de taille, courbe et badges.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final s = progressSeries[_tab];
    String fmt(double v) => fr ? v.toStringAsFixed(1).replaceAll('.', ',') : v.toStringAsFixed(1);
    final unit = s.unit.isEmpty ? '' : ' ${s.unit}';
    final last = s.data.last;
    final delta = '−${fmt(s.data.first - last)}$unit ${l.progSince}';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          Tch.pagePadding, Tch.topInset(context), Tch.pagePadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                TchBackButton(onTap: () => context.go('/profile')),
                const SizedBox(width: 12),
                Text(l.progTitle, style: Tch.style(24, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 1,
            child: TchSegmented(
              labels: [l.progTabWeight, l.progTabBmi, l.progTabWaist],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 2,
            child: TchCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.today, style: Tch.style(13, color: Tch.textSecondary)),
                          Text.rich(TextSpan(
                            text: fmt(last),
                            style: Tch.style(32, weight: FontWeight.w700, height: 1.1),
                            children: [
                              if (s.unit.isNotEmpty)
                                TextSpan(
                                  text: ' ${s.unit}',
                                  style: Tch.style(15,
                                      weight: FontWeight.w500, color: Tch.textSecondary),
                                ),
                            ],
                          )),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Tch.greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(delta,
                            style: Tch.style(13,
                                weight: FontWeight.w600, color: Tch.greenDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TchCurve(
                    key: ValueKey(_tab),
                    data: s.data,
                    min: s.min,
                    max: s.max,
                    goal: s.goal,
                    goalLabel: '${l.progGoal} ${fmt(s.goal)}$unit',
                    semanticLabel:
                        '${l.progTitle} — ${[l.progTabWeight, l.progTabBmi, l.progTabWaist][_tab]}',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.progStart, style: Tch.style(11, color: Tch.textSecondary)),
                        Text(l.progEnd, style: Tch.style(11, color: Tch.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 3,
            child: Text(l.progBadges, style: Tch.style(17, weight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          FadeSlideIn(
            index: 4,
            child: Row(
              children: [
                Expanded(
                    child: _Badge(TchIcons.leaf, Tch.greenLight, Tch.greenDark2, l.progB1)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Badge(
                        TchIcons.flame, Tch.peachLight, Tch.coralText, l.progB2)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Badge(
                        TchIcons.award, Tch.yellow, const Color(0xFF7A5C00), l.progB3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.bg, this.fg, this.label);
  final String icon;
  final Color bg;
  final Color fg;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: Tch.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x0D2F3437), blurRadius: 10, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Center(child: TchIcon(icon, color: fg)),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: Tch.style(12, weight: FontWeight.w500, height: 1.3)),
          ],
        ),
      );
}
