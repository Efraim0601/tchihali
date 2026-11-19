import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/dietitian_repository.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import 'booking_state.dart';

// Jours fériés fixes au Cameroun (mois, jour).
const _holidays = {(1, 1), (2, 11), (5, 1), (5, 20), (8, 15), (12, 25)};

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Jour réservable : ni passé, ni week-end, ni férié.
bool _isOpen(DateTime d, DateTime today) =>
    !d.isBefore(today) &&
    d.weekday <= DateTime.friday &&
    !_holidays.contains((d.month, d.day));

DateTime? _firstOpenDay(DateTime month, DateTime today) {
  final len = DateTime(month.year, month.month + 1, 0).day;
  for (var n = 1; n <= len; n++) {
    final d = DateTime(month.year, month.month, n);
    if (_isOpen(d, today)) return d;
  }
  return null;
}

/// 7. Réservation : mode, calendrier mensuel, créneaux, récapitulatif.
class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final b = ref.watch(bookingProvider);
    final n = ref.read(bookingProvider.notifier);
    final today = _dateOnly(DateTime.now());

    // Deux mois consultables : le mois en cours et le suivant.
    final base = DateTime(today.year, today.month);
    final months = [base, DateTime(base.year, base.month + 1)];
    final monthIndex =
        (b.day.year == months[1].year && b.day.month == months[1].month)
        ? 1
        : 0;
    final month = months[monthIndex];

    void goMonth(int i) {
      final first = _firstOpenDay(months[i], today);
      if (first != null) n.setDay(first);
    }

    final open = _isOpen(b.day, today);
    final slotsAsync = ref.watch(
      slotsProvider((id: b.dietitian.id, day: b.day)),
    );
    final slotOk = (slotsAsync.value ?? const <Slot>[]).any(
      (s) => s.time == b.slot && !s.taken,
    );
    final dayLabel = open
        ? l.bookSlotsOf(formatLongDay(b.day, locale))
        : l.bookSlotsNone;
    final modeLabel = b.mode == ConsultMode.video ? l.modeVideo : l.modeOffice;
    final summary =
        '${formatSummaryDay(b.day, locale)} · ${b.slot} · $modeLabel';
    final initials = l.weekdayInitials.split(',');

    return Scaffold(
      backgroundColor: Tch.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Tch.pagePadding,
                Tch.topInset(context) - 4,
                Tch.pagePadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    child: Row(
                      children: [
                        TchBackButton(onTap: () => context.go('/directory')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.bookWith,
                                style: Tch.style(13, color: Tch.textSecondary),
                              ),
                              Text(
                                b.dietitian.name,
                                style: Tch.style(17, weight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        TchAvatar(
                          initials: b.dietitian.initials,
                          size: 46,
                          background: b.dietitian.avatarBg,
                          foreground: b.dietitian.avatarFg,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            icon: TchIcons.video,
                            label: l.modeVideo,
                            on: b.mode == ConsultMode.video,
                            enabled: b.dietitian.video,
                            onTap: () => n.setMode(ConsultMode.video),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            icon: TchIcons.office,
                            label: l.modeOffice,
                            on: b.mode == ConsultMode.office,
                            enabled: b.dietitian.inPerson,
                            onTap: () => n.setMode(ConsultMode.office),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 2,
                    child: _Calendar(
                      month: month,
                      title: capitalize(
                        DateFormat('MMMM y', locale).format(month),
                      ),
                      weekdays: initials,
                      today: today,
                      selected: b.day,
                      prevLabel: l.bookPrevMonth,
                      nextLabel: l.bookNextMonth,
                      canPrev: monthIndex > 0,
                      canNext: monthIndex < 1,
                      onPrev: () => goMonth(0),
                      onNext: () => goMonth(1),
                      onPick: n.setDay,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayLabel,
                          style: Tch.style(15, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        AsyncView<List<Slot>>(
                          value: slotsAsync,
                          onRetry: () => ref.invalidate(
                            slotsProvider((id: b.dietitian.id, day: b.day)),
                          ),
                          builder: (slots) => GridView(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  mainAxisExtent: 46,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final s in slots)
                                _SlotButton(
                                  label: s.taken
                                      ? '${s.time} · ${l.bookFull}'
                                      : s.time,
                                  selected: s.time == b.slot && !s.taken,
                                  full: s.taken,
                                  onTap: () => n.setSlot(s.time),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              14 + MediaQuery.of(context).padding.bottom.clamp(16, 40),
            ),
            decoration: const BoxDecoration(
              color: Tch.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F2F3437),
                  blurRadius: 20,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Tch.style(13, color: Tch.textSecondary),
                      ),
                      Text(
                        formatFcfa(b.price, locale),
                        style: Tch.style(20, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                TchButton(
                  label: l.bookContinue,
                  height: 54,
                  expand: false,
                  onPressed: open && slotOk
                      ? () => context.go('/booking/payment')
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.on,
    required this.enabled,
    required this.onTap,
  });
  final String icon;
  final String label;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = on ? Tch.greenDark : Tch.text;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: PressScale(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: Tch.selectDuration,
          height: 52,
          decoration: BoxDecoration(
            color: on ? Tch.greenLight : Tch.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: on ? Tch.green : Tch.borderLight,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TchIcon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: Tch.style(
                  15,
                  weight: on ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.month,
    required this.title,
    required this.weekdays,
    required this.today,
    required this.selected,
    required this.prevLabel,
    required this.nextLabel,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });
  final DateTime month;
  final String title;
  final List<String> weekdays;
  final DateTime today;
  final DateTime selected;
  final String prevLabel;
  final String nextLabel;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    // Semaine qui commence le lundi.
    final lead = DateTime(month.year, month.month, 1).weekday - 1;
    final len = DateTime(month.year, month.month + 1, 0).day;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Tch.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D2F3437),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MonthArrow(
                icon: TchIcons.chevronLeft,
                label: prevLabel,
                enabled: canPrev,
                onTap: onPrev,
              ),
              Text(title, style: Tch.style(16, weight: FontWeight.w600)),
              _MonthArrow(
                icon: TchIcons.chevronRight,
                label: nextLabel,
                enabled: canNext,
                onTap: onNext,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: Tch.style(
                        12,
                        weight: FontWeight.w500,
                        color: Tch.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lead + len,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 3,
              mainAxisExtent:
                  44, // 38 visibles + 3 px de marge : zone tactile de 44
            ),
            itemBuilder: (_, i) {
              if (i < lead) return const SizedBox.shrink();
              final day = DateTime(month.year, month.month, i - lead + 1);
              final open = _isOpen(day, today);
              return _DayCell(
                day: day.day,
                open: open,
                selected: open && day == selected,
                isToday: day == today,
                onTap: () => onPick(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: TchIcon(
            icon,
            size: 20,
            strokeWidth: 2.2,
            color: enabled ? Tch.text : const Color(0xFFD5D0C6),
          ),
        ),
      ),
    ),
  );
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.open,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });
  final int day;
  final bool open;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    FontWeight weight;
    if (selected) {
      bg = Tch.green;
      fg = Colors.white;
      weight = FontWeight.w700;
    } else if (open) {
      bg = Tch.greenLight;
      fg = const Color(0xFF24412D);
      weight = FontWeight.w600;
    } else {
      bg = Colors.transparent;
      fg = const Color(0xFFB4B7B3);
      weight = FontWeight.w400;
    }
    return Semantics(
      button: true,
      enabled: open,
      selected: selected,
      label: '$day',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: open ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
            duration: Tch.selectDuration,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: isToday && open && !selected
                  ? Border.all(color: Tch.green, width: 1.5)
                  : null,
            ),
            child: Text(
              '$day',
              style: Tch.style(14, weight: weight, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.label,
    required this.selected,
    required this.full,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool full;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: full ? null : onTap,
    child: AnimatedContainer(
      duration: Tch.selectDuration,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Tch.green : (full ? Colors.transparent : Tch.surface),
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? null
            : Border.all(
                color: full ? const Color(0xFFDCD5CA) : Tch.borderLight,
                width: 1.5,
              ),
      ),
      child: full
          ? CustomPaint(
              painter: _DashedBorder(),
              child: Center(
                child: Text(
                  label,
                  style: Tch.style(14, color: const Color(0xFFA7AAA6)),
                ),
              ),
            )
          : Text(
              label,
              style: Tch.style(
                14,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Tch.text,
              ),
            ),
    ),
  );
}

/// Bordure en pointillés (créneau complet).
class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCD5CA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
