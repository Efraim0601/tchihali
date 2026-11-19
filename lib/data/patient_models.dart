// Modèles des données du patient (journal, progrès, carnet, notifications).

enum MealType { breakfast, lunch, snack, dinner }

class Meal {
  const Meal({
    required this.id,
    required this.eatenAt,
    required this.type,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.photoFileId,
    this.mood,
    this.symptoms = const {},
  });
  final String id;
  final DateTime eatenAt;
  final MealType type;
  final String name;
  final int kcal, protein, carbs, fat;
  final String? photoFileId;
  final int? mood;
  final Set<int> symptoms;

  Meal copyWith({int? mood, Set<int>? symptoms}) => Meal(
    id: id,
    eatenAt: eatenAt,
    type: type,
    name: name,
    kcal: kcal,
    protein: protein,
    carbs: carbs,
    fat: fat,
    photoFileId: photoFileId,
    mood: mood ?? this.mood,
    symptoms: symptoms ?? this.symptoms,
  );
}

class NewMeal {
  const NewMeal({
    required this.type,
    required this.name,
    required this.kcal,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.photoFileId,
  });
  final MealType type;
  final String name;
  final int kcal, protein, carbs, fat;
  final String? photoFileId;
}

class DayJournal {
  const DayJournal({
    required this.meals,
    required this.totalKcal,
    required this.targetKcal,
  });
  final List<Meal> meals;
  final int totalKcal;
  final int targetKcal;
}

class SeriesPoint {
  const SeriesPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

class ProgressData {
  const ProgressData({
    required this.weight,
    required this.bmi,
    required this.waist,
    this.goalWeightKg,
    this.heightCm,
    required this.firstSession,
    required this.streak14,
    required this.lost4kg,
  });
  final List<SeriesPoint> weight, bmi, waist;
  final double? goalWeightKg;
  final int? heightCm;
  final bool firstSession, streak14, lost4kg;

  double? get goalBmi => goalWeightKg == null || heightCm == null
      ? null
      : goalWeightKg! / ((heightCm! / 100) * (heightCm! / 100));
}

class RecordGoal {
  const RecordGoal(this.text, this.done);
  final String text;
  final bool done;
}

class RecordSession {
  const RecordSession({
    required this.number,
    required this.heldOn,
    required this.mode,
    required this.summary,
    required this.goals,
  });
  final int number;
  final DateTime heldOn;
  final String mode; // video | office
  final String summary;
  final List<RecordGoal> goals;
}

class PlanMeal {
  const PlanMeal(this.text, this.kcal);
  final String text;
  final int kcal;
}

class RecordDocument {
  const RecordDocument({
    required this.id,
    required this.name,
    required this.meta,
    required this.downloadable,
  });
  final String id, name, meta;
  final bool downloadable;
}

class RecordData {
  const RecordData({
    this.session,
    this.plan,
    this.documents = const [],
    this.isDemo = false,
  });
  final RecordSession? session;
  final List<PlanMeal>? plan;
  final List<RecordDocument> documents;

  /// Mode démo : l'écran affiche les textes d'exemple traduits.
  final bool isDemo;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.data,
    required this.createdAt,
    required this.read,
  });
  final int id;
  final String kind;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool read;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.dietitianId,
    required this.startsAt,
    required this.mode,
    required this.status,
  });
  final String id, dietitianId;
  final DateTime startsAt;
  final String mode; // video | office
  final String status; // pending | confirmed | refused | cancelled
}
