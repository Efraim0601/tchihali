import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';
import 'models.dart';

/// Annuaire des diététiciens et créneaux.
abstract class DietitianRepository {
  Future<List<Dietitian>> all();

  /// Créneaux d'un jour ; liste vide si week-end, jour férié ou passé.
  Future<List<Slot>> slots(String dietitianId, DateTime day);
}

/// Mode démo : données fictives.
class MockDietitianRepository implements DietitianRepository {
  static const _times = ['09:00', '10:30', '11:30', '14:00', '15:30', '17:00'];
  static const _holidays = {(1, 1), (2, 11), (5, 1), (5, 20), (8, 15), (12, 25)};

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

  /// Diététicien utilisé tant qu'aucune réservation n'a été démarrée depuis l'annuaire.
  static Dietitian get fallback => _items.first;

  @override
  Future<List<Dietitian>> all() async => _items;

  @override
  Future<List<Slot>> slots(String dietitianId, DateTime day) async {
    final today = DateTime.now();
    final d = DateTime(day.year, day.month, day.day);
    final past = d.isBefore(DateTime(today.year, today.month, today.day));
    if (past || d.weekday > DateTime.friday || _holidays.contains((d.month, d.day))) return [];
    return [for (final t in _times) Slot(t, taken: t == '15:30')];
  }
}

class ApiDietitianRepository implements DietitianRepository {
  ApiDietitianRepository(this._api);
  final ApiClient _api;

  static Color _color(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  @override
  Future<List<Dietitian>> all() async {
    final list = await _api.get('/dietitians') as List;
    return [
      for (final j in list.cast<Map<String, dynamic>>())
        Dietitian(
          id: j['id'] as String,
          initials: j['initials'] as String,
          name: j['name'] as String,
          specialties: LText(j['specialties']['fr'] as String, j['specialties']['en'] as String),
          languages: LText(j['languages']['fr'] as String, j['languages']['en'] as String),
          nextSlot: j['next_slot'] == null ? null : DateTime.parse(j['next_slot'] as String).toLocal(),
          video: j['video'] as bool,
          inPerson: j['in_person'] as bool,
          avatarBg: _color(j['avatar_bg'] as String),
          avatarFg: _color(j['avatar_fg'] as String),
        ),
    ];
  }

  @override
  Future<List<Slot>> slots(String dietitianId, DateTime day) async {
    final d = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final list = await _api.get('/dietitians/$dietitianId/slots', query: {'day': d}) as List;
    return [
      for (final j in list.cast<Map<String, dynamic>>()) Slot(j['time'] as String, taken: j['taken'] as bool),
    ];
  }
}

final dietitianRepositoryProvider = Provider<DietitianRepository>((ref) =>
    ApiConfig.isConfigured
        ? ApiDietitianRepository(ref.watch(apiClientProvider))
        : MockDietitianRepository());

final dietitiansProvider = FutureProvider.autoDispose<List<Dietitian>>(
    (ref) => ref.watch(dietitianRepositoryProvider).all());

final slotsProvider = FutureProvider.autoDispose.family<List<Slot>, ({String id, DateTime day})>(
    (ref, a) => ref.watch(dietitianRepositoryProvider).slots(a.id, a.day));
