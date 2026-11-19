import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'animations.dart';

/// Puce : 42 de haut, rayon 14. Sélection = fond vert, texte blanc.
/// 1 px de marge verticale pour atteindre une zone tactile de 44.
class TchChip extends StatelessWidget {
  const TchChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.background = Tch.surface,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color background;

  @override
  Widget build(BuildContext context) => PressScale(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AnimatedContainer(
        duration: Tch.selectDuration,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Tch.green : background,
          borderRadius: BorderRadius.circular(Tch.chipRadius),
          border: Border.all(
            color: selected ? Tch.green : Tch.border,
            width: 1.5,
          ),
        ),
        child: SizedBox(
          height: 39,
          child: Center(
            widthFactor: 1,
            child: AnimatedDefaultTextStyle(
              duration: Tch.selectDuration,
              style: Tch.style(
                14,
                weight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : Tch.text,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    ),
  );
}
