import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_curve.dart';
import '../../data/pro_data.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

EdgeInsets _pagePadding(BuildContext context) {
  final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
  return EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28);
}

/// 20. Praticien — Fiche patient : indicateurs, courbe de poids, derniers repas, notes.
class ProPatientScreen extends StatefulWidget {
  const ProPatientScreen({super.key, required this.id});
  final String id;

  @override
  State<ProPatientScreen> createState() => _ProPatientScreenState();
}

class _ProPatientScreenState extends State<ProPatientScreen> {
  TextEditingController? _note;

  @override
  void dispose() {
    _note?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    _note ??= TextEditingController(text: patientNote.of(locale));
    final kpiLabels = [l.proKpiWeight, l.proKpiWaist, l.proKpiGlucose];

    final chart = FadeSlideIn(
      index: 2,
      child: TchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.proChart, style: Tch.style(17, weight: FontWeight.w600)),
            const SizedBox(height: 8),
            TchCurve(
              data: patientWeights,
              min: 74,
              max: 85,
              goal: 75,
              goalLabel: l.proChartGoal,
              semanticLabel: l.proChart,
              height: 200,
              hollowDot: false,
              labelSize: 12,
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
    );

    final meals = FadeSlideIn(
      index: 3,
      child: TchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.proMeals, style: Tch.style(17, weight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final m in patientMeals) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: m.late ? Tch.peachLight : Tch.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.text.of(locale),
                              style: Tch.style(14, weight: FontWeight.w500)),
                          Text(m.when.of(locale),
                              style: Tch.style(12, color: Tch.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${m.kcal} kcal', style: Tch.style(13, weight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: _pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: TchCard(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 18,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tch.peach,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text('NN',
                        style: Tch.style(22,
                            weight: FontWeight.w700, color: const Color(0xFF7A3522))),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 220, maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nadège Ngono', style: Tch.style(24, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(patientInfo.of(locale),
                            style: Tch.style(14, color: Tch.textSecondary)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(patientTag1.of(locale), Tch.peachLight, const Color(0xFF8A3A24)),
                            _Tag(patientTag2.of(locale), Tch.yellow, Tch.yellowText),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PressScale(
                    onTap: () => context.go('/pro/reports/${widget.id}'),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Tch.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(l.proWrite,
                          style:
                              Tch.style(14, weight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 1,
            child: LayoutBuilder(
              builder: (context, box) {
                final cols = ((box.maxWidth + 12) / (180 + 12)).floor().clamp(1, 3);
                final w = (box.maxWidth - 12 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < patientKpis.length; i++)
                      SizedBox(
                        width: w,
                        child: TchCard(
                          radius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(kpiLabels[i],
                                  style: Tch.style(13, color: Tch.textSecondary)),
                              Text(patientKpis[i].value.of(locale),
                                  style: Tch.style(24, weight: FontWeight.w700)),
                              Text(patientKpis[i].delta.of(locale),
                                  style: Tch.style(13,
                                      weight: FontWeight.w500, color: Tch.greenDark)),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 18),
                      Expanded(flex: 2, child: meals),
                    ],
                  )
                : Column(children: [chart, const SizedBox(height: 18), meals]),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 4,
            child: TchCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.proNotes, style: Tch.style(17, weight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Semantics(
                    label: l.proNotes,
                    textField: true,
                    child: TextField(
                      controller: _note,
                      minLines: 3,
                      maxLines: 6,
                      cursorColor: Tch.green,
                      style: Tch.style(14, height: 1.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Tch.background,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: _border(Tch.border),
                        enabledBorder: _border(Tch.border),
                        focusedBorder: _border(Tch.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(l.proNotePrivate, style: Tch.style(12, color: Tch.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: 1.5),
      );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.bg, this.fg);
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: Tch.style(12, weight: FontWeight.w500, color: fg)),
      );
}
