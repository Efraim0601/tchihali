import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

bool _reduced(BuildContext c) => MediaQuery.of(c).disableAnimations;

/// Apparition : fondu + glissement de 16 px vers le haut (600 ms).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;

  /// Rang de l'élément : décalage de 80 ms par rang.
  final int index;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Tch.riseDuration,
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Tch.riseCurve,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduced(context)) {
      _c.value = 1;
    } else {
      Future.delayed(Tch.riseStagger * widget.index, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    child: widget.child,
    builder: (_, child) => Opacity(
      opacity: _a.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - _a.value)),
        child: child,
      ),
    ),
  );
}

/// Appui : léger rétrécissement (échelle 0,95, 180 ms).
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = _reduced(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.95 : 1,
          duration: reduced ? Duration.zero : Tch.pressDuration,
          curve: Curves.ease,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Pulsation douce : halo qui s'étend (2 s), comme `tcPulse`.
class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    required this.child,
    this.color = Tch.coral,
    this.radius = 22,
    this.spread = 12,
    this.shape = BoxShape.rectangle,
  });
  final Widget child;
  final Color color;
  final double radius;
  final double spread;
  final BoxShape shape;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!_reduced(context)) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) {
      // 0 → 70 % : halo 0 → spread, opacité 0,5 → 0 ; puis repos.
      final p = (_c.value / 0.7).clamp(0.0, 1.0);
      final active = _c.isAnimating && _c.value < 0.7;
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.circle
              ? null
              : BorderRadius.circular(widget.radius),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5 * (1 - p)),
                    spreadRadius: widget.spread * p,
                  ),
                ]
              : null,
        ),
        child: child,
      );
    },
  );
}

/// Flottement lent (5 s) des illustrations de l'onboarding.
class Float extends StatefulWidget {
  const Float({super.key, required this.child});
  final Widget child;

  @override
  State<Float> createState() => _FloatState();
}

class _FloatState extends State<Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!_reduced(context)) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
      child: child,
    ),
  );
}

/// Barre qui se remplit depuis la gauche (1 s, après 0,3 s), comme `tcGrow`.
class GrowBar extends StatefulWidget {
  const GrowBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 6,
    this.trackColor = Tch.segmented,
  });
  final double fraction;
  final Color color;
  final double height;
  final Color trackColor;

  @override
  State<GrowBar> createState() => _GrowBarState();
}

class _GrowBarState extends State<GrowBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.3 / 1.3, 1, curve: Tch.riseCurve),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: widget.height,
    decoration: BoxDecoration(
      color: widget.trackColor,
      borderRadius: BorderRadius.circular(widget.height),
    ),
    clipBehavior: Clip.antiAlias,
    child: AnimatedBuilder(
      animation: _a,
      builder: (_, _) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widget.fraction * _a.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.height),
            ),
            child: SizedBox(height: widget.height),
          ),
        ),
      ),
    ),
  );
}
