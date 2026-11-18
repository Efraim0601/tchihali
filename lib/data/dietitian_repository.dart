import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'models.dart';

/// Annuaire des diététiciens. Le backend viendra plus tard derrière cette interface.
abstract class DietitianRepository {
  List<Dietitian> all();
  Dietitian byId(String id);
}

class MockDietitianRepository implements DietitianRepository {
  static final _items = [
    Dietitian(
      id: 'estelle',
      initials: 'EM',
      name: 'Estelle Mbarga',
      specialties: const LText('Yaoundé · Diabète, perte de poids', 'Yaoundé · Diabetes, weight loss'),
      languages: const LText('Français · Anglais · Ewondo', 'French · English · Ewondo'),
      nextSlot: DateTime(2026, 11, 24, 10, 30),
      video: true,
      inPerson: true,
      avatarBg: const Color(0xFFF6C7B4),
      avatarFg: const Color(0xFF7A3522),
    ),
    Dietitian(
      id: 'serge',
      initials: 'SF',
      name: 'Serge Fotso',
      specialties: const LText('Douala · Diabète, sport', 'Douala · Diabetes, sports'),
      languages: const LText('Anglais · Français · Pidgin', 'English · French · Pidgin'),
      nextSlot: DateTime(2026, 11, 19, 17, 0),
      video: true,
      inPerson: false,
      avatarBg: const Color(0xFFCFE0CB),
      avatarFg: const Color(0xFF2F5238),
    ),
    Dietitian(
      id: 'aissatou',
      initials: 'AB',
      name: 'Aïssatou Bello',
      specialties: const LText('Yaoundé · Grossesse, enfants', 'Yaoundé · Pregnancy, children'),
      languages: const LText('Français · Fulfulde', 'French · Fulfulde'),
      nextSlot: DateTime(2026, 11, 20, 9, 0),
      video: false,
      inPerson: true,
      avatarBg: const Color(0xFFFCE9E0),
      avatarFg: const Color(0xFF7A3522),
    ),
  ];

  @override
  List<Dietitian> all() => _items;

  @override
  Dietitian byId(String id) => _items.firstWhere((d) => d.id == id);
}

final dietitianRepositoryProvider =
    Provider<DietitianRepository>((_) => MockDietitianRepository());
