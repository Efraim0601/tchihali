import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens de Tchihali (voir CLAUDE.md).
class Tch {
  Tch._();

  // Couleurs
  static const background = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const green = Color(0xFF4F7A5A);
  static const greenDark = Color(0xFF2F5238);
  static const greenDark2 = Color(0xFF3E6448);
  static const greenLight = Color(0xFFE7EFE4);
  static const greenDeco = Color(0xFF8FB394);
  static const coral = Color(0xFFE0704F);
  static const coralText = Color(0xFFA9482F);
  static const peach = Color(0xFFF6C7B4);
  static const peachLight = Color(0xFFFCE9E0);
  static const yellow = Color(0xFFFBF0C9);
  static const yellowText = Color(0xFF5E4700);
  static const text = Color(0xFF2F3437);
  static const textSecondary = Color(0xFF646B6F);
  static const border = Color(0xFFE4DED4);
  static const borderLight = Color(0xFFEFEAE2);
  static const segmented = Color(0xFFEFEAE2);
  static const danger = Color(0xFFC4533A);
  static const checkBorder = Color(0xFFC9C2B6);

  // Formes
  static const double pagePadding = 20;
  static const double authPadding = 24;
  static const double onboardingPadding = 28;
  static const double cardRadius = 24;
  static const double buttonHeight = 56;
  static const double buttonRadius = 18;
  static const double fieldRadius = 16;
  static const double chipRadius = 14;

  static const cardShadow = [
    BoxShadow(
      color: Color(0x0D2F3437), // 0.05
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Animations
  static const Curve riseCurve = Cubic(0.2, 0.8, 0.2, 1);
  static const Duration riseDuration = Duration(milliseconds: 600);
  static const Duration riseStagger = Duration(milliseconds: 80);
  static const Duration pressDuration = Duration(milliseconds: 180);
  static const Duration selectDuration = Duration(milliseconds: 250);

  /// Marge haute des écrans : 56 px comme les maquettes (barre d'état incluse).
  static double topInset(BuildContext context) =>
      math.max(56, MediaQuery.of(context).padding.top + 16);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.light,
        surface: surface,
      ).copyWith(primary: green, secondary: coral, error: danger),
    );
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: text,
      displayColor: text,
    );
    return base.copyWith(
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: borderLight,
    );
  }

  /// Style Poppins (400, 500, 600, 700 uniquement).
  static TextStyle style(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = text,
    double? height,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}
