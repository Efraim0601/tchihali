import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Courbe de suivi : ligne verte, zone remplie, objectif en pointillés corail,
/// tracée progressivement de gauche à droite (1,6 s).
class TchCurve extends StatelessWidget {
  const TchCurve({
    super.key,
    required this.data,
    required this.min,
    required this.max,
    this.goal,
    this.goalLabel,
    required this.semanticLabel,
    this.height = 160,
    this.hollowDot = true,
    this.labelSize = 11,
  });
  final List<double> data;
  final double min;
  final double max;
  final double? goal;
  final String? goalLabel;
  final String semanticLabel;
  final double height;

  /// Point final blanc cerclé de vert (patient) ou plein (praticien).
  final bool hollowDot;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    final spots = [
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
    ];
    final step = (max - min) / 4;
    final chart = LineChart(
      duration: Duration.zero,
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: min,
        maxY: max,
        clipData: const FlClipData.none(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          // 3 lignes de repère : 1/4, 1/2 et 3/4 de la hauteur.
          checkToShowHorizontalLine: (v) {
            final k = (v - min) / step;
            return k > 0.5 && k < 3.5;
          },
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFF0EBE3), strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (goal != null && goalLabel != null)
              HorizontalLine(
                y: goal!,
                color: Tch.coral,
                strokeWidth: 1.5,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(bottom: 4),
                  style: Tch.style(
                    labelSize,
                    weight: FontWeight.w600,
                    color: Tch.coralText,
                  ),
                  labelResolver: (_) => goalLabel!,
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Tch.green,
            barWidth: 3,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            dotData: FlDotData(
              checkToShowDot: (spot, bar) => spot == bar.spots.last,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 6,
                color: hollowDot ? Colors.white : Tch.green,
                strokeWidth: hollowDot ? 3 : 0,
                strokeColor: Tch.green,
              ),
            ),
            belowBarData: BarAreaData(show: true, color: Tch.greenLight),
          ),
        ],
      ),
    );
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduced ? 1 : 0, end: 1),
          duration: reduced
              ? Duration.zero
              : const Duration(milliseconds: 1600),
          curve: Curves.easeOut,
          builder: (_, t, child) => ClipRect(clipper: _Reveal(t), child: child),
          child: Padding(
            padding: const EdgeInsets.only(right: 6, left: 6, top: 4),
            child: chart,
          ),
        ),
      ),
    );
  }
}

/// Découvre la courbe de gauche à droite.
class _Reveal extends CustomClipper<Rect> {
  _Reveal(this.t);
  final double t;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(-8, -8, (size.width + 16) * t, size.height + 16);

  @override
  bool shouldReclip(_Reveal old) => old.t != t;
}
