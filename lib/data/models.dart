import 'package:material_ui/material_ui.dart';

enum ConsultMode { video, office }

extension ConsultModePrice on ConsultMode {
  /// Tarifs : vidéo 12 000 FCFA, cabinet 15 000 FCFA.
  int get price => this == ConsultMode.video ? 12000 : 15000;
}

/// Texte disponible en français et en anglais (données de test).
class LText {
  const LText(this.fr, this.en);
  final String fr;
  final String en;
  String of(String locale) => locale.startsWith('fr') ? fr : en;
}

class Dietitian {
  const Dietitian({
    required this.id,
    required this.initials,
    required this.name,
    required this.specialties,
    required this.languages,
    required this.nextSlot,
    required this.video,
    required this.inPerson,
    required this.avatarBg,
    required this.avatarFg,
  });
  final String id;
  final String initials;
  final String name;
  final LText specialties; // « Ville · spécialités »
  final LText languages;
  final DateTime nextSlot;
  final bool video;
  final bool inPerson;
  final Color avatarBg;
  final Color avatarFg;

  bool supports(ConsultMode m) => m == ConsultMode.video ? video : inPerson;
}
