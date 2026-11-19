import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import 'tch_icons.dart';

/// Case à cocher : 22 px, vert quand cochée.
class TchCheckbox extends StatelessWidget {
  const TchCheckbox({super.key, required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Tch.selectDuration,
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: checked ? Tch.green : Tch.surface,
      borderRadius: BorderRadius.circular(6),
      border: checked ? null : Border.all(color: Tch.checkBorder, width: 2),
    ),
    child: checked
        ? const Center(
            child: TchIcon(
              TchIcons.check,
              size: 14,
              color: Colors.white,
              strokeWidth: 3.5,
            ),
          )
        : null,
  );
}
