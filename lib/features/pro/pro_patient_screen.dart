import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_curve.dart';
import '../../data/pro_data.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

EdgeInsets _pagePadding(BuildContext context) {
  final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
  return EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28);
}

/// 20. Praticien — Fiche patient : indicateurs, courbe de poids, derniers repas, notes.
class ProPatientScreen extends ConsumerWidget {
  const ProPatientScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: _pagePadding(context),
    child: AsyncView<ProPatientDetail>(
      value: ref.watch(proPatientProvider(id)),
      onRetry: () => ref.invalidate(proPatientProvider(id)),
      builder: (p) => _PatientBody(patient: p),
    ),
  );
}

class _PatientBody extends ConsumerStatefulWidget {
  const _PatientBody({required this.patient});
  final ProPatientDetail patient;

  @override
  ConsumerState<_PatientBody> createState() => _PatientBodyState();
}

class _PatientBodyState extends ConsumerState<_PatientBody> {
  late final _note = TextEditingController(text: widget.patient.note);
  Timer? _debounce;
  bool _noteInitialised = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _note.dispose();
    super.dispose();
  }

  void _onNote(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      ref
          .read(proRepositoryProvider)
          .saveNote(widget.patient.id, v)
          .then((_) {}, onError: (_) {});
    });
  }

  String _fmt(double v, bool fr, {int digits = 1}) {
    final s = v.toStringAsFixed(digits);
    return fr ? s.replaceAll('.', ',') : s;
  }

  String _mealWhen(AppLocalizations l, String locale, DateTime at) {
    final now = DateTime.now();
    final d = DateTime(at.year, at.month, at.day);
    final today = DateTime(now.year, now.month, now.day);
    final label = d == today
        ? l.today
        : d == today.subtract(const Duration(days: 1))
        ? l.yesterday
        : DateFormat.MMMd(locale).format(at);
    return '$label · ${hhmm(at)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fr = isFrench(locale);
    final p = widget.patient;
    if (!_noteInitialised) {
      _noteInitialised = true;
      if (p.demo && p.note.isEmpty) _note.text = patientNote.of(locale);
    }

    final conditionLabels = [l.q2o1, l.q2o2, l.q2o3];
    final allergyLabels = [l.q3o1, l.q3o2, l.q3o3];
    final tags = <(String, Color, Color)>[
      if (p.demo) ...[
        (patientTag1.of(locale), Tch.peachLight, const Color(0xFF8A3A24)),
        (patientTag2.of(locale), Tch.yellow, Tch.yellowText),
      ] else ...[
        for (final i in p.conditions.where((i) => i < 3))
          (conditionLabels[i], Tch.peachLight, const Color(0xFF8A3A24)),
        for (final i in p.allergies.where((i) => i < 3))
          (allergyLabels[i], Tch.yellow, Tch.yellowText),
      ],
    ];

    final infoParts = [
      if (p.age != null) '${p.age} ${fr ? 'ans' : 'years'}',
      if (p.heightCm != null) '${_fmt(p.heightCm! / 100, fr, digits: 2)} m',
    ];
    final since = p.since == null
        ? null
        : DateFormat('d MMM', locale).format(p.since!);
    final info = p.demo
        ? patientInfo.of(locale)
        : (since == null
              ? infoParts.join(' · ')
              : l.proPatientInfo(
                  infoParts.isEmpty ? p.name : infoParts.join(' · '),
                  since,
                ));

    String kpiValue(ProKpi? k, String unit, {int digits = 1}) =>
        k == null ? l.proUnknown : '${_fmt(k.value, fr, digits: digits)} $unit';
    String kpiDelta(ProKpi? k, String unit, {int digits = 1}) => k == null
        ? ''
        : '${k.delta < 0 ? '−' : '+'}${_fmt(k.delta.abs(), fr, digits: digits)} $unit';
    final kpis = [
      (l.proKpiWeight, kpiValue(p.weight, 'kg'), kpiDelta(p.weight, 'kg')),
      (
        l.proKpiWaist,
        kpiValue(p.waist, 'cm', digits: 0),
        kpiDelta(p.waist, 'cm', digits: 0),
      ),
      (
        l.proKpiGlucose,
        kpiValue(p.glucose, 'g/L', digits: 2),
        kpiDelta(p.glucose, 'g/L', digits: 2),
      ),
    ];

    final series = p.weightSeries;
    final goal = p.goalWeightKg;
    final all = [...series, ?goal];
    final lo = all.isEmpty ? 0.0 : all.reduce(math.min);
    final hi = all.isEmpty ? 1.0 : all.reduce(math.max);
    final pad = math.max((hi - lo) * 0.15, 0.5);

    final chart = FadeSlideIn(
      index: 2,
      child: TchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.proChart, style: Tch.style(17, weight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (series.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l.progNoData,
                  style: Tch.style(14, color: Tch.textSecondary),
                ),
              )
            else ...[
              TchCurve(
                data: series,
                min: lo - pad,
                max: hi + pad,
                goal: goal,
                goalLabel: goal == null
                    ? null
                    : l.proGoalLabel('${_fmt(goal, fr, digits: 0)} kg'),
                semanticLabel: l.proChart,
                height: 200,
                hollowDot: false,
                labelSize: 12,
              ),
            ],
          ],
        ),
      ),
    );

    final mealRows = p.demo
        ? [
            for (final m in patientMeals)
              (m.text.of(locale), m.when.of(locale), m.kcal, m.late),
          ]
        : [
            for (final m in p.meals)
              (m.name, _mealWhen(l, locale, m.at), m.kcal, m.late),
          ];

    final meals = FadeSlideIn(
      index: 3,
      child: TchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.proMeals, style: Tch.style(17, weight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final m in mealRows) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: m.$4 ? Tch.peachLight : Tch.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.$1,
                            style: Tch.style(14, weight: FontWeight.w500),
                          ),
                          Text(
                            m.$2,
                            style: Tch.style(12, color: Tch.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${m.$3} kcal',
                      style: Tch.style(13, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );

    return Column(
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
                  child: Text(
                    p.initials,
                    style: Tch.style(
                      22,
                      weight: FontWeight.w700,
                      color: const Color(0xFF7A3522),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 220,
                    maxWidth: 520,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: Tch.style(24, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info,
                        style: Tch.style(14, color: Tch.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in tags) _Tag(t.$1, t.$2, t.$3),
                        ],
                      ),
                    ],
                  ),
                ),
                PressScale(
                  onTap: () => context.go('/pro/reports/${p.id}'),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tch.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l.proWrite,
                      style: Tch.style(
                        14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
              final cols = ((box.maxWidth + 12) / (180 + 12)).floor().clamp(
                1,
                3,
              );
              final w = (box.maxWidth - 12 * (cols - 1)) / cols;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final k in kpis)
                    SizedBox(
                      width: w,
                      child: TchCard(
                        radius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              k.$1,
                              style: Tch.style(13, color: Tch.textSecondary),
                            ),
                            Text(
                              k.$2,
                              style: Tch.style(24, weight: FontWeight.w700),
                            ),
                            Text(
                              k.$3,
                              style: Tch.style(
                                13,
                                weight: FontWeight.w500,
                                color: Tch.greenDark,
                              ),
                            ),
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
                    onChanged: _onNote,
                    minLines: 3,
                    maxLines: 6,
                    cursorColor: Tch.green,
                    style: Tch.style(14, height: 1.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Tch.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: _border(Tch.border),
                      enabledBorder: _border(Tch.border),
                      focusedBorder: _border(Tch.green),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.proNotePrivate,
                  style: Tch.style(12, color: Tch.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
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
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: Tch.style(12, weight: FontWeight.w500, color: fg),
    ),
  );
}
