import 'package:material_ui/material_ui.dart';
import '../../app/theme.dart';

/// Carte : fond blanc, rayon 24, ombre douce.
class TchCard extends StatelessWidget {
  const TchCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.color = Tch.surface,
    this.radius = Tch.cardRadius,
    this.shadow = true,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow ? Tch.cardShadow : null,
        ),
        child: child,
      );
}
