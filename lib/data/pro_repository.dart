import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/api_providers.dart';
import 'chat_repository.dart';
import 'patient_repositories.dart' show ymd;
import 'pro_data.dart';
import 'pro_models.dart';

/// Espace praticien : agenda, demandes, patients, compte rendu, disponibilités, messages.
abstract class ProRepository {
  Future<List<ProAppointment>> agenda(DateTime weekStart);
  Future<List<ProRequestItem>> requests();
  Future<void> decide(String appointmentId, {required bool accept});
  Future<List<ProPatientSummary>> patients();
  Future<ProPatientDetail> patient(String id);
  Future<void> saveNote(String patientId, String body);
  Future<ReportDraft> report(String patientId);
  Future<void> saveReport(String patientId, ReportDraft draft);
  Future<void> sendReport(String patientId);
  Future<List<AvailabilitySlot>> availability();
  Future<void> addSlot(int weekday, String time);
  Future<void> removeSlot(int weekday, String time);
  Future<List<Conversation>> conversations();
  Future<List<ChatMessage>> messages(String patientId, {int afterId = 0});
  Future<ChatMessage> sendMessage(String patientId, String body);
}

/// Mode démo : données d'exemple de la maquette (Estelle Mbarga, semaine du 16 novembre 2026).
class MockProRepository implements ProRepository {
  final _decided = <String>{};
  final _notes = <String, String>{};
  final _chat = <ChatMessage>[];

  @override
  Future<List<ProAppointment>> agenda(DateTime weekStart) async => [
    for (var d = 0; d < weekAppts.length; d++)
      for (final a in weekAppts[d])
        ProAppointment(
          id: 'demo-$d-${a.name}',
          patient: a.name,
          mode: a.video ? 'video' : 'office',
          startsAt: DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day + d,
            a.start.floor(),
            a.start % 1 == 0 ? 0 : 30,
          ),
        ),
  ];

  @override
  Future<List<ProRequestItem>> requests() async => [
    for (final r in proRequests)
      if (!_decided.contains('${r.id}'))
        ProRequestItem(
          id: '${r.id}',
          patient: r.name,
          initials: r.initials,
          mode: r.video ? 'video' : 'office',
          startsAt: r.when,
        ),
  ];

  @override
  Future<void> decide(String appointmentId, {required bool accept}) async =>
      _decided.add(appointmentId);

  @override
  Future<List<ProPatientSummary>> patients() async => [
    ProPatientSummary(
      id: 'nadege',
      name: 'Nadège Ngono',
      initials: 'NN',
      since: DateTime(2026, 8, 24),
    ),
  ];

  @override
  Future<ProPatientDetail> patient(String id) async => ProPatientDetail(
    id: id,
    name: 'Nadège Ngono',
    initials: 'NN',
    demo: true,
    weight: const ProKpi(79.6, -4.4),
    waist: const ProKpi(92, -6),
    glucose: const ProKpi(1.08, -0.18),
    weightSeries: patientWeights,
    goalWeightKg: 75,
    note: _notes[id] ?? '',
  );

  @override
  Future<void> saveNote(String patientId, String body) async =>
      _notes[patientId] = body;

  @override
  Future<ReportDraft> report(String patientId) async => ReportDraft(
    patientName: 'Nadège Ngono',
    sessionNo: 4,
    heldOn: DateTime(2026, 11, 24),
    summary: '',
  );

  @override
  Future<void> saveReport(String patientId, ReportDraft draft) async {}

  @override
  Future<void> sendReport(String patientId) async {}

  @override
  Future<List<AvailabilitySlot>> availability() async => [
    for (var d = 1; d <= 5; d++)
      for (final t in ['09:00', '10:30', '11:30', '14:00', '15:30', '17:00'])
        AvailabilitySlot(d, t),
  ];

  @override
  Future<void> addSlot(int weekday, String time) async {}

  @override
  Future<void> removeSlot(int weekday, String time) async {}

  @override
  Future<List<Conversation>> conversations() async => [];

  @override
  Future<List<ChatMessage>> messages(
    String patientId, {
    int afterId = 0,
  }) async => _chat.where((m) => m.id > afterId).toList();

  @override
  Future<ChatMessage> sendMessage(String patientId, String body) async {
    final m = ChatMessage(id: 1000 + _chat.length, fromMe: true, text: body);
    _chat.add(m);
    return m;
  }
}

class ApiProRepository implements ProRepository {
  ApiProRepository(this._api);
  final ApiClient _api;

