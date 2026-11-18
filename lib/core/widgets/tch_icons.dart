import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icônes des maquettes : viewBox 24, traits arrondis, épaisseur 2.
class TchIcons {
  TchIcons._();

  static const home = '<path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>';
  static const agenda = '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M8 3v4M16 3v4M3 10h18"/>';
  static const journal = '<path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3z"/><path d="M9 9h6M9 13h6"/>';
  static const messages = '<path d="M4 5h16v11H9l-5 4z"/>';
  static const profile = '<circle cx="12" cy="8" r="4"/><path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6"/>';
  static const plus = '<path d="M12 5v14M5 12h14"/>';
  static const check = '<path d="M5 12l5 5 9-10"/>';
  static const edit = '<path d="M4 20h4L19 9l-4-4L4 16z"/>';
  static const chevronRight = '<path d="M9 5l7 7-7 7"/>';
  static const chevronLeft = '<path d="M15 5l-7 7 7 7"/>';
  static const globe = '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>';
  static const logout = '<path d="M15 4h4v16h-4M10 8l-4 4 4 4M6 12h10"/>';
  static const book = '<path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3z"/>';
  static const search = '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>';
  static const filters = '<path d="M4 7h10M18 7h2M4 17h4M12 17h8"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="17" r="2"/>';
  static const video = '<rect x="3" y="7" width="13" height="10" rx="3"/><path d="M16 11l5-3v8l-5-3"/>';
  static const office = '<path d="M3 11l9-7 9 7v9H3z"/><path d="M10 20v-5h4v5"/>';
  static const lock = '<rect x="5" y="11" width="14" height="10" rx="3"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>';
  static const camera = '<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>';
  static const send = '<path d="M4 12l16-8-6 16-3-7z"/>';
  static const download = '<path d="M12 4v11M7 10l5 5 5-5M5 20h14"/>';
  static const leaf = '<path d="M5 19c0-8 5-13 14-14-1 9-6 14-14 14z"/><path d="M5 19l7-7"/>';
  static const flame = '<path d="M12 3c2 4 6 5 6 10a6 6 0 0 1-12 0c0-3 2-4 2-6 2 1 3 2 4-4z"/>';
  static const award = '<circle cx="12" cy="9" r="6"/><path d="M8.5 14L7 21l5-3 5 3-1.5-7"/>';
  static const heart = '<path d="M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.5-7 10-7 10z"/>';
  static const mic = '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/>';
  static const phoneDown = '<path d="M3 14c5-5 13-5 18 0l-2 3-4-1v-3c-2-.6-4-.6-6 0v3l-4 1z"/>';
  static const close = '<path d="M6 6l12 12M18 6L6 18"/>';
  static const patients = '<circle cx="9" cy="8" r="4"/><path d="M2 21c1-4 4-6 7-6s6 2 7 6M16 4a4 4 0 0 1 0 8M22 21c-.5-3-2-5-4-5.5"/>';
  static const report = '<path d="M6 3h9l4 4v14H6z"/><path d="M9 12h7M9 16h5"/>';
  static const back = '<path d="M15 5l-7 7 7 7"/>';
}

/// Affiche un contenu SVG (éléments internes) dans un viewBox 24.
class TchIcon extends StatelessWidget {
  const TchIcon(
    this.inner, {
    super.key,
    this.size = 24,
    this.color = Colors.black,
    this.strokeWidth = 2,
    this.viewBox = 24,
    this.fill = false,
  });
  final String inner;
  final double size;
  final Color color;
  final double strokeWidth;
  final double viewBox;

  /// Remplit les formes avec la couleur (cœur favori).
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final hex = colorHex(color);
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $viewBox $viewBox" fill="${fill ? hex : 'none'}" '
      'stroke="$hex" stroke-width="$strokeWidth" stroke-linecap="round" '
      'stroke-linejoin="round">$inner</svg>',
      width: size,
      height: size,
    );
  }
}

/// Couleur au format `#rrggbb` pour les SVG.
String colorHex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
