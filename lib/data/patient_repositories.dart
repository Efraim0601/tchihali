import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';
import 'patient_models.dart';
import 'progress_data.dart';

String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// ======================= Journal alimentaire et objectifs =======================
abstract class JournalRepository {
  Future<DayJournal> day(DateTime day);
  Future<void> addMeal(NewMeal meal, {DateTime? eatenAt});
  Future<void> setFeeling(
    String mealId, {
    int? mood,
    required Set<int> symptoms,
  });
  Future<void> deleteMeal(String mealId);
  Future<Set<int>> goals(DateTime day);
  Future<void> setGoals(DateTime day, Set<int> done);
  Future<String> uploadPhoto(
    Uint8List bytes, {
    required String kind,
    required String filename,
  });
  Future<Uint8List> photoBytes(String fileId);
}

/// Mode démo : un repas d'exemple, données gardées en mémoire.
class MockJournalRepository implements JournalRepository {
  final _meals = <Meal>[
    Meal(
      id: 'demo-1',
      eatenAt: _today(13, 5),
      type: MealType.lunch,
      name: 'Poisson braisé, miondo',
      kcal: 540,
      protein: 32,
      carbs: 68,
      fat: 14,
      mood: 3,
      symptoms: {0},
    ),
  ];
  Set<int> _goals = {1};

  static DateTime _today(int h, int m) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, h, m);
  }

  @override
  Future<DayJournal> day(DateTime day) async {
    final list =
        _meals.where((m) => dateOnly(m.eatenAt) == dateOnly(day)).toList()
          ..sort((a, b) => a.eatenAt.compareTo(b.eatenAt));
    return DayJournal(
      meals: list,
      totalKcal: list.fold(0, (a, m) => a + m.kcal),
      targetKcal: 1700,
    );
  }

  @override
  Future<void> addMeal(NewMeal m, {DateTime? eatenAt}) async => _meals.add(
    Meal(
      id: 'demo-${_meals.length + 1}',
      eatenAt: eatenAt ?? DateTime.now(),
      type: m.type,
      name: m.name,
      kcal: m.kcal,
      protein: m.protein,
      carbs: m.carbs,
      fat: m.fat,
      photoFileId: m.photoFileId,
    ),
  );

  @override
  Future<void> setFeeling(
    String mealId, {
    int? mood,
    required Set<int> symptoms,
  }) async {
    final i = _meals.indexWhere((m) => m.id == mealId);
    if (i >= 0) _meals[i] = _meals[i].copyWith(mood: mood, symptoms: symptoms);
  }

  @override
  Future<void> deleteMeal(String mealId) async =>
      _meals.removeWhere((m) => m.id == mealId);

  @override
  Future<Set<int>> goals(DateTime day) async => _goals;

  @override
  Future<void> setGoals(DateTime day, Set<int> done) async => _goals = done;

  @override
  Future<String> uploadPhoto(
    Uint8List bytes, {
    required String kind,
    required String filename,
  }) async => 'demo';

  @override
  Future<Uint8List> photoBytes(String fileId) async => Uint8List(0);
}

class ApiJournalRepository implements JournalRepository {
  ApiJournalRepository(this._api);
  final ApiClient _api;

  static const _types = {
    'breakfast': MealType.breakfast,
    'lunch': MealType.lunch,
    'snack': MealType.snack,
    'dinner': MealType.dinner,
  };

  Meal _meal(Map<String, dynamic> j) => Meal(
    id: j['id'] as String,
    eatenAt: DateTime.parse(j['eaten_at'] as String).toLocal(),
    type: _types[j['meal_type']] ?? MealType.lunch,
    name: j['name'] as String,
    kcal: j['kcal'] as int,
    protein: j['protein'] as int,
    carbs: j['carbs'] as int,
    fat: j['fat'] as int,
    photoFileId: j['photo_file_id'] as String?,
    mood: j['mood'] as int?,
    symptoms: (j['symptoms'] as List).cast<int>().toSet(),
  );

  @override
  Future<DayJournal> day(DateTime day) async {
    final j = await _api.get(
      '/meals',
      query: {'day': ymd(day)},
    ) as Map<String, dynamic>;
    return DayJournal(
      meals: [
        for (final m in (j['meals'] as List).cast<Map<String, dynamic>>())
          _meal(m),
      ],
      totalKcal: j['total_kcal'] as int,
      targetKcal: j['target_kcal'] as int,
    );
  }

  @override
  Future<void> addMeal(NewMeal m, {DateTime? eatenAt}) async {
    await _api.post(
      '/meals',
      body: {
        if (eatenAt != null) 'eaten_at': eatenAt.toUtc().toIso8601String(),
        'meal_type': m.type.name,
        'name': m.name,
        'kcal': m.kcal,
        'protein': m.protein,
        'carbs': m.carbs,
        'fat': m.fat,
        if (m.photoFileId != null) 'photo_file_id': m.photoFileId,
      },
    );
  }