  static DateTime _t(String s) => DateTime.parse(s).toLocal();

  @override
  Future<List<ProAppointment>> agenda(DateTime weekStart) async {
    final j = await _api.get(
      '/pro/agenda',
      query: {'week_start': ymd(weekStart)},
    ) as Map<String, dynamic>;
    return [
      for (final a in (j['appointments'] as List).cast<Map<String, dynamic>>())
        ProAppointment(
          id: a['id'] as String,
          patient: a['patient'] as String,
          mode: a['mode'] as String,
          startsAt: _t(a['starts_at'] as String),
        ),
    ];
  }

  @override
  Future<List<ProRequestItem>> requests() async {
    final list = await _api.get('/pro/requests') as List;
    return [
      for (final r in list.cast<Map<String, dynamic>>())
        ProRequestItem(
          id: r['id'] as String,
          patient: r['patient'] as String,
          initials: r['initials'] as String,
          mode: r['mode'] as String,
          startsAt: _t(r['starts_at'] as String),
        ),
    ];
  }

  @override
  Future<void> decide(String appointmentId, {required bool accept}) async {
    await _api.post(
      '/pro/appointments/$appointmentId/decision',
      body: {'accept': accept},
    );
  }

  @override
  Future<List<ProPatientSummary>> patients() async {
    final list = await _api.get('/pro/patients') as List;
    return [
      for (final p in list.cast<Map<String, dynamic>>())
        ProPatientSummary(
          id: p['id'] as String,
          name: p['name'] as String,
          initials: p['initials'] as String,
          since: p['since'] == null
              ? null
              : DateTime.parse(p['since'] as String),
        ),
    ];
  }

  ProKpi? _kpi(Map<String, dynamic>? k) => k == null
      ? null
      : ProKpi((k['value'] as num).toDouble(), (k['delta'] as num).toDouble());

  @override
  Future<ProPatientDetail> patient(String id) async {
    final j = await _api.get('/pro/patients/$id') as Map<String, dynamic>;
    final k = j['kpis'] as Map<String, dynamic>;
    return ProPatientDetail(
      id: j['id'] as String,
      name: j['name'] as String,
      initials: j['initials'] as String,
      age: j['age'] as int?,
      heightCm: j['height_cm'] as int?,
      goalWeightKg: (j['goal_weight_kg'] as num?)?.toDouble(),
      conditions: (j['conditions'] as List).cast<int>(),
      allergies: (j['allergies'] as List).cast<int>(),
      since: j['since'] == null ? null : DateTime.parse(j['since'] as String),
      weight: _kpi(k['weight'] as Map<String, dynamic>?),
      waist: _kpi(k['waist'] as Map<String, dynamic>?),
      glucose: _kpi(k['glucose'] as Map<String, dynamic>?),
      weightSeries: [
        for (final p
            in (j['weight_series'] as List).cast<Map<String, dynamic>>())
          (p['value'] as num).toDouble(),
      ],
      meals: [
        for (final m in (j['meals'] as List).cast<Map<String, dynamic>>())
          ProMeal(
            m['name'] as String,
            m['kcal'] as int,
            _t(m['eaten_at'] as String),
            m['late'] as bool,
          ),
      ],
      note: j['note'] as String,
    );
  }

  @override
  Future<void> saveNote(String patientId, String body) async {
    await _api.put('/pro/patients/$patientId/note', body: {'body': body});
  }

