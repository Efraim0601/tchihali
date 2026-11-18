import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_checkbox.dart';
import '../../data/pro_data.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

const _mealTints = [
  (Tch.yellow, Tch.yellowText),
  (Tch.greenLight, Color(0xFF24412D)),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

/// 21. Praticien — Compte rendu : mesures, résumé, objectifs et plan alimentaire.
class ProReportScreen extends StatefulWidget {
  const ProReportScreen({super.key, required this.id});
  final String id;

  @override
  State<ProReportScreen> createState() => _ProReportScreenState();
}

class _ProReportScreenState extends State<ProReportScreen> {
  int _day = 0;
  bool _sent = false;
  String _time = '10:52'; // heure du brouillon dans la maquette ; mise à jour à la saisie
  final _goals = <int>{0, 1, 2};
  TextEditingController? _summary;
  List<TextEditingController>? _fields;

  @override
  void dispose() {
    _summary?.dispose();
    for (final f in _fields ?? const <TextEditingController>[]) {
      f.dispose();
    }
    super.dispose();
  }

  void _touch() => setState(() => _time = hhmm(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    _summary ??= TextEditingController(text: reportSummary.of(locale));
    _fields ??= [
      for (final f in reportFields) TextEditingController(text: f.$2.of(locale)),
    ];
    final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
    final weekdays = l.proWeekdaysShort.split(',');
    final plan = reportPlans[_day % 3];
    final times = [l.recMealTime1, l.recMealTime2, l.recMealTime3, l.recMealTime4];
    final labels = [l.recMealLabel1, l.recMealLabel2, l.recMealLabel3, l.recMealLabel4];
    final total = plan.fold<int>(0, (a, m) => a + m.$2);

    final measures = TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.proMeasures, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < reportFields.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reportFields[i].$1.of(locale),
                          style: Tch.style(13, weight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      _Input(
                        controller: _fields![i],
                        label: reportFields[i].$1.of(locale),
                        onChanged: (_) => _touch(),
                      ),
                    ],
                  ),
                ),
              ],
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
              minLines: 4,
              maxLines: 8,
              onChanged: (_) => _touch(),
              cursorColor: Tch.green,
              style: Tch.style(14, height: 1.55),
              decoration: InputDecoration(
                filled: true,
                fillColor: Tch.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: _border(Tch.border),
                enabledBorder: _border(Tch.border),
                focusedBorder: _border(Tch.green),
              ),
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
          for (var i = 0; i < reportGoals.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _goals.contains(i) ? _goals.remove(i) : _goals.add(i);
                _time = hhmm(DateTime.now());
              }),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Tch.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    TchCheckbox(checked: _goals.contains(i)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(reportGoals[i].of(locale),
                          style: Tch.style(14, weight: FontWeight.w500)),
                    ),
                  ],
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
                      child: Text(weekdays[i],
                          style: Tch.style(13,
                              weight: i == _day ? FontWeight.w600 : FontWeight.w500,
                              color: i == _day ? Colors.white : Tch.text)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < plan.length; i++) ...[
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
                    child: Text(times[i],
                        style: Tch.style(12,
                            weight: FontWeight.w600, color: _mealTints[i].$2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels[i], style: Tch.style(12, color: Tch.textSecondary)),
                        Text(plan[i].$1.of(locale),
                            style: Tch.style(14, weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${plan[i].$2} kcal',
                      style: Tch.style(13,
                          weight: FontWeight.w600, color: const Color(0xFF4A5054))),
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
                Text(l.proTotal,
                    style: Tch.style(15,
                        weight: FontWeight.w600, color: const Color(0xFF24412D))),
                Text('${_group(total, locale)} / ${_group(1700, locale)} kcal',
                    style: Tch.style(15,
                        weight: FontWeight.w600, color: const Color(0xFF24412D))),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28),
      child: Column(
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
                    Text(reportContext.of(locale),
                        style: Tch.style(14, color: Tch.textSecondary)),
                    const SizedBox(height: 2),
                    Text(l.proReportTitle, style: Tch.style(28, weight: FontWeight.w700)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_sent ? l.proSentAt(_time) : l.proDraftSaved(_time),
                        style: Tch.style(13, color: Tch.textSecondary)),
                    const SizedBox(width: 10),
                    PressScale(
                      onTap: _sent
                          ? null
                          : () => setState(() {
                                _sent = true;
                                _time = hhmm(DateTime.now());
                              }),
                      child: AnimatedContainer(
                        duration: Tch.selectDuration,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _sent ? Tch.greenLight : Tch.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(_sent ? l.proSent : l.proSend,
                            style: Tch.style(15,
                                weight: FontWeight.w600,
                                color: _sent ? const Color(0xFF24412D) : Colors.white)),
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
      ),
    );
  }

  static String _group(int n, String locale) =>
      formatFcfa(n, locale).replaceAll(' FCFA', '');

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: 1.5),
      );
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.label, required this.onChanged});
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: Semantics(
          label: label,
          textField: true,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: Tch.green,
            style: Tch.style(16, weight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: Tch.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: _b(Tch.border),
              enabledBorder: _b(Tch.border),
              focusedBorder: _b(Tch.green),
            ),
          ),
        ),
      );

  static OutlineInputBorder _b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: 1.5),
      );
}
