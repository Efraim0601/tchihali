import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/api_errors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_button.dart';
import '../../core/widgets/tch_checkbox.dart';
import '../../core/widgets/tch_text_field.dart';
import '../../data/api/api_client.dart';
import '../../data/auth_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'signup_state.dart';

/// Gabarit des écrans d'inscription : marges 24, défilement si besoin.
class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.onBack,
    required this.title,
    required this.sub,
    required this.body,
    required this.footer,
  });
  final VoidCallback onBack;
  final String title;
  final String sub;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Tch.background,
        body: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(Tch.authPadding,
                      Tch.topInset(context), Tch.authPadding, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TchBackButton(onTap: onBack)),
                      const SizedBox(height: 28),
                      FadeSlideIn(
                        index: 1,
                        child: Text(title,
                            style: Tch.style(28, weight: FontWeight.w700, height: 1.2)),
                      ),
                      const SizedBox(height: 8),
                      FadeSlideIn(
                        index: 2,
                        child: Text(sub,
                            style: Tch.style(15,
                                color: Tch.textSecondary, height: 1.5)),
                      ),
                      const SizedBox(height: 28),
                      FadeSlideIn(index: 3, child: body),
                      const Spacer(),
                      const SizedBox(height: 18),
                      footer,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// 4. Inscription : nom + téléphone (+237), sans mot de passe.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Valeurs de test (patiente de démonstration).
  final _name = TextEditingController(text: 'Nadège Ngono');
  final _phone = TextEditingController(text: '677 21 36 90');
  bool _terms = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _phone.text.replaceAll(RegExp(r'\D'), '').length >= 9 &&
      _terms;

  bool _busy = false;

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).requestCode(
            phone: toE164(_phone.text),
            name: _name.text.trim(),
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ref.read(signupProvider.notifier).set(_name.text.trim(), _phone.text.trim());
    context.go('/signup/code');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget label(String s) => Text(s, style: Tch.style(14, weight: FontWeight.w600));
    return _AuthLayout(
      onBack: () => context.go('/onboarding/3'),
      title: l.signupTitle,
      sub: l.signupSub,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label(l.fieldName),
          const SizedBox(height: 8),
          TchTextField(
              controller: _name,
              semanticLabel: l.fieldName,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 18),
          label(l.fieldPhone),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Tch.surface,
                  borderRadius: BorderRadius.circular(Tch.fieldRadius),
                  border: Border.all(color: Tch.border, width: 1.5),
                ),
                child: Text('+237', style: Tch.style(16, weight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TchTextField(
                  controller: _phone,
                  semanticLabel: l.fieldPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.phoneHint, style: Tch.style(13, color: Tch.textSecondary)),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _terms = !_terms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: TchCheckbox(checked: _terms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.terms,
                      style: Tch.style(13,
                          color: const Color(0xFF4A5054), height: 1.45)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TchButton(label: l.signupCta, onPressed: _valid && !_busy ? _submit : null),
        ],
      ),
    );
  }
}

/// 4 bis. Saisie du code SMS (écran à prévoir par ECRANS.md, même style).
/// Maquette absente : tout code de 6 chiffres est accepté tant qu'il n'y a pas de backend.
class SmsCodeScreen extends ConsumerStatefulWidget {
  const SmsCodeScreen({super.key});

  @override
  ConsumerState<SmsCodeScreen> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends ConsumerState<SmsCodeScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();

  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final signup = ref.read(signupProvider);
    setState(() => _busy = true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .verify(phone: toE164(signup.phone), code: code);
      if (user.fullName.isNotEmpty) {
        ref.read(signupProvider.notifier).set(user.fullName, signup.phone);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _code.clear();
      });
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e, codeContext: true))));
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    context.go('/questionnaire/1');
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final signup = ref.read(signupProvider);
    setState(_code.clear);
    try {
      await ref
          .read(authRepositoryProvider)
          .requestCode(phone: toE164(signup.phone), name: signup.name);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final phone = ref.watch(signupProvider).phone;
    final value = _code.text;
    return _AuthLayout(
      onBack: () => context.go('/signup'),
      title: l.codeTitle,
      sub: l.codeSub(phone),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 6; i++)
                  AnimatedContainer(
                    duration: Tch.selectDuration,
                    width: 48,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tch.surface,
                      borderRadius: BorderRadius.circular(Tch.fieldRadius),
                      border: Border.all(
                          color: i == value.length ? Tch.green : Tch.border,
                          width: 1.5),
                    ),
                    child: Text(i < value.length ? value[i] : '',
                        style: Tch.style(22, weight: FontWeight.w600)),
                  ),
              ],
            ),
            // Champ réel invisible qui reçoit la saisie.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _code,
                  focusNode: _focus,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          TchButton(
            label: l.codeCta,
            onPressed: value.length == 6 && !_busy ? () => _verify(value) : null,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _resend,
            child: Container(
              height: 48,
              margin: const EdgeInsets.only(top: 8),
              alignment: Alignment.center,
              child: Text(l.codeResend,
                  style: Tch.style(15, weight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
