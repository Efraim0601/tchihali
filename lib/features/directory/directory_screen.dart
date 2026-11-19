import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_segmented.dart';
import '../../core/widgets/async_view.dart';
import '../../data/dietitian_repository.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../booking/booking_state.dart';

/// 6. Annuaire des diététiciens (onglet Agenda).
class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  int _mode = 0; // 0 = Tous, 1 = Vidéo, 2 = Cabinet
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final q = _query.trim().toLowerCase();
    final dietitians = ref.watch(dietitiansProvider);
    List<Dietitian> filter(List<Dietitian> all) => all.where((d) {
          final modeOk = _mode == 0 || (_mode == 1 && d.video) || (_mode == 2 && d.inPerson);
          final textOk = q.isEmpty ||
              d.name.toLowerCase().contains(q) ||
              d.specialties.of(locale).toLowerCase().contains(q);
          return modeOk && textOk;
        }).toList();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
          Tch.pagePadding, Tch.topInset(context), Tch.pagePadding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text(l.dirTitle,
                style: Tch.style(26, weight: FontWeight.w700, height: 1.2)),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            index: 1,
            child: Row(
              children: [
                Expanded(child: _SearchField(hint: l.dirSearch, onChanged: (v) => setState(() => _query = v))),
                const SizedBox(width: 10),
                _SquareButton(label: l.dirFilters),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            index: 2,
            child: TchSegmented(
              labels: [l.dirAll, l.modeVideo, l.modeOffice],
              selectedIndex: _mode,
              onChanged: (i) => setState(() => _mode = i),
            ),
          ),
          const SizedBox(height: 16),
          AsyncView<List<Dietitian>>(
            value: dietitians,
            onRetry: () => ref.invalidate(dietitiansProvider),
            builder: (all) {
              final list = filter(all);
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    FadeSlideIn(
                      key: ValueKey(list[i].id),
                      index: 3 + i,
                      child: _DietitianCard(
                        d: list[i],
                        locale: locale,
                        nextLabel: l.dirNext,
                        noSlot: l.dirNoSlot,
                        bookLabel: l.dirBook,
                        onBook: () {
                          ref.read(bookingProvider.notifier).start(list[i]);
                          context.go('/booking');
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Tch.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D2F3437), blurRadius: 10, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            const TchIcon(TchIcons.search, size: 20, color: Tch.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                label: hint,
                textField: true,
                child: TextField(
                  onChanged: onChanged,
                  cursorColor: Tch.green,
                  style: Tch.style(15),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: hint,
                    hintStyle: Tch.style(15, color: Tch.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => PressScale(
        semanticLabel: label,
        onTap: () {}, // Filtres : pas encore de comportement défini dans ECRANS.md
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Tch.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x0D2F3437), blurRadius: 10, offset: Offset(0, 2))
            ],
          ),
          child: const Center(child: TchIcon(TchIcons.filters, size: 22, color: Tch.text)),
        ),
      );
}

class _DietitianCard extends StatelessWidget {
  const _DietitianCard({
    required this.d,
    required this.locale,
    required this.nextLabel,
    required this.noSlot,
    required this.bookLabel,
    required this.onBook,
  });
  final Dietitian d;
  final String locale;
  final String nextLabel;
  final String noSlot;
  final String bookLabel;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Tch.surface,
          borderRadius: BorderRadius.circular(Tch.cardRadius),
          boxShadow: const [
            BoxShadow(color: Color(0x0F2F3437), blurRadius: 16, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: d.avatarBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(d.initials,
                      style: Tch.style(18, weight: FontWeight.w700, color: d.avatarFg)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: Tch.style(16, weight: FontWeight.w600)),
                      Text(d.specialties.of(locale),
                          style: Tch.style(13, color: Tch.textSecondary)),
                      Text(d.languages.of(locale),
                          style: Tch.style(12, color: Tch.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextLabel, style: Tch.style(12, color: Tch.textSecondary)),
                      Text(d.nextSlot == null ? noSlot : '${formatSlotDay(d.nextSlot!, locale)} · ${hhmm(d.nextSlot!)}',
                          style: Tch.style(14,
                              weight: FontWeight.w600, color: Tch.coralText)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                PressScale(
                  onTap: onBook,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tch.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(bookLabel,
                        style: Tch.style(15, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