  @override
  Future<void> setFeeling(
    String mealId, {
    int? mood,
    required Set<int> symptoms,
  }) async {
    await _api.patch(
      '/meals/$mealId',
      body: {'mood': mood, 'symptoms': symptoms.toList()..sort()},
    );
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    await _api.delete('/meals/$mealId');
  }

  @override
  Future<Set<int>> goals(DateTime day) async {
    final j = await _api.get(
      '/goals',
      query: {'day': ymd(day)},
    ) as Map<String, dynamic>;
    return (j['done'] as List).cast<int>().toSet();
  }

  @override
  Future<void> setGoals(DateTime day, Set<int> done) async {
    await _api.put(
      '/goals',
      body: {'day': ymd(day), 'done': done.toList()..sort()},
    );
  }

  @override
  Future<String> uploadPhoto(
    Uint8List bytes, {
    required String kind,
    required String filename,
  }) => _api.uploadImage(bytes, kind: kind, filename: filename);

  @override
  Future<Uint8List> photoBytes(String fileId) =>
      _api.getBytes('/files/$fileId');
}

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiJournalRepository(ref.watch(apiClientProvider))
      : MockJournalRepository(),
);

final journalDayProvider = FutureProvider.autoDispose
    .family<DayJournal, DateTime>(
      (ref, day) => ref.watch(journalRepositoryProvider).day(day),
    );

final goalsProvider = FutureProvider.autoDispose.family<Set<int>, DateTime>(
  (ref, day) => ref.watch(journalRepositoryProvider).goals(day),
);

/// Photo protégée (repas, message) : téléchargée avec le jeton, gardée en mémoire.
final photoProvider = FutureProvider.family<Uint8List, String>(
  (ref, id) => ref.watch(journalRepositoryProvider).photoBytes(id),
);

// ======================= Progrès =======================
abstract class ProgressRepository {
  Future<ProgressData> load();
  Future<void> addMeasurement({double? weightKg, double? waistCm});
}

class MockProgressRepository implements ProgressRepository {
  @override
  Future<ProgressData> load() async {
    final start = DateTime(2026, 8, 24);
    final weight = [
      for (var i = 0; i < progressSeries[0].data.length; i++)
        SeriesPoint(
          start.add(Duration(days: i * 7)),
          progressSeries[0].data[i],
        ),
    ];
    final waist = [
      for (var i = 0; i < progressSeries[2].data.length; i++)
        SeriesPoint(
          start.add(Duration(days: i * 7)),
          progressSeries[2].data[i],
        ),
    ];
    return ProgressData(
      weight: weight,
      bmi: [
        for (final p in weight) SeriesPoint(p.date, p.value / (1.65 * 1.65)),
      ],
      waist: waist,
      goalWeightKg: 75,
      heightCm: 165,
      firstSession: true,
      streak14: true,
      lost4kg: true,
    );
  }

  @override
  Future<void> addMeasurement({double? weightKg, double? waistCm}) async {}
}

class ApiProgressRepository implements ProgressRepository {
  ApiProgressRepository(this._api);
  final ApiClient _api;

  List<SeriesPoint> _series(List l) => [
    for (final j in l.cast<Map<String, dynamic>>())
      SeriesPoint(
        DateTime.parse(j['date'] as String),
        (j['value'] as num).toDouble(),
      ),
  ];

  @override
  Future<ProgressData> load() async {
    final j = await _api.get('/progress') as Map<String, dynamic>;
    final b = j['badges'] as Map<String, dynamic>;
    return ProgressData(
      weight: _series(j['weight'] as List),
      bmi: _series(j['bmi'] as List),
      waist: _series(j['waist'] as List),
      goalWeightKg: (j['goal_weight_kg'] as num?)?.toDouble(),
      heightCm: j['height_cm'] as int?,
      firstSession: b['first_session'] as bool,
      streak14: b['journal_streak_14'] as bool,
      lost4kg: b['lost_4kg'] as bool,
    );
  }

  @override
  Future<void> addMeasurement({double? weightKg, double? waistCm}) async {
    await _api.post(
      '/measurements',
      body: {
        'measured_on': ymd(DateTime.now()),
        'weight_kg': ?weightKg,
        'waist_cm': ?waistCm,
      },
    );
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiProgressRepository(ref.watch(apiClientProvider))
      : MockProgressRepository(),
);

final progressProvider = FutureProvider.autoDispose<ProgressData>(
  (ref) => ref.watch(progressRepositoryProvider).load(),
);

// ======================= Carnet de suivi =======================
abstract class RecordRepository {
  Future<RecordData> load();
  Future<Uint8List> documentBytes(String id);
}

class MockRecordRepository implements RecordRepository {
  @override
  Future<RecordData> load() async => const RecordData(isDemo: true);

  @override
  Future<Uint8List> documentBytes(String id) async => Uint8List(0);
}

class ApiRecordRepository implements RecordRepository {
  ApiRecordRepository(this._api);
  final ApiClient _api;

