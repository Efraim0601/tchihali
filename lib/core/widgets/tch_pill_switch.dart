import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Petit sélecteur à deux ou trois valeurs (FR / EN, Français / English) :
/// fond #EFEAE2, padding 4, onglets de 36 px, actif blanc avec ombre.
class TchPillSwitch extends StatelessWidget {
  const TchPillSwitch({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.horizontalPadding = 12,
    this.activeWeight = FontWeight.w600,
    this.semanticLabel,
    this.expand = false,
  });
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double horizontalPadding;
  final FontWeight activeWeight;
  final String? semanticLabel;

  /// Occupe toute la largeur disponible, onglets de même taille.
  final bool expand;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Tch.segmented,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _wrap(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: Tch.selectDuration,
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: i == selectedIndex
                        ? const [
                            BoxShadow(
                              color: Color(0x1A2F3437),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: Tch.style(
                      13,
                      weight: i == selectedIndex
                          ? activeWeight
                          : FontWeight.w500,
                      color: i == selectedIndex ? Tch.text : Tch.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _wrap(Widget w) => expand ? Expanded(child: w) : w;
}
