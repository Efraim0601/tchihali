import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/tch_back_button.dart';
import '../../l10n/gen/app_localizations.dart';
import 'legal_texts.dart';

enum LegalKind { terms, privacy }

/// Conditions d'utilisation ou politique de confidentialité (accessibles sans connexion).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.kind});
  final LegalKind kind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final sections = kind == LegalKind.terms ? termsSections : privacySections;
    return Scaffold(
      backgroundColor: Tch.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Tch.pagePadding,
          Tch.topInset(context),
          Tch.pagePadding,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  TchBackButton(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/signup'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      kind == LegalKind.terms
                          ? l.legalTermsTitle
                          : l.legalPrivacyTitle,
                      style: Tch.style(22, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final s in sections) ...[
              Text(
                s.title.of(locale),
                style: Tch.style(16, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                s.body.of(locale),
                style: Tch.style(
                  14,
                  color: const Color(0xFF4A5054),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
