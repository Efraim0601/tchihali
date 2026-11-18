import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/locale_provider.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../core/widgets/tch_pill_switch.dart';
import '../../l10n/gen/app_localizations.dart';
import 'onboarding_widgets.dart';

/// 1. Bienvenue + choix de langue.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return OnboardingLayout(
      top: const _TopBar(),
      illustration: const PlateIllustration(),
      title: l.onb1Title,
      text: l.onb1Text,
      cta: l.onb1Start,
      onCta: () => context.go('/onboarding/2'),
      below: FadeSlideIn(
        index: 4,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.go('/signup'),
          child: Container(
            height: 48,
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            child: Text(l.onb1Login, style: Tch.style(15, weight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  static const _logo = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28"><circle cx="14" cy="14" r="14" fill="#4F7A5A"/>
<path d="M9 18c0-6 4-9 10-9 0 6-3 10-9 10" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/></svg>''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(localeProvider).languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          SvgPicture.string(_logo, width: 30, height: 30),
          const SizedBox(width: 8),
          Text(l.appName, style: Tch.style(18, weight: FontWeight.w700)),
        ]),
        TchPillSwitch(
          semanticLabel: l.langLabel,
          labels: const ['FR', 'EN'],
          selectedIndex: lang == 'fr' ? 0 : 1,
          horizontalPadding: 14,
          activeWeight: FontWeight.w700,
          onChanged: (i) =>
              ref.read(localeProvider.notifier).set(Locale(i == 0 ? 'fr' : 'en')),
        ),
      ],
    );
  }
}

/// 2. Journal photo.
class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OnboardingLayout(
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TchBackButton(onTap: () => context.go('/onboarding/1')),
          _SkipLink(label: l.skip),
        ],
      ),
      illustration: PhotoCardIllustration(kcal: l.onbKcal),
      dots: 1,
      title: l.onb2Title,
      text: l.onb2Text,
      cta: l.next,
      onCta: () => context.go('/onboarding/3'),
    );
  }
}

/// 3. Cabinet ou vidéo.
class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OnboardingLayout(
      top: Align(
        alignment: Alignment.centerLeft,
        child: TchBackButton(onTap: () => context.go('/onboarding/2')),
      ),
      illustration:
          AppointmentCardIllustration(label: l.onb3Card, confirmed: l.onb3Confirmed),
      dots: 2,
      title: l.onb3Title,
      text: l.onb3Text,
      cta: l.onb3Cta,
      onCta: () => context.go('/signup'),
    );
  }
}

class _SkipLink extends StatelessWidget {
  const _SkipLink({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go('/signup'),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          child: Text(label,
              style: Tch.style(15, weight: FontWeight.w500, color: Tch.textSecondary)),
        ),
      );
}
