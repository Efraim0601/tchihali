import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'animations.dart';

enum TchButtonStyle {
  primary,
  secondary,
  outlineCoral,
  outlineSoft,
  danger,
  neutral,
}

/// Bouton principal : 56 de haut, rayon 18, fond vert, texte blanc 16–17 px / 600.
class TchButton extends StatelessWidget {
  const TchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = TchButtonStyle.primary,
    this.height = Tch.buttonHeight,
    this.icon,
    this.expand = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final TchButtonStyle style;
  final double height;
  final Widget? icon;

  /// Pleine largeur par défaut ; sinon largeur du contenu (+ 24 px de marge de chaque côté).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      TchButtonStyle.primary => (Tch.green, Colors.white, null),
      TchButtonStyle.secondary => (Tch.surface, Tch.greenDark, Tch.border),
      TchButtonStyle.outlineCoral => (
        Colors.transparent,
        Tch.coralText,
        Tch.coral,
      ),
      TchButtonStyle.outlineSoft => (
        Tch.surface,
        Tch.coralText,
        const Color(0xFFF2C9BB),
      ),
      TchButtonStyle.danger => (Tch.danger, Colors.white, null),
      TchButtonStyle.neutral => (Tch.surface, Tch.text, Tch.border),
    };
    final enabled = onPressed != null;
    return PressScale(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Tch.selectDuration,
        height: height,
        width: expand ? double.infinity : null,
        padding: expand ? null : const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? bg : Tch.border,
          borderRadius: BorderRadius.circular(Tch.buttonRadius),
          border: border == null ? null : Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              label,
              style: Tch.style(16.5, weight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
