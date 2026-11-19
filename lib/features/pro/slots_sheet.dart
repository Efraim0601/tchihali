import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_chip.dart';
import '../../core/widgets/tch_icons.dart';
import '../../data/api/api_client.dart';
import '../../data/pro_models.dart';
import '../../data/pro_repository.dart';
import '../../l10n/gen/app_localizations.dart';

/// Gestion des disponibilités hebdomadaires : choisir un jour, ajouter ou retirer une heure.
class SlotsSheet extends ConsumerStatefulWidget {
  const SlotsSheet({super.key});

  @override
  ConsumerState<SlotsSheet> createState() => _SlotsSheetState();
}

class _SlotsSheetState extends ConsumerState<SlotsSheet> {
  int _weekday = 1;
  List<AvailabilitySlot>? _slots;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(proRepositoryProvider).availability();
      if (mounted) setState(() => _slots = s);
    } on ApiException catch (e) {
      _error(e);
    }
  }

  void _error(Object e) {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
  }

  Future<void> _add() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null) return;
    final hhmm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() => _busy = true);
    try {
      await ref.read(proRepositoryProvider).addSlot(_weekday, hhmm);
      await _load();
    } on ApiException catch (e) {
      _error(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(AvailabilitySlot s) async {
    setState(() => _busy = true);
    try {
      await ref.read(proRepositoryProvider).removeSlot(s.weekday, s.time);
      await _load();
    } on ApiException catch (e) {
      _error(e);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = l.proWeekdaysShort.split(',');
    final today = [...?_slots?.where((s) => s.weekday == _weekday)]
      ..sort((a, b) => a.time.compareTo(b.time));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.proAddSlotTitle,
              style: Tch.style(20, weight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (var i = 0; i < 7; i++)
                  TchChip(
                    label: days[i],
                    selected: _weekday == i + 1,
                    onTap: () => setState(() => _weekday = i + 1),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_slots == null)
              const Center(child: CircularProgressIndicator(color: Tch.green))
            else if (today.isEmpty)
              Text(
                l.proSlotNone,
                style: Tch.style(14, color: Tch.textSecondary),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in today)
                    Semantics(
                      button: true,
                      label: l.proSlotRemove(s.time),
                      child: GestureDetector(
                        onTap: _busy ? null : () => _remove(s),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          decoration: BoxDecoration(
                            color: Tch.greenLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.time,
                                style: Tch.style(
                                  14,
                                  weight: FontWeight.w600,
                                  color: Tch.greenDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const TchIcon(
                                TchIcons.close,
                                size: 16,
                                color: Tch.greenDark,
                                strokeWidth: 2.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            TchButton(label: l.proSlotPick, onPressed: _busy ? null : _add),
          ],
        ),
      ),
    );
  }
}
