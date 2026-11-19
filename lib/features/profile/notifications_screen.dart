import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/async_view.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_card.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/patient_models.dart';
import '../../data/patient_repositories.dart';
import '../../l10n/gen/app_localizations.dart';

/// Liste des notifications ; elles sont marquées comme lues à l'ouverture.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void dispose() {
    // Marquage « lu » quand on quitte l'écran : les non lues restent visibles pendant la lecture.
    ref
        .read(notificationsRepositoryProvider)
        .readAll()
        .then((_) {}, onError: (_) {});
    super.dispose();
  }

  String _text(AppLocalizations l, String locale, AppNotification n) {
    final d = n.data;
    String when() {
      final raw = d['starts_at'] as String?;
      if (raw == null) return '';
      final t = DateTime.parse(raw).toLocal();
      return '${formatSlotDay(t, locale)} ${hhmm(t)}';
    }

    return switch (n.kind) {
      'appointment_confirmed' => l.notifAppointmentConfirmed(
        when(),
        '${d['dietitian'] ?? ''}',
      ),
      'appointment_refused' => l.notifAppointmentRefused(when()),
      'report_sent' => l.notifReportSent(
        (d['session_no'] as num?)?.toInt() ?? 0,
      ),
      'new_message' => l.notifNewMessage(
        '${d['dietitian'] ?? d['patient'] ?? ''}',
      ),
      'appointment_request' => l.notifAppointmentRequest(
        '${d['patient'] ?? ''}',
        when(),
      ),
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final list = ref.watch(notificationsProvider);

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
                Text(
                  l.notifTitle,
                  style: Tch.style(24, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AsyncView<List<AppNotification>>(
            value: list,
            onRetry: () => ref.invalidate(notificationsProvider),
            builder: (items) => items.isEmpty
                ? TchCard(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        l.notifEmpty,
                        textAlign: TextAlign.center,
                        style: Tch.style(15, color: Tch.textSecondary),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        FadeSlideIn(
                          index: i,
                          child: TchCard(
                            radius: 20,
                            color: items[i].read ? Tch.surface : Tch.greenLight,
                            shadow: items[i].read,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Tch.surface,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Center(
                                    child: TchIcon(
                                      items[i].kind == 'new_message'
                                          ? TchIcons.messages
                                          : items[i].kind == 'report_sent'
                                          ? TchIcons.report
                                          : TchIcons.agenda,
                                      size: 20,
                                      color: Tch.greenDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _text(l, locale, items[i]),
                                        style: Tch.style(14, height: 1.45),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat.MMMEd(locale)
                                            .add_Hm()
                                            .format(items[i].createdAt),
                                        style: Tch.style(
                                          12,
                                          color: Tch.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
