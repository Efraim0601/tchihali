import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/api/api_client.dart';
import '../../data/health_repository.dart';
import '../../l10n/gen/app_localizations.dart';

/// Réponses : objectif (choix unique), santé et allergies (choix multiples).
class QuestionnaireState {
  const QuestionnaireState({
    this.goal = 0,
    this.health = const {},
    this.allergies = const {},
  });
  final int goal;
  final Set<int> health;
  final Set<int> allergies;
}

class QuestionnaireNotifier extends Notifier<QuestionnaireState> {
  @override
  QuestionnaireState build() => const QuestionnaireState();

  void pickGoal(int i) => state = QuestionnaireState(
    goal: i,
    health: state.health,
    allergies: state.allergies,
  );

  // La dernière option (« Aucun ») est exclusive.
  Set<int> _toggle(Set<int> set, int i) {
    final next = {...set};
    if (i == 3) return next.contains(3) ? {} : {3};
    next.remove(3);
    next.contains(i) ? next.remove(i) : next.add(i);
    return next;
  }

  void toggleHealth(int i) => state = QuestionnaireState(
    goal: state.goal,
    health: _toggle(state.health, i),
    allergies: state.allergies,
  );
  void toggleAllergy(int i) => state = QuestionnaireState(
    goal: state.goal,
    health: state.health,
    allergies: _toggle(state.allergies, i),
  );
}

final questionnaireProvider =
    NotifierProvider<QuestionnaireNotifier, QuestionnaireState>(
      QuestionnaireNotifier.new,
    );

const _tints = [
  (Tch.greenLight, Tch.greenDark),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Tch.yellow, Tch.yellowText),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

const _goalPaths = [
  'M4 18l5-6 4 3 7-9',
  'M12 3c3 5 6 7 6 11a6 6 0 0 1-12 0c0-4 3-6 6-11z',
  'M5 19c0-8 5-13 14-14-1 9-6 14-14 14zM5 19l7-7',
  'M4 10v4M8 7v10M16 7v10M20 10v4M8 12h8',
];
const _healthPaths = [
  'M3 12h4l3-7 4 14 3-7h4',
  'M12 3c3 5 6 7 6 11a6 6 0 0 1-12 0c0-4 3-6 6-11z',
  'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2 4 4 0 0 1 7 2c0 5.500-7 10-7 10z',
  'M5 12l5 5 9-10',
];
const _allergyPaths = [
  'M12 4l9 16H3zM12 10v4M12 17v.5',
  'M12 4l9 16H3zM12 10v4M12 17v.5',
  'M12 4l9 16H3zM12 10v4M12 17v.5',
  'M5 12l5 5 9-10',
];

/// 5. Questionnaire : 3 étapes sur le même modèle.
class QuestionnaireScreen extends ConsumerWidget {
  const QuestionnaireScreen({super.key, required this.step});
  final int step; // 1..3

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final q = ref.watch(questionnaireProvider);
    final n = ref.read(questionnaireProvider.notifier);

    final (title, sub, labels, paths) = switch (step) {
      1 => (l.q1Title, l.q1Sub, [l.q1o1, l.q1o2, l.q1o3, l.q1o4], _goalPaths),
      2 => (l.q2Title, l.q2Sub, [l.q2o1, l.q2o2, l.q2o3, l.q2o4], _healthPaths),
      _ => (
        l.q3Title,
        l.q3Sub,
        [l.q3o1, l.q3o2, l.q3o3, l.q3o4],
        _allergyPaths,
      ),
    };
    bool selected(int i) => switch (step) {
      1 => q.goal == i,
      2 => q.health.contains(i),
      _ => q.allergies.contains(i),
    };
    void pick(int i) => switch (step) {
      1 => n.pickGoal(i),
      2 => n.toggleHealth(i),
      _ => n.toggleAllergy(i),
    };

    return Scaffold(
      backgroundColor: Tch.background,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Tch.authPadding,
                  Tch.topInset(context),
                  Tch.authPadding,
                  36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TchBackButton(
                          onTap: () => context.go(
                            step == 1
                                ? '/signup/code'
                                : '/questionnaire/${step - 1}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _ProgressBar(fraction: step / 3)),
                        const SizedBox(width: 12),
                        Text(
                          '$step / 3',
                          style: Tch.style(
                            13,
                            weight: FontWeight.w600,
                            color: Tch.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      key: ValueKey('t$step'),
                      index: 1,
                      child: Text(
                        title,
                        style: Tch.style(
                          26,
                          weight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeSlideIn(
                      key: ValueKey('s$step'),
                      index: 2,
                      child: Text(
                        sub,
                        style: Tch.style(
                          15,
                          color: Tch.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      FadeSlideIn(
                        key: ValueKey('o$step$i'),
                        index: 3 + i,
                        child: _OptionCard(
                          label: labels[i],
                          path: paths[i],
                          tint: _tints[i],
                          on: selected(i),
                          multi: step != 1,
                          onTap: () => pick(i),
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 18),
                    TchButton(
                      label: step == 3 ? l.qFinish : l.qNext,
                      onPressed: () async {
                        if (step < 3) {
                          context.go('/questionnaire/${step + 1}');
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref
                              .read(healthRepositoryProvider)
                              .save(
                                goal: q.goal,
                                conditions: q.health,
                                allergies: q.allergies,
                              );
                        } on ApiException catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(apiErrorMessage(l, e))),
                          );
                          return;
                        }
                        if (context.mounted) context.go('/directory');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barre de progression : remplissage depuis la gauche (1 s).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Tch.border,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(fraction),
        tween: Tween(begin: reduced ? fraction : 0, end: fraction),
        duration: reduced ? Duration.zero : const Duration(seconds: 1),
        curve: Tch.riseCurve,
        builder: (_, v, _) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: Tch.green,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.path,
    required this.tint,
    required this.on,
    required this.multi,
    required this.onTap,
  });
  final String label;
  final String path;
  final (Color, Color) tint;
  final bool on;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Tch.selectDuration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Tch.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: on ? Tch.green : Tch.borderLight, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2F3437),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.$1,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TchIcon('<path d="$path"/>', color: tint.$2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Tch.style(16, weight: FontWeight.w600)),
          ),
          AnimatedContainer(
            duration: Tch.selectDuration,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: multi ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: multi ? BorderRadius.circular(8) : null,
              border: Border.all(
                color: on ? Tch.green : Tch.checkBorder,
                width: on ? 7 : 2,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
