import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';

/// Contrôle segmenté : fond #EFEAE2, padding 5, onglet actif blanc avec ombre légère.
class TchSegmented extends StatelessWidget {
  const TchSegmented({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Tch.segmented,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: Tch.selectDuration,
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selectedIndex ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: i == selectedIndex
                          ? const [
                              BoxShadow(
                                color: Color(0x142F3437),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: Tch.selectDuration,
                      style: Tch.style(
                        14,
                        weight: i == selectedIndex ? FontWeight.w600 : FontWeight.w500,
                        color: i == selectedIndex ? Tch.text : Tch.textSecondary,
                      ),
                      child: Text(labels[i]),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}
