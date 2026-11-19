import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_curve.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_segmented.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/patient_models.dart';
import '../../data/patient_repositories.dart';
import '../../l10n/gen/app_localizations.dart';

/// 11. Progrès : poids / IMC / tour de taille, courbe et badges.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _tab = 0;

  Future<void> _addMeasure() async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Tch.surface,
      barrierColor: const Color(0x732F3437),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _MeasureSheet(),
    );
    if (done == true) ref.invalidate(progressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fr = locale.startsWith('fr');
    final progress = ref.watch(progressProvider);

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
          AsyncView<ProgressData>(
            value: progress,
            onRetry: () => ref.invalidate(progressProvider),
            builder: (p) {
              final points = [p.weight, p.bmi, p.waist][_tab];
              final unit = ['kg', '', 'cm'][_tab];
              final goal = [p.goalWeightKg, p.goalBmi, null][_tab];
              String fmt(double v) =>
                  fr ? v.toStringAsFixed(1).replaceAll('.', ',') : v.toStringAsFixed(1);
              final u = unit.isEmpty ? '' : ' $unit';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    index: 2,
                    child: TchCard(
                      padding: const EdgeInsets.all(18),
                      child: points.length < 2
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.progNoData,
                                    style: Tch.style(15,
                                        color: Tch.textSecondary, height: 1.5)),
                                const SizedBox(height: 14),
                                TchButton(
                                    label: l.progAddMeasure, height: 48, onPressed: _addMeasure),
                              ],
                            )
                          : _ChartCard(
                              points: points,
                              unit: unit,
                              goal: goal,
                              goalLabel: goal == null ? null : '${l.progGoal} ${fmt(goal)}$u',
                              fmt: fmt,
                              today: l.today,
                              since: l.progSinceWeeks(math.max(
                                  1, points.last.date.difference(points.first.date).inDays ~/ 7)),
                              start: DateFormat('d MMM', locale).format(points.first.date),
                              end: DateFormat('d MMM', locale).format(points.last.date),
                              semantic:
                                  '${l.progTitle} — ${[l.progTabWeight, l.progTabBmi, l.progTabWaist][_tab]}',
                              chartKey: ValueKey('$_tab-${points.length}'),
                            ),
                    ),
                  ),
                  if (points.length >= 2) ...[
                    const SizedBox(height: 12),
                    TchButton(
                      label: l.progAddMeasure,
                      style: TchButtonStyle.secondary,
                      height: 48,
                      onPressed: _addMeasure,
                    ),
                  ],
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
                            child: _Badge(TchIcons.leaf, Tch.greenLight, Tch.greenDark2,
                                l.progB1, p.firstSession)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _Badge(TchIcons.flame, Tch.peachLight, Tch.coralText,
                                l.progB2, p.streak14)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _Badge(TchIcons.award, Tch.yellow, const Color(0xFF7A5C00),
                                l.progB3, p.lost4kg)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.points,
    required this.unit,
    required this.goal,
    required this.goalLabel,
    required this.fmt,
    required this.today,
    required this.since,
    required this.start,
    required this.end,
    required this.semantic,
    required this.chartKey,
  });
  final List<SeriesPoint> points;
  final String unit;
  final double? goal;
  final String? goalLabel;
  final String Function(double) fmt;
  final String today, since, start, end, semantic;
  final Key chartKey;

  @override
  Widget build(BuildContext context) {
    final values = [for (final p in points) p.value];
    final last = values.last;
    final diff = last - values.first;
    final all = [...values, ?goal];
    final lo = all.reduce(math.min);
    final hi = all.reduce(math.max);
    final pad = math.max((hi - lo) * 0.15, 0.5);
    final u = unit.isEmpty ? '' : ' $unit';
    final sign = diff < 0 ? '−' : '+';
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(today, style: Tch.style(13, color: Tch.textSecondary)),
                Text.rich(TextSpan(
                  text: fmt(last),
                  style: Tch.style(32, weight: FontWeight.w700, height: 1.1),
                  children: [
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: Tch.style(15, weight: FontWeight.w500, color: Tch.textSecondary),
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
              child: Text('$sign${fmt(diff.abs())}$u $since',
                  style: Tch.style(13, weight: FontWeight.w600, color: Tch.greenDark)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TchCurve(
          key: chartKey,
          data: values,
          min: lo - pad,
          max: hi + pad,
          goal: goal,
          goalLabel: goalLabel,
          semanticLabel: semantic,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(start, style: Tch.style(11, color: Tch.textSecondary)),
              Text(end, style: Tch.style(11, color: Tch.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.bg, this.fg, this.label, this.earned);
  final String icon;
  final Color bg;
  final Color fg;
  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: earned ? 1 : 0.4,
        child: Container(
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
        ),
      );
}

/// Saisie du poids et du tour de taille du jour.
class _MeasureSheet extends ConsumerStatefulWidget {
  const _MeasureSheet();

  @override
  ConsumerState<_MeasureSheet> createState() => _MeasureSheetState();
}

class _MeasureSheetState extends ConsumerState<_MeasureSheet> {
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final w = _num(_weight);
    final c = _num(_waist);
    final okW = w == null || (w >= 20 && w <= 400);
    final okC = c == null || (c >= 30 && c <= 300);
    if ((w == null && c == null) || !okW || !okC) {
      messenger.showSnackBar(SnackBar(content: Text(l.progMeasureInvalid)));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(progressRepositoryProvider).addMeasurement(weightKg: w, waistCm: c);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.progAddMeasure, style: Tch.style(20, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(l.progWeightLabel, style: Tch.style(13, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          TchTextField(
            controller: _weight,
            height: 52,
            semanticLabel: l.progWeightLabel,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: fmt,
          ),
          const SizedBox(height: 12),
          Text(l.progWaistLabel, style: Tch.style(13, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          TchTextField(
            controller: _waist,
            height: 52,
            semanticLabel: l.progWaistLabel,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: fmt,
          ),
          const SizedBox(height: 20),
          TchButton(label: l.progSave, onPressed: _saving ? null : _save),
        ],
      ),
    );
  }
}
