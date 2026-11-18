import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_chip.dart';
import '../../core/widgets/tch_icons.dart';
import '../../l10n/gen/app_localizations.dart';

const _mealSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 326 150" preserveAspectRatio="xMidYMid slice">
<rect width="326" height="150" fill="#D9C7AB"/><path d="M0 110h326v40H0z" fill="#C9B391"/>
<circle cx="163" cy="78" r="68" fill="#FFFFFF"/><circle cx="163" cy="78" r="56" fill="#F5EFE4"/>
<ellipse cx="144" cy="64" rx="28" ry="21" fill="#F3E3B8"/>
<ellipse cx="182" cy="90" rx="28" ry="11" fill="#C97B4E" transform="rotate(-18 182 90)"/>
<circle cx="142" cy="102" r="10" fill="#7FA77F"/><circle cx="156" cy="110" r="8" fill="#5E8A62"/>
<circle cx="192" cy="56" r="8" fill="#E8775F"/></svg>''';

const _mouths = [
  'M10 21c3-3 7-3 10 0',
  'M10 20c3-1.5 7-1.5 10 0',
  'M10 19h10',
  'M10 18c3 2 7 2 10 0',
  'M9 17c3 4 9 4 12 0',
];

/// 10. Journal alimentaire.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _dayOffset = 0; // 0 = aujourd'hui, négatif = jours passés
  int _mood = 3;
  final _symptoms = <int>{0};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final moods = [l.mood1, l.mood2, l.mood3, l.mood4, l.mood5];
    final syms = [l.sym1, l.sym2, l.sym3, l.sym4];
    final day = DateTime.now().add(Duration(days: _dayOffset));
    final dayLabel = _dayOffset == 0
        ? l.today
        : DateFormat.MMMEd(locale).format(day);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                Tch.pagePadding, Tch.topInset(context), Tch.pagePadding, 8),
            child: FadeSlideIn(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.journalTitle, style: Tch.style(28, weight: FontWeight.w700)),
                  PressScale(
                    onTap: () => context.go('/journal/recipes'),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Tch.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0F2F3437),
                              blurRadius: 10,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          const TchIcon(TchIcons.book, size: 18, color: Tch.text),
                          const SizedBox(width: 6),
                          Text(l.journalRecipes,
                              style: Tch.style(14, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Tch.pagePadding, 0, Tch.pagePadding, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DayArrow(
                  icon: TchIcons.chevronLeft,
                  label: l.journalPrevDay,
                  color: Tch.textSecondary,
                  onTap: () => setState(() => _dayOffset--),
                ),
                Column(
                  children: [
                    Text(dayLabel, style: Tch.style(15, weight: FontWeight.w600)),
                    Text(l.journalKcalDay,
                        style: Tch.style(13, color: Tch.textSecondary)),
                  ],
                ),
                _DayArrow(
                  icon: TchIcons.chevronRight,
                  label: l.journalNextDay,
                  color: _dayOffset < 0 ? Tch.textSecondary : Tch.checkBorder,
                  onTap: _dayOffset < 0 ? () => setState(() => _dayOffset++) : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Tch.pagePadding, 4, Tch.pagePadding, 0),
            child: Column(
              children: [
                FadeSlideIn(
                  index: 1,
                  child: TchCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SvgPicture.string(_mealSvg, fit: BoxFit.cover),
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('${l.journalLunch} · 13:05',
                                        style: Tch.style(12,
                                            weight: FontWeight.w600,
                                            color: Tch.greenDark)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(l.journalDish,
                                    style: Tch.style(16, weight: FontWeight.w600)),
                              ),
                              Text.rich(TextSpan(
                                text: '540 ',
                                style: Tch.style(18, weight: FontWeight.w700),
                                children: [
                                  TextSpan(
                                    text: 'kcal',
                                    style: Tch.style(12,
                                        weight: FontWeight.w500,
                                        color: Tch.textSecondary),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _Macro(l.journalProt, '32 g', 0.72, Tch.green)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _Macro(l.journalCarbs, '68 g', 0.58,
                                      const Color(0xFFE9B949))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _Macro(l.journalFat, '14 g', 0.34, Tch.coral)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 2,
                  child: SizedBox(
                    width: double.infinity,
                    child: TchCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.journalMood,
                              style: Tch.style(15, weight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var i = 0; i < 5; i++)
                                _MoodFace(
                                  mouth: _mouths[i],
                                  label: moods[i],
                                  on: i == _mood,
                                  onTap: () => setState(() => _mood = i),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(l.journalSymptoms,
                              style: Tch.style(15, weight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (var i = 0; i < syms.length; i++)
                                TchChip(
                                  label: syms[i],
                                  selected: _symptoms.contains(i),
                                  background: Tch.background,
                                  onTap: () => setState(() => _symptoms.contains(i)
                                      ? _symptoms.remove(i)
                                      : _symptoms.add(i)),
                                ),
                            ],
                          ),
                        ],
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

class _DayArrow extends StatelessWidget {
  const _DayArrow(
      {required this.icon, required this.label, required this.color, this.onTap});
  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
                child: TchIcon(icon, size: 20, color: color, strokeWidth: 2.2)),
          ),
        ),
      );
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.value, this.fraction, this.color);
  final String label;
  final String value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Tch.style(12, weight: FontWeight.w500)),
              Text(value, style: Tch.style(12, weight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 5),
          GrowBar(fraction: fraction, color: color),
        ],
      );
}

class _MoodFace extends StatelessWidget {
  const _MoodFace(
      {required this.mouth, required this.label, required this.on, required this.onTap});
  final String mouth;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = on ? Tch.coralText : Tch.textSecondary;
    final hex = colorHex(color);
    final reduced = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      selected: on,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: on ? 1.08 : 1,
          duration: reduced ? Duration.zero : Tch.selectDuration,
          child: AnimatedContainer(
            duration: Tch.selectDuration,
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? Tch.peachLight : const Color(0xFFF5F1EA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TchIcon(
              '<circle cx="15" cy="15" r="12"/>'
              '<circle cx="11" cy="12.5" r="0.9" fill="$hex"/>'
              '<circle cx="19" cy="12.5" r="0.9" fill="$hex"/>'
              '<path d="$mouth"/>',
              size: 30,
              viewBox: 30,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
