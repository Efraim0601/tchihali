import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_card.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'pro_shell.dart';

EdgeInsets _pad(BuildContext context) {
  final narrow = MediaQuery.of(context).size.width < proWideBreakpoint;
  return EdgeInsets.fromLTRB(narrow ? 20 : 32, 28, narrow ? 20 : 32, 28);
}

/// Liste des patients : mène à la fiche patient ou au compte rendu (selon l'entrée du menu).
class ProPatientsScreen extends ConsumerWidget {
  const ProPatientsScreen({super.key, required this.forReports});
  final bool forReports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: _pad(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text(
              forReports ? l.proReportsTitle : l.proPatientsTitle,
              style: Tch.style(30, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 18),
          AsyncView<List<ProPatientSummary>>(
            value: ref.watch(proPatientsProvider),
            onRetry: () => ref.invalidate(proPatientsProvider),
            builder: (list) => list.isEmpty
                ? TchCard(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        l.proNoPatients,
                        textAlign: TextAlign.center,
                        style: Tch.style(15, color: Tch.textSecondary),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < list.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        FadeSlideIn(
                          index: i,
                          child: PressScale(
                            onTap: () => context.go(
                              forReports
                                  ? '/pro/reports/${list[i].id}'
                                  : '/pro/patients/${list[i].id}',
                            ),
                            child: TchCard(
                              radius: 20,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  TchAvatar(
                                    initials: list[i].initials,
                                    size: 44,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      list[i].name,
                                      style: Tch.style(
                                        15,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
