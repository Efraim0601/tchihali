import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Bouton radio : cercle de 24 px, anneau épais (7 px) quand il est choisi.
class TchRadio extends StatelessWidget {
  const TchRadio({super.key, required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Tch.selectDuration,
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: on ? Tch.green : Tch.checkBorder,
        width: on ? 7 : 2,
      ),
    ),
  );
}
