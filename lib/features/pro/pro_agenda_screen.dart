import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_card.dart';
import '../../data/api/api_client.dart';
import '../../data/api/api_config.dart';
import '../../data/patient_repositories.dart' show dateOnly;
import '../../data/pro_data.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';
import 'slots_sheet.dart';

const _videoBg = Color(0xFFF6D3C4);
const _videoFg = Color(0xFF6E2E1B);
const _officeBg = Color(0xFFCFE0CB);
const _officeFg = Color(0xFF24412D);

/// 19. Praticien — Agenda : semaine lun–ven (8 h–18 h) et demandes à valider.
class ProAgendaScreen extends ConsumerStatefulWidget {
  const ProAgendaScreen({super.key});

  @override
  ConsumerState<ProAgendaScreen> createState() => _ProAgendaScreenState();
}

class _ProAgendaScreenState extends ConsumerState<ProAgendaScreen> {
  /// id de la demande -> true = validée, false = refusée.
  final _decided = <String, bool>{};

  Future<void> _decide(ProRequestItem r, bool accept) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(proRepositoryProvider).decide(r.id, accept: accept);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    if (!mounted) return;
    setState(() => _decided[r.id] = accept);
    ref.invalidate(proAgendaProvider);
  }

  Future<void> _addSlot() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Tch.surface,
    barrierColor: const Color(0x732F3437),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const SlotsSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fr = isFrench(locale);
    final dateText = capitalize(
      DateFormat(
        fr ? 'EEEE d MMMM y' : 'EEEE, MMMM d, y',
        locale,
      ).format(ApiConfig.isConfigured ? DateTime.now() : weekStart),
    );
    final ws = currentWeekStart();
    final weekLabel = l.proWeek(
      DateFormat(fr ? 'd MMMM' : 'MMMM d', locale).format(ws),
    );
    final reqAsync = ref.watch(proRequestsProvider);
    final pending = (reqAsync.value ?? const <ProRequestItem>[])
        .where((r) => !_decided.containsKey(r.id))
        .length;

    final week = FadeSlideIn(
      index: 1,
      child: TchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [
                Text(weekLabel, style: Tch.style(18, weight: FontWeight.w600)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Legend(color: _officeBg, label: l.modeOffice),
                    const SizedBox(width: 14),
                    _Legend(color: _videoBg, label: l.modeVideo),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            AsyncView<List<ProAppointment>>(
              value: ref.watch(proAgendaProvider),
              onRetry: () => ref.invalidate(proAgendaProvider),
              builder: (appts) =>
                  _WeekGrid(locale: locale, start: ws, appts: appts),
            ),
          ],
        ),
      ),
    );

    final requests = FadeSlideIn(
      index: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l.proPending, style: Tch.style(18, weight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Tch.peachLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pending',
                  style: Tch.style(14, color: const Color(0xFF8A3A24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AsyncView<List<ProRequestItem>>(
            value: reqAsync,
            onRetry: () => ref.invalidate(proRequestsProvider),
            builder: (items) => Column(
              children: [
                for (final r in items) ...[
                  _RequestCard(
                    request: r,
                    locale: locale,
                    decision: _decided[r.id],
                    onDecide: (ok) => _decide(r, ok),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28).copyWith(
        left: MediaQuery.of(context).size.width < proWideBreakpoint ? 20 : 32,
        right: MediaQuery.of(context).size.width < proWideBreakpoint ? 20 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: Tch.style(14, color: Tch.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.proAgenda,
                      style: Tch.style(30, weight: FontWeight.w700),
                    ),
                  ],
                ),
                PressScale(
                  onTap: _addSlot,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tch.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l.proNewSlot,
                      style: Tch.style(
                        15,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) => box.maxWidth >= 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: week),
                      const SizedBox(width: 20),
                      SizedBox(width: 340, child: requests),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [week, const SizedBox(height: 20), requests],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: Tch.style(12, color: const Color(0xFF4A5054))),
    ],
  );
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.locale,
    required this.start,
    required this.appts,
  });
  final String locale;
  final DateTime start;
  final List<ProAppointment> appts;

  /// Rendez-vous du jour n (0 = lundi) au format de la grille (heure décimale).
  List<ProAppt> _forDay(int n) => [
    for (final a in appts)
      if (a.startsAt.weekday - 1 == n)
        ProAppt(a.patient, a.startsAt.hour + a.startsAt.minute / 60, a.video),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = box.maxWidth < 600 ? 600.0 : box.maxWidth;
      final days = [for (var i = 0; i < 5; i++) start.add(Duration(days: i))];
      bool highlight(int i) => ApiConfig.isConfigured
          ? dateOnly(days[i]) == dateOnly(DateTime.now())
          : i == 0;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 44),
                  for (var i = 0; i < days.length; i++) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: highlight(i) ? Tch.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          capitalize(
                            DateFormat('EEE d', locale).format(days[i]),
                          ),
                          style: Tch.style(
                            13,
                            weight: FontWeight.w600,
                            color: highlight(i) ? Colors.white : Tch.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        for (var h = 8; h < 18; h++)
                          SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${h}h',
                                style: Tch.style(11, color: Tch.textSecondary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < days.length; i++) ...[
                    const SizedBox(width: 6),
                    Expanded(child: _DayColumn(appts: _forDay(i))),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.appts});
  final List<ProAppt> appts;

  String _time(double start) =>
      '${start.floor()}:${start % 1 == 0 ? '00' : '30'}';

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      height: 480,
      child: CustomPaint(
        painter: _HourLines(),
        child: Stack(
          children: [
            for (final a in appts)
              Positioned(
                left: 4,
                right: 4,
                top: (a.start - 8) * 48 + 2,
                height: 32,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: a.video ? _videoBg : _officeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: Tch.style(
                          12,
                          weight: FontWeight.w600,
                          height: 1.2,
                          color: a.video ? _videoFg : _officeFg,
                        ),
                      ),
                      Text(
                        _time(a.start),
                        style: Tch.style(
                          11,
                          color: (a.video ? _videoFg : _officeFg).withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Fond de colonne : une ligne par heure (48 px).
class _HourLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Tch.background);
    final line = Paint()..color = Tch.borderLight;
    for (var y = 47.0; y < size.height; y += 48) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.locale,
    required this.decision,
    required this.onDecide,
  });
  final ProRequestItem request;
  final String locale;
  final bool? decision;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = request;
    return TchCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _avatarColors(r.patient).$1,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  r.initials,
                  style: Tch.style(
                    14,
                    weight: FontWeight.w700,
                    color: _avatarColors(r.patient).$2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.patient,
                      style: Tch.style(15, weight: FontWeight.w600),
                    ),
                    Text(
                      '${formatSlotDay(r.startsAt, locale)} · ${hhmm(r.startsAt)}',
                      style: Tch.style(13, color: Tch.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: r.video ? _videoBg : _officeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r.video ? l.modeVideo : l.modeOffice,
                  style: Tch.style(
                    12,
                    weight: FontWeight.w600,
                    color: r.video ? _videoFg : _officeFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: Tch.selectDuration,
            child: decision == null
                ? Row(
                    key: const ValueKey('actions'),
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: l.proRefuse,
                          filled: false,
                          onTap: () => onDecide(false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: l.proAccept,
                          filled: true,
                          onTap: () => onDecide(true),
                        ),
                      ),
                    ],
                  )
                : Container(
                    key: const ValueKey('status'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: decision!
                          ? Tch.greenLight
                          : const Color(0xFFF3EFE8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      decision! ? l.proAccepted : l.proRefused,
                      style: Tch.style(
                        13,
                        weight: FontWeight.w500,
                        color: decision!
                            ? Tch.greenDark
                            : const Color(0xFF4A5054),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

const _avatarPalette = [
  (Color(0xFFCFE0CB), Color(0xFF24412D)),
  (Color(0xFFFCE9E0), Color(0xFF7A3522)),
  (Color(0xFFFBF0C9), Color(0xFF5E4700)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

(Color, Color) _avatarColors(String name) =>
    _avatarPalette[name.codeUnits.fold<int>(0, (a, c) => a + c) %
        _avatarPalette.length];

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap,
    child: Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? Tch.green : Tch.surface,
        borderRadius: BorderRadius.circular(14),
        border: filled ? null : Border.all(color: Tch.border, width: 1.5),
      ),
      child: Text(
        label,
        style: Tch.style(
          14,
          weight: FontWeight.w600,
          color: filled ? Colors.white : Tch.text,
        ),
      ),
    ),
  );
}
