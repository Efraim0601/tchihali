import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_checkbox.dart';
import '../../data/api/api_client.dart';
import '../../data/pro_data.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

const _mealTints = [
  (Tch.yellow, Tch.yellowText),
  (Tch.greenLight, Color(0xFF24412D)),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

/// 21. Praticien — Compte rendu : mesures, résumé, objectifs et plan alimentaire.
class ProReportScreen extends ConsumerWidget {
  const ProReportScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28),
      child: AsyncView<ReportDraft>(
        value: ref.watch(proReportProvider(id)),
        onRetry: () => ref.invalidate(proReportProvider(id)),
        builder: (d) => _ReportBody(patientId: id, draft: d),
      ),
    );
  }
}

class _ReportBody extends ConsumerStatefulWidget {
  const _ReportBody({required this.patientId, required this.draft});
  final String patientId;
  final ReportDraft draft;

  @override
  ConsumerState<_ReportBody> createState() => _ReportBodyState();
}

class _ReportBodyState extends ConsumerState<_ReportBody> {
  late final ReportDraft _d = widget.draft;
  int _day = 0;
  String _time = hhmm(DateTime.now());
  bool _sending = false;
  bool _demoFilled = false;
  Timer? _debounce;

  late final _summary = TextEditingController();
  late final _weight = TextEditingController();
  late final _waist = TextEditingController();
  late final _glucose = TextEditingController();
  final _newGoal = TextEditingController();
  final _mealCtrls = <String, TextEditingController>{};
  final _kcalCtrls = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _summary.text = _d.summary;
    _weight.text = _d.weightKg == null ? '' : '${_d.weightKg}';
    _waist.text = _d.waistCm == null ? '' : '${_d.waistCm}';
    _glucose.text = _d.glucoseGl == null ? '' : '${_d.glucoseGl}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Démo : contenu d'exemple de la maquette dans la langue de l'interface.
    if (_d.demo && !_demoFilled) {
      _demoFilled = true;
      final locale = Localizations.localeOf(context).toString();
      _d.summary = reportSummary.of(locale);
      _summary.text = _d.summary;
      _d.goals.addAll([
        for (final g in reportGoals) ReportGoalItem(g.of(locale)),
      ]);
      for (var day = 0; day < 7; day++) {
        final plan = reportPlans[day % 3];
        _d.plan[day] = [
          for (final m in plan) ReportMealItem(m.$1.of(locale), m.$2),
        ];
      }
      _d.weightKg = 79.1;
      _d.waistCm = 91.5;
      _d.glucoseGl = 1.05;
      _weight.text = '79.1';
      _waist.text = '91.5';
      _glucose.text = '1.05';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [
      _summary,
      _weight,
      _waist,
      _glucose,
      _newGoal,
      ..._mealCtrls.values,
      ..._kcalCtrls.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _mealCtrl(int day, int i) => _mealCtrls.putIfAbsent(
    '$day-$i',
    () => TextEditingController(text: _d.plan[day][i].text),
  );
  TextEditingController _kcalCtrl(int day, int i) => _kcalCtrls.putIfAbsent(
    '$day-$i',
    () => TextEditingController(
      text: _d.plan[day][i].kcal == 0 ? '' : '${_d.plan[day][i].kcal}',
    ),
  );

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  /// Brouillon enregistré automatiquement, 0,8 s après la dernière modification.
  void _touch() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<bool> _save() async {
    _d.summary = _summary.text;
    _d.weightKg = _num(_weight);
    _d.waistCm = _num(_waist);
    _d.glucoseGl = _num(_glucose);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(proRepositoryProvider).saveReport(widget.patientId, _d);
      if (mounted) setState(() => _time = hhmm(DateTime.now()));
      return true;
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.status == 422 || e.status == 400
                ? l.proSaveFailed
                : apiErrorMessage(l, e),
          ),
        ),
      );
      return false;
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_summary.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.proReportSendFailed)));
      return;
    }
    setState(() => _sending = true);
    _debounce?.cancel();
    try {
      if (!await _save()) {
        if (mounted) setState(() => _sending = false);
        return;
      }
      await ref.read(proRepositoryProvider).sendReport(widget.patientId);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    if (!mounted) return;
    setState(() {
      _d.sent = true;
      _sending = false;
      _time = hhmm(DateTime.now());
    });
  }

  OutlineInputBorder _border(Color c, [double r = 16]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(r),
    borderSide: BorderSide(color: c, width: 1.5),
  );

  InputDecoration _deco({String? hint, double r = 16, EdgeInsets? pad}) =>
      InputDecoration(
        filled: true,
        fillColor: Tch.background,
        hintText: hint,
        hintStyle: Tch.style(14, color: Tch.textSecondary),
        contentPadding:
            pad ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: _border(Tch.border, r),
        enabledBorder: _border(Tch.border, r),
        focusedBorder: _border(Tch.green, r),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final weekdays = l.proWeekdaysShort.split(',');
    final plan = _d.plan[_day];
    final times = [
      l.recMealTime1,
      l.recMealTime2,
      l.recMealTime3,
      l.recMealTime4,
    ];
    final labels = [
      l.recMealLabel1,
      l.recMealLabel2,
      l.recMealLabel3,
      l.recMealLabel4,
    ];
    final total = plan.fold<int>(0, (a, m) => a + m.kcal);
    final readOnly = _d.sent;
    final numeric = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    Widget measure(String label, TextEditingController c) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Tch.style(13, weight: FontWeight.w500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: Semantics(
              label: label,
              textField: true,
              child: TextField(
                controller: c,
                readOnly: readOnly,
                onChanged: (_) => _touch(),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: numeric,
                cursorColor: Tch.green,
                style: Tch.style(16, weight: FontWeight.w600),
                decoration: _deco(
                  r: 14,
                  pad: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final measures = TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.proMeasures, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              measure(l.progWeightLabel, _weight),
              const SizedBox(width: 10),
              measure(l.progWaistLabel, _waist),
              const SizedBox(width: 10),
              measure('${l.proKpiGlucose} (g/L)', _glucose),
            ],
          ),
        ],
      ),
    );

    final summary = TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.proSummary, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 8),
          Semantics(
            label: l.proSummary,
            textField: true,
            child: TextField(
              controller: _summary,
              readOnly: readOnly,
              minLines: 4,
              maxLines: 8,
              onChanged: (_) => _touch(),
              cursorColor: Tch.green,
              style: Tch.style(14, height: 1.55),
              decoration: _deco(),
            ),
          ),
        ],
      ),
    );

    final goals = TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.proGoals, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          for (var i = 0; i < _d.goals.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: readOnly
                  ? null
                  : () {
                      _d.goals[i].done = !_d.goals[i].done;
                      _touch();
                    },
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Tch.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    TchCheckbox(checked: _d.goals[i].done),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _d.goals[i].text,
                        style: Tch.style(14, weight: FontWeight.w500),
                      ),
                    ),
                    if (!readOnly)
                      GestureDetector(
                        onTap: () {
                          _d.goals.removeAt(i);
                          _touch();
                        },
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Tch.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (!readOnly) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _newGoal,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.isEmpty) return;
                  _d.goals.add(ReportGoalItem(t));
                  _newGoal.clear();
                  _touch();
                },
                cursorColor: Tch.green,
                style: Tch.style(14),
                decoration: _deco(
                  hint: l.proGoalPlaceholder,
                  r: 14,
                  pad: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final planCard = TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.proPlan, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _day = i),
                    child: AnimatedContainer(
                      duration: Tch.selectDuration,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == _day ? Tch.green : Tch.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: i == _day
                            ? null
                            : Border.all(color: Tch.border, width: 1.5),
                      ),
                      child: Text(
                        weekdays[i],
                        style: Tch.style(
                          13,
                          weight: i == _day ? FontWeight.w600 : FontWeight.w500,
                          color: i == _day ? Colors.white : Tch.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < plan.length && i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Tch.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mealTints[i].$1,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      times[i],
                      style: Tch.style(
                        12,
                        weight: FontWeight.w600,
                        color: _mealTints[i].$2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels[i],
                          style: Tch.style(12, color: Tch.textSecondary),
                        ),
                        TextField(
                          controller: _mealCtrl(_day, i),
                          readOnly: readOnly,
                          onChanged: (v) {
                            plan[i].text = v;
                            _touch();
                          },
                          cursorColor: Tch.green,
                          style: Tch.style(14, weight: FontWeight.w500),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: l.proMealPlaceholder,
                            hintStyle: Tch.style(14, color: Tch.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _kcalCtrl(_day, i),
                      readOnly: readOnly,
                      onChanged: (v) {
                        plan[i].kcal = int.tryParse(v) ?? 0;
                        _touch();
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.end,
                      cursorColor: Tch.green,
                      style: Tch.style(
                        13,
                        weight: FontWeight.w600,
                        color: const Color(0xFF4A5054),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '0',
                        suffixText: ' kcal',
                        suffixStyle: Tch.style(
                          13,
                          weight: FontWeight.w600,
                          color: const Color(0xFF4A5054),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Tch.greenLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.proTotal,
                  style: Tch.style(
                    15,
                    weight: FontWeight.w600,
                    color: const Color(0xFF24412D),
                  ),
                ),
                Text(
                  '${formatInt(total, locale)} / ${formatInt(1700, locale)} kcal',
                  style: Tch.style(
                    15,
                    weight: FontWeight.w600,
                    color: const Color(0xFF24412D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final contextLine = _d.demo
        ? reportContext.of(locale)
        : l.proReportContext(
            _d.patientName,
            _d.sessionNo,
            DateFormat('d MMMM', locale).format(_d.heldOn),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contextLine,
                    style: Tch.style(14, color: Tch.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.proReportTitle,
                    style: Tch.style(28, weight: FontWeight.w700),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _d.sent ? l.proSentAt(_time) : l.proDraftSaved(_time),
                    style: Tch.style(13, color: Tch.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  PressScale(
                    onTap: _d.sent || _sending ? null : _send,
                    child: AnimatedContainer(
                      duration: Tch.selectDuration,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _d.sent ? Tch.greenLight : Tch.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _d.sent ? l.proSent : l.proSend,
                        style: Tch.style(
                          15,
                          weight: FontWeight.w600,
                          color: _d.sent
                              ? const Color(0xFF24412D)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, box) {
            final left = Column(
              children: [
                FadeSlideIn(index: 1, child: measures),
                const SizedBox(height: 18),
                FadeSlideIn(index: 2, child: summary),
                const SizedBox(height: 18),
                FadeSlideIn(index: 3, child: goals),
              ],
            );
            final right = FadeSlideIn(index: 2, child: planCard);
            return box.maxWidth >= 800
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 18),
                      Expanded(child: right),
                    ],
                  )
                : Column(children: [left, const SizedBox(height: 18), right]);
          },
        ),
      ],
    );
  }
}
