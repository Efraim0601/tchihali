import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_segmented.dart';
import '../../l10n/gen/app_localizations.dart';

const _mealTints = [
  (Tch.yellow, Tch.yellowText),
  (Tch.greenLight, Color(0xFF24412D)),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

/// 15. Carnet de suivi : séance, plan alimentaire, documents.
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final meals = [
      (l.recMealTime1, l.recMealLabel1, l.recMealText1),
      (l.recMealTime2, l.recMealLabel2, l.recMealText2),
      (l.recMealTime3, l.recMealLabel3, l.recMealText3),
      (l.recMealTime4, l.recMealLabel4, l.recMealText4),
    ];
    final docs = [
      (l.recDoc1, l.recDoc1Meta),
      (l.recDoc2, l.recDoc2Meta),
      (l.recDoc3, l.recDoc3Meta),
    ];

    final Widget content = switch (_tab) {
      0 => TchCard(
          key: const ValueKey('session'),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.recSession,
                  style: Tch.style(12, weight: FontWeight.w500, color: Tch.textSecondary)),
              Text(l.recDate, style: Tch.style(17, weight: FontWeight.w600)),
              const SizedBox(height: 14),
              Text(l.recSummary,
                  style: Tch.style(15, color: const Color(0xFF4A5054), height: 1.6)),
              const SizedBox(height: 14),
              Text(l.recGoalsTitle, style: Tch.style(15, weight: FontWeight.w600)),
              const SizedBox(height: 10),
              for (final g in [l.recGoal1, l.recGoal2, l.recGoal3])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 9, right: 10),
                        decoration:
                            const BoxDecoration(color: Tch.green, shape: BoxShape.circle),
                      ),
                      Expanded(child: Text(g, style: Tch.style(15, height: 1.45))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      1 => Column(
          key: const ValueKey('plan'),
          children: [
            for (var i = 0; i < meals.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              TchCard(
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _mealTints[i].$1,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(meals[i].$1,
                          style: Tch.style(12,
                              weight: FontWeight.w600, color: _mealTints[i].$2)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meals[i].$2,
                              style: Tch.style(12,
                                  weight: FontWeight.w500, color: Tch.textSecondary)),
                          Text(meals[i].$3, style: Tch.style(15, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      _ => Column(
          key: const ValueKey('docs'),
          children: [
            for (var i = 0; i < docs.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              TchCard(
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Tch.greenLight,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                          child: TchIcon(
                              '<path d="M6 3h9l4 4v14H6z"/><path d="M9 12h7M9 16h5"/>',
                              size: 20,
                              color: Tch.greenDark)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(docs[i].$1, style: Tch.style(15, weight: FontWeight.w500)),
                          Text(docs[i].$2,
                              style: Tch.style(12, color: Tch.textSecondary)),
                        ],
                      ),
                    ),
                    PressScale(
                      semanticLabel: l.recDownload,
                      onTap: () {}, // Téléchargement : à brancher avec le backend
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1EA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                            child: TchIcon(TchIcons.download, size: 20, color: Tch.text)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
    };

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
                Text(l.recTitle, style: Tch.style(24, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 1,
            child: TchSegmented(
              labels: [l.recTabSession, l.recTabPlan, l.recTabDocs],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: Tch.selectDuration,
            child: SizedBox(key: ValueKey(_tab), width: double.infinity, child: content),
          ),
        ],
      ),
    );
  }
}