  @override
  Future<ReportDraft> report(String patientId) async {
    final j = await _api.get('/pro/reports/$patientId') as Map<String, dynamic>;
    final m = (j['measures'] as Map?)?.cast<String, dynamic>() ?? {};
    final plan = (j['plan'] as List).cast<Map<String, dynamic>>();
    return ReportDraft(
      patientName: j['patient_name'] as String,
      sessionNo: j['session_no'] as int,
      heldOn: DateTime.parse(j['held_on'] as String),
      summary: j['summary'] as String,
      goals: [
        for (final g in (j['goals'] as List).cast<Map<String, dynamic>>())
          ReportGoalItem(g['text'] as String, (g['done'] as bool?) ?? true),
      ],
      plan: [
        for (var d = 0; d < 7; d++)
          [
            for (final x
                in ((d < plan.length ? plan[d]['meals'] : const []) as List)
                    .cast<Map<String, dynamic>>())
              ReportMealItem(
                (x['text'] as String?) ?? '',
                (x['kcal'] as int?) ?? 0,
              ),
          ],
      ],
      weightKg: (m['weight_kg'] as num?)?.toDouble(),
      waistCm: (m['waist_cm'] as num?)?.toDouble(),
      glucoseGl: (m['glucose_gl'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> saveReport(String patientId, ReportDraft d) async {
    await _api.put(
      '/pro/reports/$patientId',
      body: {
        'summary': d.summary,
        'goals': [
          for (final g in d.goals) {'text': g.text, 'done': g.done},
        ],
        'plan': [
          for (final day in d.plan)
            {
              'meals': [
                for (final m in day) {'text': m.text, 'kcal': m.kcal},
              ],
            },
        ],
        'measures': {
          'weight_kg': ?d.weightKg,
          'waist_cm': ?d.waistCm,
          'glucose_gl': ?d.glucoseGl,
        },
      },
    );
  }

  @override
  Future<void> sendReport(String patientId) async {
    await _api.post('/pro/reports/$patientId/send');
  }

  @override
  Future<List<AvailabilitySlot>> availability() async {
    final list = await _api.get('/pro/availability') as List;
    return [
      for (final s in list.cast<Map<String, dynamic>>())
        AvailabilitySlot(s['weekday'] as int, s['start_time'] as String),
    ];
  }

  @override
  Future<void> addSlot(int weekday, String time) async {
    await _api.post(
      '/pro/availability',
      body: {'weekday': weekday, 'start_time': time},
    );
  }

  @override
  Future<void> removeSlot(int weekday, String time) async {
    await _api.delete(
      '/pro/availability',
      query: {'weekday': '$weekday', 'start_time': time},
    );
  }

  @override
  Future<List<Conversation>> conversations() async {
    final list = await _api.get('/pro/conversations') as List;
    return [
      for (final c in list.cast<Map<String, dynamic>>())
        Conversation(
          patientId: c['patient_id'] as String,
          patient: c['patient'] as String,
          last: c['last'] as String,
          at: _t(c['at'] as String),
          fromPatient: c['from_patient'] as bool,
        ),
    ];
  }

  ChatMessage _msg(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] as int,
    fromMe: j['from_me'] as bool,
    text: j['body'] as String,
    photoFileId: j['photo_file_id'] as String?,
    time:
        '${_t(j['created_at'] as String).hour.toString().padLeft(2, '0')}:${_t(j['created_at'] as String).minute.toString().padLeft(2, '0')}',
  );

  @override
  Future<List<ChatMessage>> messages(
    String patientId, {
    int afterId = 0,
  }) async {
    final list = await _api.get(
      '/pro/messages',
      query: {'patient_id': patientId, 'after_id': '$afterId'},
    ) as List;
    return [for (final m in list.cast<Map<String, dynamic>>()) _msg(m)];
  }

  @override
  Future<ChatMessage> sendMessage(String patientId, String body) async => _msg(
    await _api.post(
      '/pro/messages',
      body: {'patient_id': patientId, 'body': body},
    ) as Map<String, dynamic>,
  );
}

final proRepositoryProvider = Provider<ProRepository>(
  (ref) => ApiConfig.isConfigured
      ? ApiProRepository(ref.watch(apiClientProvider))
      : MockProRepository(),
);

/// Lundi de la semaine affichée : cette semaine (API) ou la semaine de la maquette (démo).
DateTime currentWeekStart() {
  if (!ApiConfig.isConfigured) return weekStart;
  final n = DateTime.now();
  final d = DateTime(n.year, n.month, n.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

final proAgendaProvider = FutureProvider.autoDispose<List<ProAppointment>>(
  (ref) => ref.watch(proRepositoryProvider).agenda(currentWeekStart()),
);

final proRequestsProvider = FutureProvider.autoDispose<List<ProRequestItem>>(
  (ref) => ref.watch(proRepositoryProvider).requests(),
);

final proPatientsProvider = FutureProvider.autoDispose<List<ProPatientSummary>>(
  (ref) => ref.watch(proRepositoryProvider).patients(),
);

final proPatientProvider = FutureProvider.autoDispose
    .family<ProPatientDetail, String>(
      (ref, id) => ref.watch(proRepositoryProvider).patient(id),
    );

final proConversationsProvider = FutureProvider.autoDispose<List<Conversation>>(
  (ref) => ref.watch(proRepositoryProvider).conversations(),
);

final proReportProvider = FutureProvider.autoDispose
    .family<ReportDraft, String>(
      (ref, patientId) => ref.watch(proRepositoryProvider).report(patientId),
    );
