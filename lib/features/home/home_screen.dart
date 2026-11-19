import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/async_view.dart';
import '../../data/api/api_client.dart';
import '../../data/dietitian_repository.dart';
import '../../data/models.dart';
import '../../data/patient_repositories.dart';
import '../auth/signup_state.dart';
import '../messages/chat_state.dart';

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// 9. Accueil patient.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Objectifs cochés pendant cette session (avant retour du serveur).
  Set<int>? _local;

  Future<void> _toggleGoal(int i, Set<int> current) async {
    final next = {...current};
    next.contains(i) ? next.remove(i) : next.add(i);
    setState(() => _local = next);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(journalRepositoryProvider)
          .setGoals(dateOnly(DateTime.now()), next);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _local = current);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fr = locale.startsWith('fr');
    final name = ref.watch(signupProvider).name.split(' ').first;
    final today = DateTime.now();
    final dateText = _cap(
      DateFormat(fr ? 'EEEE d MMMM' : 'EEEE, MMMM d', locale).format(today),
    );
    final goals = [l.homeGoal1, l.homeGoal2, l.homeGoal3];
    final done =
        _local ?? ref.watch(goalsProvider(dateOnly(today))).value ?? <int>{};
    final next = ref.watch(nextAppointmentProvider);
    final dietitians =
        ref.watch(dietitiansProvider).value ?? const <Dietitian>[];
    final lastMessage = ref.watch(lastDietitianMessageProvider).value;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Tch.pagePadding,
            Tch.topInset(context),
            Tch.pagePadding,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: Tch.style(14, color: Tch.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.homeHello(name),
                      style: Tch.style(28, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                index: 1,
                child: next.when(
                  data: (a) => a == null
                      ? _EmptyAppointmentCard(
                          title: l.homeNoAppointment,
                          action: l.homeBookNow,
                          onTap: () => context.go('/directory'),
                        )
                      : _NextAppointmentCard(
                          title: l.homeNext,
                          month: DateFormat(
                            'MMM',
                            locale,
                          ).format(a.startsAt).toUpperCase(),
                          day: '${a.startsAt.day}',
                          time:
                              '${_cap(DateFormat('EEEE', locale).format(a.startsAt))} · ${DateFormat('HH:mm').format(a.startsAt)}',
                          who:
                              '${dietitians.where((d) => d.id == a.dietitianId).map((d) => d.name).firstOrNull ?? ''} · ${a.mode == 'video' ? l.modeVideo : l.modeOffice}'
                                  .replaceFirst(RegExp(r'^ · '), ''),
                          join: a.status == 'pending'
                              ? l.homePending
                              : l.homeJoin,
                          onJoin: a.status == 'pending' || a.mode != 'video'
                              ? null
                              : () => context.push('/video/waiting'),
                        ),
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(color: Tch.green),
                    ),
                  ),
                  error: (e, _) => AsyncView<void>(
                    value: AsyncError<void>(e, StackTrace.empty),
                    onRetry: () => ref.invalidate(nextAppointmentProvider),
                    builder: (_) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                index: 2,
                child: TchCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l.today,
                            style: Tch.style(17, weight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Tch.greenLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${done.length} / 3',
                              style: Tch.style(
                                13,
                                weight: FontWeight.w600,
                                color: Tch.greenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      for (var i = 0; i < goals.length; i++)
                        _GoalRow(
                          label: goals[i],
                          on: done.contains(i),
                          onTap: () => _toggleGoal(i, done),
                        ),
                    ],
                  ),
                ),
              ),
              if (lastMessage != null) const SizedBox(height: 16),
              if (lastMessage != null)
                FadeSlideIn(
                  index: 3,
                  child: PressScale(
                    onTap: () => context.go('/messages'),
                    child: TchCard(
                      color: Tch.peachLight,
                      shadow: false,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const TchAvatar(initials: 'EM'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lastMessage.seed != null
                                  ? l.homeMsg
                                  : (lastMessage.text ?? ''),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Tch.style(14, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: Tch.pagePadding,
          bottom: 18,
          child: Pulse(
            child: PressScale(
              semanticLabel: l.homeAddMeal,
              onTap: () => context.go('/journal/add'),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Tch.coral,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: TchIcon(
                    TchIcons.plus,
                    size: 28,
                    color: Colors.white,
                    strokeWidth: 2.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.title,
    required this.month,
    required this.day,
    required this.time,
    required this.who,
    required this.join,
    required this.onJoin,
  });
  final String title, month, day, time, who, join;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Tch.green,
      borderRadius: BorderRadius.circular(Tch.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Tch.style(
            13,
            weight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    month,
                    style: Tch.style(
                      11,
                      weight: FontWeight.w600,
                      color: Tch.coralText,
                    ),
                  ),
                  Text(
                    day,
                    style: Tch.style(22, weight: FontWeight.w700, height: 1.1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: Tch.style(
                      17,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    who,
                    style: Tch.style(
                      14,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        PressScale(
          onTap: onJoin,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onJoin == null
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              join,
              style: Tch.style(
                15,
                weight: FontWeight.w600,
                color: Tch.greenDark,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyAppointmentCard extends StatelessWidget {
  const _EmptyAppointmentCard({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Tch.green,
      borderRadius: BorderRadius.circular(Tch.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Tch.style(17, weight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 14),
        PressScale(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              action,
              style: Tch.style(
                15,
                weight: FontWeight.w600,
                color: Tch.greenDark,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Tch.selectDuration,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: on ? Tch.green : Tch.surface,
              borderRadius: BorderRadius.circular(10),
              border: on ? null : Border.all(color: Tch.checkBorder, width: 2),
            ),
            child: on
                ? const Center(
                    child: TchIcon(
                      TchIcons.check,
                      size: 16,
                      color: Colors.white,
                      strokeWidth: 3.5,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Tch.style(15, weight: FontWeight.w500)),
          ),
        ],
      ),
    ),
  );
}
