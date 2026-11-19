import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_chip.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/api/api_client.dart';
import '../../data/patient_models.dart';
import '../../data/patient_repositories.dart';
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

String mealTypeLabel(AppLocalizations l, MealType t) => switch (t) {
  MealType.breakfast => l.mealBreakfast,
  MealType.lunch => l.mealLunch,
  MealType.snack => l.mealSnack,
  MealType.dinner => l.mealDinner,
};

/// 10. Journal alimentaire.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  int _dayOffset = 0; // 0 = aujourd'hui, négatif = jours passés

  DateTime get _day => dateOnly(DateTime.now().add(Duration(days: _dayOffset)));

  Future<void> _saveFeeling(Meal meal, int? mood, Set<int> symptoms) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(journalRepositoryProvider)
          .setFeeling(meal.id, mood: mood, symptoms: symptoms);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    }
  }

  Future<void> _delete(Meal meal) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(journalRepositoryProvider).deleteMeal(meal.id);
      ref.invalidate(journalDayProvider(_day));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = _day;
    final journal = ref.watch(journalDayProvider(day));
    final dayLabel = _dayOffset == 0
        ? l.today
        : DateFormat.MMMEd(locale).format(day);
    final kcalText = journal.maybeWhen(
      data: (j) =>
          '${formatInt(j.totalKcal, locale)} / ${formatInt(j.targetKcal, locale)} kcal',
      orElse: () => ' ',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Tch.pagePadding,
              Tch.topInset(context),
              Tch.pagePadding,
              8,
            ),
            child: FadeSlideIn(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.journalTitle,
                    style: Tch.style(28, weight: FontWeight.w700),
                  ),
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
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const TchIcon(
                            TchIcons.book,
                            size: 18,
                            color: Tch.text,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l.journalRecipes,
                            style: Tch.style(14, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tch.pagePadding,
              0,
              Tch.pagePadding,
              8,
            ),
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
                    Text(
                      dayLabel,
                      style: Tch.style(15, weight: FontWeight.w600),
                    ),
                    Text(
                      kcalText,
                      style: Tch.style(13, color: Tch.textSecondary),
                    ),
                  ],
                ),
                _DayArrow(
                  icon: TchIcons.chevronRight,
                  label: l.journalNextDay,
                  color: _dayOffset < 0 ? Tch.textSecondary : Tch.checkBorder,
                  onTap: _dayOffset < 0
                      ? () => setState(() => _dayOffset++)
                      : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tch.pagePadding,
              4,
              Tch.pagePadding,
              0,
            ),
            child: AsyncView<DayJournal>(
              value: journal,
              onRetry: () => ref.invalidate(journalDayProvider(day)),
              builder: (j) => Column(
                children: [
                  if (j.meals.isEmpty)
                    FadeSlideIn(
                      index: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: TchCard(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            l.journalEmpty,
                            textAlign: TextAlign.center,
                            style: Tch.style(
                              15,
                              color: Tch.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  for (var i = 0; i < j.meals.length; i++) ...[
                    FadeSlideIn(
                      key: ValueKey(j.meals[i].id),
                      index: 1 + i,
                      child: _MealCard(
                        meal: j.meals[i],
                        onDelete: () => _delete(j.meals[i]),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_dayOffset == 0 || j.meals.isNotEmpty) ...[
                    if (j.meals.isNotEmpty)
                      FadeSlideIn(
                        index: 2,
                        child: _Feeling(
                          key: ValueKey(j.meals.last.id),
                          meal: j.meals.last,
                          onChanged: (mood, symptoms) =>
                              _saveFeeling(j.meals.last, mood, symptoms),
                        ),
                      ),
                    const SizedBox(height: 14),
                  ],
                  if (_dayOffset == 0)
                    TchButton(
                      label: l.journalAddMeal,
                      style: TchButtonStyle.secondary,
                      onPressed: () => context.go('/journal/add'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayArrow extends StatelessWidget {
  const _DayArrow({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
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
          child: TchIcon(icon, size: 20, color: color, strokeWidth: 2.2),
        ),
      ),
    ),
  );
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal, required this.onDelete});
  final Meal meal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final photoId = meal.photoFileId;
    Widget image = SvgPicture.string(_mealSvg, fit: BoxFit.cover);
    if (photoId != null) {
      final bytes = ref.watch(photoProvider(photoId));
      image = bytes.maybeWhen(
        data: (b) => b.isEmpty
            ? image
            : Image.memory(b, fit: BoxFit.cover, gaplessPlayback: true),
        orElse: () => const ColoredBox(color: Tch.segmented),
      );
    }
    return TchCard(
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
                  image,
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${mealTypeLabel(l, meal.type)} · ${DateFormat('HH:mm', locale).format(meal.eatenAt)}',
                        style: Tch.style(
                          12,
                          weight: FontWeight.w600,
                          color: Tch.greenDark,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Semantics(
                      button: true,
                      label: l.journalDeleteMeal,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onDelete,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: TchIcon(
                                  TchIcons.close,
                                  size: 16,
                                  color: Tch.coralText,
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                  child: Text(
                    meal.name,
                    style: Tch.style(16, weight: FontWeight.w600),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '${meal.kcal} ',
                    style: Tch.style(18, weight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: 'kcal',
                        style: Tch.style(
                          12,
                          weight: FontWeight.w500,
                          color: Tch.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: _Macro(
                    l.journalProt,
                    '${meal.protein} g',
                    (meal.protein / 45).clamp(0, 1).toDouble(),
                    Tch.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Macro(
                    l.journalCarbs,
                    '${meal.carbs} g',
                    (meal.carbs / 117).clamp(0, 1).toDouble(),
                    const Color(0xFFE9B949),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Macro(
                    l.journalFat,
                    '${meal.fat} g',
                    (meal.fat / 41).clamp(0, 1).toDouble(),
                    Tch.coral,
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

/// Humeur (choix unique) et symptômes « après le repas » (choix multiples) du dernier repas.
class _Feeling extends StatefulWidget {
  const _Feeling({super.key, required this.meal, required this.onChanged});
  final Meal meal;
  final void Function(int? mood, Set<int> symptoms) onChanged;

  @override
  State<_Feeling> createState() => _FeelingState();
}

class _FeelingState extends State<_Feeling> {
  late int? _mood = widget.meal.mood;
  late final Set<int> _symptoms = {...widget.meal.symptoms};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final moods = [l.mood1, l.mood2, l.mood3, l.mood4, l.mood5];
    final syms = [l.sym1, l.sym2, l.sym3, l.sym4];
    return SizedBox(
      width: double.infinity,
      child: TchCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.journalMood, style: Tch.style(15, weight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 5; i++)
                  _MoodFace(
                    mouth: _mouths[i],
                    label: moods[i],
                    on: i == _mood,
                    onTap: () {
                      setState(() => _mood = i);
                      widget.onChanged(_mood, _symptoms);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.journalSymptoms,
              style: Tch.style(15, weight: FontWeight.w600),
            ),
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
                    onTap: () {
                      setState(
                        () => _symptoms.contains(i)
                            ? _symptoms.remove(i)
                            : _symptoms.add(i),
                      );
                      widget.onChanged(_mood, _symptoms);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodFace extends StatelessWidget {
  const _MoodFace({
    required this.mouth,
    required this.label,
    required this.on,
    required this.onTap,
  });
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
