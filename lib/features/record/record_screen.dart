import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_segmented.dart';
import '../../data/api/api_client.dart';
import '../../data/patient_models.dart';
import '../../data/patient_repositories.dart';
import '../../l10n/gen/app_localizations.dart';

const _mealTints = [
  (Tch.yellow, Tch.yellowText),
  (Tch.greenLight, Color(0xFF24412D)),
  (Tch.peachLight, Color(0xFF8A3A24)),
  (Color(0xFFE3E8EE), Color(0xFF34495E)),
];

/// 15. Carnet de suivi : séance, plan alimentaire, documents.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  int _tab = 0;

  Future<void> _open(RecordDocument d) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ref
          .read(recordRepositoryProvider)
          .documentBytes(d.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tchihali-${d.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      final res = await OpenFilex.open(file.path);
      if (res.type != ResultType.done) {
        messenger.showSnackBar(SnackBar(content: Text(l.recOpenError)));
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.recOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final record = ref.watch(recordProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Tch.pagePadding,
        Tch.topInset(context),
        Tch.pagePadding,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                TchBackButton(onTap: () => context.go('/profile')),
                const SizedBox(width: 12),
                Text(l.recTitle, style: Tch.style(24, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 1,
            child: TchSegmented(
              labels: [l.recTabSession, l.recTabPlan, l.recTabDocs],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 18),
          AsyncView<RecordData>(
            value: record,
            onRetry: () => ref.invalidate(recordProvider),
            builder: (data) => AnimatedSwitcher(
              duration: Tch.selectDuration,
              child: SizedBox(
                key: ValueKey(_tab),
                width: double.infinity,
                child: switch (_tab) {
                  0 => _sessionTab(l, data),
                  1 => _planTab(l, data),
                  _ => _docsTab(l, data),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) => TchCard(
    padding: const EdgeInsets.all(20),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: Tch.style(15, color: Tch.textSecondary, height: 1.5),
    ),
  );

  Widget _sessionTab(AppLocalizations l, RecordData data) {
    final locale = Localizations.localeOf(context).toString();
    final String head, date, summary;
    final List<String> goals;
    if (data.isDemo) {
      head = l.recSession;
      date = l.recDate;
      summary = l.recSummary;
      goals = [l.recGoal1, l.recGoal2, l.recGoal3];
    } else if (data.session == null) {
      return _empty(l.recNoSession);
    } else {
      final s = data.session!;
      head = l.recSessionLabel(
        s.number,
        s.mode == 'video' ? l.modeVideo : l.modeOffice,
      );
      date = formatLongDay(s.heldOn, locale, capital: true);
      summary = s.summary;
      goals = [for (final g in s.goals) g.text];
    }
    return TchCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            head,
            style: Tch.style(
              12,
              weight: FontWeight.w500,
              color: Tch.textSecondary,
            ),
          ),
          Text(date, style: Tch.style(17, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          Text(
            summary,
            style: Tch.style(15, color: const Color(0xFF4A5054), height: 1.6),
          ),
          if (goals.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.recGoalsTitle,
              style: Tch.style(15, weight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            for (final g in goals)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 9, right: 10),
                      decoration: const BoxDecoration(
                        color: Tch.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(g, style: Tch.style(15, height: 1.45)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _planTab(AppLocalizations l, RecordData data) {
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
    final List<String> texts;
    if (data.isDemo) {
      texts = [l.recMealText1, l.recMealText2, l.recMealText3, l.recMealText4];
    } else {
      final plan = [...?data.plan]..removeWhere((m) => m.text.trim().isEmpty);
      if (plan.isEmpty) return _empty(l.recNoPlan);
      texts = [for (final m in data.plan!) m.text];
    }
    return Column(
      children: [
        for (var i = 0; i < texts.length && i < 4; i++) ...[
          if (texts[i].trim().isEmpty)
            const SizedBox.shrink()
          else ...[
            if (i > 0) const SizedBox(height: 12),
            TchCard(
              radius: 22,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _mealTints[i].$1,
                      borderRadius: BorderRadius.circular(15),
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels[i],
                          style: Tch.style(
                            12,
                            weight: FontWeight.w500,
                            color: Tch.textSecondary,
                          ),
                        ),
                        Text(
                          texts[i],
                          style: Tch.style(15, weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _docsTab(AppLocalizations l, RecordData data) {
    final docs = data.isDemo
        ? [
            RecordDocument(
              id: 'd1',
              name: l.recDoc1,
              meta: l.recDoc1Meta,
              downloadable: false,
            ),
            RecordDocument(
              id: 'd2',
              name: l.recDoc2,
              meta: l.recDoc2Meta,
              downloadable: false,
            ),
            RecordDocument(
              id: 'd3',
              name: l.recDoc3,
              meta: l.recDoc3Meta,
              downloadable: false,
            ),
          ]
        : data.documents;
    if (docs.isEmpty) return _empty(l.recNoDocs);
    return Column(
      children: [
        for (var i = 0; i < docs.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          TchCard(
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Tch.greenLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: TchIcon(
                      TchIcons.report,
                      size: 20,
                      color: Tch.greenDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docs[i].name,
                        style: Tch.style(15, weight: FontWeight.w500),
                      ),
                      Text(
                        docs[i].meta,
                        style: Tch.style(12, color: Tch.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (docs[i].downloadable)
                  PressScale(
                    semanticLabel: l.recDownload,
                    onTap: () => _open(docs[i]),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: TchIcon(
                          TchIcons.download,
                          size: 20,
                          color: Tch.text,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
