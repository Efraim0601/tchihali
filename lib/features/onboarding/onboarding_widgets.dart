import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_button.dart';

/// Gabarit commun des écrans d'onboarding : marges 28, défilement si l'écran est petit.
class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.top,
    required this.illustration,
    required this.title,
    required this.text,
    required this.cta,
    required this.onCta,
    this.dots,
    this.below,
  });
  final Widget top;
  final Widget illustration;
  final int? dots;
  final String title;
  final String text;
  final String cta;
  final VoidCallback onCta;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tch.background,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Tch.onboardingPadding,
                  Tch.topInset(context),
                  Tch.onboardingPadding,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    top,
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: illustration,
                        ),
                      ),
                    ),
                    if (dots != null) ...[
                      ProgressDots(count: 3, active: dots!),
                      const SizedBox(height: 24),
                    ],
                    FadeSlideIn(
                      index: 1,
                      child: Text(title,
                          style: Tch.style(30, weight: FontWeight.w700, height: 1.2)),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      index: 2,
                      child: Text(text,
                          style: Tch.style(16,
                              color: Tch.textSecondary, height: 1.55)),
                    ),
                    const SizedBox(height: 32),
                    FadeSlideIn(
                        index: 3, child: TchButton(label: cta, onPressed: onCta)),
                    ?below,
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

/// Points de progression : 8 px, le point actif fait 28 px de large.
class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: Tch.selectDuration,
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 8),
              width: i == active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == active ? Tch.green : const Color(0xFFD5DED2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      );
}

/// Pastille ronde de 280 px derrière les illustrations.
class IllustrationCircle extends StatelessWidget {
  const IllustrationCircle({super.key, required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: 280,
        height: 280,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: child,
      );
}

const _illuShadow = [
  BoxShadow(color: Color(0x1A2F3437), blurRadius: 30, offset: Offset(0, 12)),
];

/// Grande assiette de l'écran 1 (SVG de la maquette).
class PlateIllustration extends StatelessWidget {
  const PlateIllustration({super.key});

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 260 260">
<circle cx="130" cy="130" r="122" fill="#E7EFE4"/>
<path d="M30 70c22-14 46-4 50 16-22 10-44 2-50-16z" fill="#8FB394"/>
<path d="M214 190c-18 14-40 8-46-10 18-12 40-8 46 10z" fill="#F6C7B4"/>
<circle cx="130" cy="138" r="88" fill="#FFFFFF"/>
<circle cx="130" cy="138" r="72" fill="#F7F3EC"/>
<ellipse cx="106" cy="122" rx="36" ry="27" fill="#F3E3B8"/>
<ellipse cx="152" cy="150" rx="32" ry="14" fill="#E39A6F" transform="rotate(-20 152 150)"/>
<circle cx="110" cy="172" r="15" fill="#8FB394"/><circle cx="128" cy="182" r="12" fill="#6E9A77"/>
<circle cx="160" cy="110" r="10" fill="#E8775F"/><circle cx="175" cy="124" r="8" fill="#E8775F"/>
</svg>''';

  @override
  Widget build(BuildContext context) => Float(
        child: SvgPicture.string(_svg, width: 280, height: 280),
      );
}

/// Petite assiette (carte photo de l'écran 2).
class SmallPlate extends StatelessWidget {
  const SmallPlate({super.key});

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110">
<circle cx="55" cy="55" r="48" fill="#FFFFFF"/><circle cx="55" cy="55" r="38" fill="#F7F3EC"/>
<ellipse cx="45" cy="48" rx="18" ry="14" fill="#F3E3B8"/>
<ellipse cx="66" cy="62" rx="16" ry="8" fill="#E39A6F" transform="rotate(-20 66 62)"/>
<circle cx="46" cy="70" r="8" fill="#8FB394"/><circle cx="68" cy="40" r="6" fill="#E8775F"/>
</svg>''';

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_svg, width: 104, height: 104);
}

/// Carte flottante de l'écran 2 : photo + « 540 kcal ».
class PhotoCardIllustration extends StatelessWidget {
  const PhotoCardIllustration({super.key, required this.kcal});
  final String kcal;

  @override
  Widget build(BuildContext context) => IllustrationCircle(
        color: Tch.peachLight,
        child: Float(
          child: Container(
            width: 180,
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Tch.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: _illuShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 130,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Tch.greenLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const SmallPlate(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Tch.greenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(kcal,
                      style: Tch.style(13,
                          weight: FontWeight.w600, color: Tch.greenDark)),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Carte flottante de l'écran 3 : rendez-vous confirmé.
class AppointmentCardIllustration extends StatelessWidget {
  const AppointmentCardIllustration(
      {super.key, required this.label, required this.confirmed});
  final String label;
  final String confirmed;

  @override
  Widget build(BuildContext context) => IllustrationCircle(
        color: Tch.greenLight,
        child: Float(
          child: Container(
            width: 190,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Tch.surface,
              borderRadius: BorderRadius.circular(26),
              boxShadow: _illuShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Tch.peach, shape: BoxShape.circle),
                  child: Text('EM',
                      style: Tch.style(16,
                          weight: FontWeight.w700, color: const Color(0xFF7A3522))),
                ),
                const SizedBox(height: 12),
                Text(label,
                    textAlign: TextAlign.center,
                    style: Tch.style(14, weight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Tch.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(confirmed,
                      style: Tch.style(13,
                          weight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
}