  @override
  Future<RecordData> load() async {
    final j = await _api.get('/record') as Map<String, dynamic>;
    final s = j['session'] as Map<String, dynamic>?;
    final plan = j['plan'] as List?;
    return RecordData(
      session: s == null
          ? null
          : RecordSession(
              number: s['session_no'] as int,
              heldOn: DateTime.parse(s['held_on'] as String),
              mode: s['mode'] as String,
              summary: s['summary'] as String,
              goals: [
                for (final g
                    in (s['goals'] as List).cast<Map<String, dynamic>>())
                  RecordGoal(g['text'] as String, (g['done'] as bool?) ?? true),
              ],
            ),
      plan: plan == null
          ? null
          : [
              for (final m in plan.cast<Map<String, dynamic>>())
                PlanMeal(
                  (m['text'] as String?) ?? '',
                  (m['kcal'] as int?) ?? 0,
                ),
            ],
      documents: [
        for (final d in (j['documents'] as List).cast<Map<String, dynamic>>())
          RecordDocument(
            id: d['id'] as String,
            name: d['name'] as String,
            meta: d['meta'] as String,
            downloadable: d['downloadable'] as bool,
          ),
      ],
    );
  }

  @override
  Future<Uint8List> documentBytes(String id) =>
      _api.getBytes('/documents/$id/download');
}

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiRecordRepository(ref.watch(apiClientProvider))
      : MockRecordRepository(),
);

final recordProvider = FutureProvider.autoDispose<RecordData>(
  (ref) => ref.watch(recordRepositoryProvider).load(),
);

// ======================= Notifications =======================
abstract class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<void> readAll();
}

class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> list() async => [];

  @override
  Future<void> readAll() async {}
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<AppNotification>> list() async {
    final j = await _api.get('/notifications') as Map<String, dynamic>;
    return [
      for (final n in (j['items'] as List).cast<Map<String, dynamic>>())
        AppNotification(
          id: n['id'] as int,
          kind: n['kind'] as String,
          data: (n['data'] as Map?)?.cast<String, dynamic>() ?? {},
          createdAt: DateTime.parse(n['created_at'] as String).toLocal(),
          read: n['read'] as bool,
        ),
    ];
  }

  @override
  Future<void> readAll() async {
    await _api.post('/notifications/read-all');
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiNotificationsRepository(ref.watch(apiClientProvider))
      : MockNotificationsRepository(),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(notificationsRepositoryProvider).list(),
);

/// Nombre de notifications non lues (pastille sur « Profil »). 0 en cas d'erreur.
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  try {
    final list = await ref.watch(notificationsProvider.future);
    return list.where((n) => !n.read).length;
  } on ApiException {
    return 0;
  }
});

// ======================= Rendez-vous du patient =======================
abstract class AppointmentsRepository {
  Future<List<Appointment>> mine();
}

class MockAppointmentsRepository implements AppointmentsRepository {
  @override
  Future<List<Appointment>> mine() async => [
    Appointment(
      id: 'demo',
      dietitianId: 'estelle',
      startsAt: DateTime(2026, 11, 24, 10, 30),
      mode: 'video',
      status: 'confirmed',
    ),
  ];
}

class ApiAppointmentsRepository implements AppointmentsRepository {
  ApiAppointmentsRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Appointment>> mine() async {
    final list = await _api.get('/appointments/mine') as List;
    return [
      for (final j in list.cast<Map<String, dynamic>>())
        Appointment(
          id: j['id'] as String,
          dietitianId: j['dietitian_id'] as String,
          startsAt: DateTime.parse(j['starts_at'] as String).toLocal(),
          mode: j['mode'] as String,
          status: j['status'] as String,
        ),
    ];
  }
}

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiAppointmentsRepository(ref.watch(apiClientProvider))
      : MockAppointmentsRepository(),
);

/// Prochain rendez-vous à venir (en attente ou confirmé), ou null.
final nextAppointmentProvider = FutureProvider.autoDispose<Appointment?>((
  ref,
) async {
  final all = await ref.watch(appointmentsRepositoryProvider).mine();
  final now = DateTime.now();
  final upcoming =
      all
          .where(
            (a) =>
                (a.status == 'confirmed' || a.status == 'pending') &&
                a.startsAt.isAfter(now),
          )
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return upcoming.isEmpty ? null : upcoming.first;
});

// ======================= Profil =======================
abstract class ProfileRepository {
  Future<void> updateName(String name);

  /// Toutes les données du compte (JSON) : droit d'accès et de portabilité.
  Future<Uint8List> exportData();

  /// Suppression définitive du compte et de ses données.
  Future<void> deleteAccount();
}

class MockProfileRepository implements ProfileRepository {
  @override
  Future<void> updateName(String name) async {}

  @override
  Future<Uint8List> exportData() async =>
      Uint8List.fromList('{"demo": true}'.codeUnits);

  @override
  Future<void> deleteAccount() async {}
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> updateName(String name) async {
    await _api.patch('/me', body: {'full_name': name});
  }

  @override
  Future<Uint8List> exportData() => _api.getBytes('/me/export');

  @override
  Future<void> deleteAccount() async {
    await _api.delete('/me', query: {'confirm': 'yes'});
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiProfileRepository(ref.watch(apiClientProvider))
      : MockProfileRepository(),
);
