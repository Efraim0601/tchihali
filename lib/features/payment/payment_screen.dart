import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/format.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_avatar.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_icons.dart';
import '../../core/widgets/tch_radio.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/dietitian_repository.dart';
import '../../data/models.dart';
import '../../data/payment_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/signup_state.dart';
import '../booking/booking_state.dart';

/// 8. Paiement : récapitulatif, moyen de paiement, numéro Mobile Money.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PayMethod _method = PayMethod.orangeMoney;
  late final TextEditingController _number = TextEditingController(
    text: '+237 ${ref.read(signupProvider).phone}',
  );
  bool _paying = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  bool get _mobile => _method != PayMethod.card;
  bool get _valid =>
      !_mobile || _number.text.replaceAll(RegExp(r'\D'), '').length >= 9;

  Future<void> _pay(BookingState b) async {
    setState(() => _paying = true);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(paymentRepositoryProvider)
          .payAndBook(
            BookingPayment(
              dietitianId: b.dietitian.id,
              day: b.day,
              time: b.slot,
              mode: b.mode,
              method: _method,
              phone: _mobile ? _number.text.trim() : null,
            ),
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      // Créneau pris entre-temps : on revient choisir un autre créneau.
      if (e.isConflict) {
        ref.invalidate(dietitiansProvider);
        context.go('/booking');
      }
      return;
    }
    if (!mounted) return;
    setState(() => _paying = false);
    ref.invalidate(dietitiansProvider);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final b = ref.watch(bookingProvider);
    final modeLabel = b.mode == ConsultMode.video ? l.modeVideo : l.modeOffice;
    final when = '${formatLongDay(b.day, locale, capital: true)} · ${b.slot}';
    final methods = [
      (
        PayMethod.orangeMoney,
        'OM',
        'Orange Money',
        const Color(0xFFFCE3CF),
        const Color(0xFF9A4A12),
      ),
      (
        PayMethod.mtnMomo,
        'MTN',
        'MTN MoMo',
        const Color(0xFFFBF0B8),
        const Color(0xFF6B5A00),
      ),
      (PayMethod.card, 'CB', l.payCard, Tch.greenLight, Tch.greenDark),
    ];

    return Scaffold(
      backgroundColor: Tch.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                Tch.pagePadding,
                Tch.topInset(context),
                Tch.pagePadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    child: Row(
                      children: [
                        TchBackButton(onTap: () => context.go('/booking')),
                        const SizedBox(width: 12),
                        Text(
                          l.payTitle,
                          style: Tch.style(22, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Tch.greenLight,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          TchAvatar(
                            initials: b.dietitian.initials,
                            size: 48,
                            radius: 16,
                            background: b.dietitian.avatarBg,
                            foreground: b.dietitian.avatarFg,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.dietitian.name} · $modeLabel',
                                  style: Tch.style(15, weight: FontWeight.w600),
                                ),
                                Text(
                                  when,
                                  style: Tch.style(
                                    13,
                                    color: const Color(0xFF3E4F43),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    index: 2,
                    child: Text(
                      l.payHow,
                      style: Tch.style(16, weight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < methods.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    FadeSlideIn(
                      index: 3 + i,
                      child: _MethodRow(
                        short: methods[i].$2,
                        label: methods[i].$3,
                        bg: methods[i].$4,
                        fg: methods[i].$5,
                        on: _method == methods[i].$1,
                        onTap: () => setState(() => _method = methods[i].$1),
                      ),
                    ),
                  ],
                  AnimatedSize(
                    duration: Tch.selectDuration,
                    alignment: Alignment.topCenter,
                    child: _mobile
                        ? Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.payNumber,
                                  style: Tch.style(14, weight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TchTextField(
                                  controller: _number,
                                  height: 54,
                                  semanticLabel: l.payNumber,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9 +]'),
                                    ),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).padding.bottom.clamp(18, 40),
            ),
            child: Column(
              children: [
                TchButton(
                  label: l.payCta(formatFcfa(b.price, locale)),
                  height: 58,
                  icon: const TchIcon(
                    TchIcons.lock,
                    size: 18,
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                  onPressed: _valid && !_paying ? () => _pay(b) : null,
                ),
                const SizedBox(height: 10),
                Text(
                  l.payCancel,
                  textAlign: TextAlign.center,
                  style: Tch.style(12, color: Tch.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.short,
    required this.label,
    required this.bg,
    required this.fg,
    required this.on,
    required this.onTap,
  });
  final String short;
  final String label;
  final Color bg;
  final Color fg;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Tch.selectDuration,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Tch.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: on ? Tch.green : Tch.borderLight, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              short,
              style: Tch.style(13, weight: FontWeight.w700, color: fg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Tch.style(15, weight: FontWeight.w600)),
          ),
          TchRadio(on: on),
        ],
      ),
    ),
  );
}
