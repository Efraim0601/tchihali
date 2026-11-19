import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Avatar à initiales : fond pêche, texte #7A3522, rayon 15 par défaut.
class TchAvatar extends StatelessWidget {
  const TchAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.radius = 15,
    this.background = Tch.peach,
    this.foreground = const Color(0xFF7A3522),
  });
  final String initials;
  final double size;
  final double radius;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(
      initials,
      style: Tch.style(size * 0.32, weight: FontWeight.w700, color: foreground),
    ),
  );
}
