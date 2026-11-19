// Modèles de l'espace praticien.

class ProAppointment {
  const ProAppointment({
    required this.id,
    required this.patient,
    required this.mode,
    required this.startsAt,
  });
  final String id, patient;
  final String mode; // video | office
  final DateTime startsAt;

  bool get video => mode == 'video';
}

class ProRequestItem {
  const ProRequestItem({
    required this.id,
    required this.patient,
    required this.initials,
    required this.mode,
    required this.startsAt,
  });
  final String id, patient, initials, mode;
  final DateTime startsAt;

  bool get video => mode == 'video';
}

class ProPatientSummary {
  const ProPatientSummary({
    required this.id,
    required this.name,
    required this.initials,
    this.since,
  });
  final String id, name, initials;
  final DateTime? since;
}

class ProKpi {
  const ProKpi(this.value, this.delta);
  final double value, delta;
}

class ProMeal {
  const ProMeal(this.name, this.kcal, this.at, this.late);
  final String name;
  final int kcal;
  final DateTime at;
  final bool late;
}

class ProPatientDetail {
  const ProPatientDetail({
    required this.id,
    required this.name,
    required this.initials,
    this.age,
    this.heightCm,
    this.goalWeightKg,
    this.conditions = const [],
    this.allergies = const [],
    this.since,
    this.weight,
    this.waist,
    this.glucose,
    this.weightSeries = const [],
    this.meals = const [],
    this.note = '',
    this.demo = false,
  });
  final String id, name, initials;
  final int? age, heightCm;
  final double? goalWeightKg;
  final List<int> conditions, allergies;
  final DateTime? since;
  final ProKpi? weight, waist, glucose;
  final List<double> weightSeries;
  final List<ProMeal> meals;
  final String note;

  /// Mode démo : l'écran affiche les textes d'exemple traduits.
  final bool demo;
}

class ReportMealItem {
  ReportMealItem([this.text = '', this.kcal = 0]);
  String text;
  int kcal;
}

class ReportGoalItem {
  ReportGoalItem(this.text, [this.done = true]);
  String text;
  bool done;
}

class ReportDraft {
  ReportDraft({
    required this.patientName,
    required this.sessionNo,
    required this.heldOn,
    this.summary = '',
    List<ReportGoalItem>? goals,
    List<List<ReportMealItem>>? plan,
    this.weightKg,
    this.waistCm,
    this.glucoseGl,
    this.sent = false,
    this.demo = false,
  }) : goals = goals ?? [],
       plan =
           plan ??
           [
             for (var d = 0; d < 7; d++)
               [for (var i = 0; i < 4; i++) ReportMealItem()],
           ];

  final String patientName;
  final int sessionNo;
  final DateTime heldOn;
  String summary;
  final List<ReportGoalItem> goals;
  final List<List<ReportMealItem>> plan; // 7 jours × repas
  double? weightKg, waistCm, glucoseGl;
  bool sent;

  /// Mode démo : l'écran préremplit le contenu d'exemple traduit.
  final bool demo;
}

class Conversation {
  const Conversation({
    required this.patientId,
    required this.patient,
    required this.last,
    required this.at,
    required this.fromPatient,
  });
  final String patientId, patient, last;
  final DateTime at;
  final bool fromPatient;
}

class AvailabilitySlot {
  const AvailabilitySlot(this.weekday, this.time);
  final int weekday; // 1 = lundi
  final String time; // HH:MM
}
