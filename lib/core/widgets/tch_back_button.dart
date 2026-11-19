import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'animations.dart';
import 'tch_icons.dart';

/// Bouton retour : 44 × 44, rayon 14.
class TchBackButton extends StatelessWidget {
  const TchBackButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => PressScale(
    semanticLabel: AppLocalizations.of(context).back,
    onTap: onTap ?? () => Navigator.of(context).maybePop(),
    child: Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Tch.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: Tch.cardShadow,
      ),
      child: const TchIcon(TchIcons.back, size: 22, color: Tch.text),
    ),
  );
}
