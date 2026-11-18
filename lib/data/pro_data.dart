import 'package:material_ui/material_ui.dart';
import 'models.dart';

/// Données de test de l'espace praticien (Estelle Mbarga, semaine du 16 novembre 2026).
final weekStart = DateTime(2026, 11, 16);

class ProAppt {
  const ProAppt(this.name, this.start, this.video);
  final String name;
  final double start; // heure décimale : 10.5 = 10:30
  final bool video;
}

const weekAppts = <List<ProAppt>>[
  [
    ProAppt('Nadège Ngono', 9, true),
    ProAppt('Martin Essomba', 10.5, false),
    ProAppt('Linda Kamga', 14, false),
    ProAppt('Hervé Tchoumi', 16, true),
  ],
  [ProAppt('Aïcha Mohamadou', 8.5, false), ProAppt('Brenda Ewane', 11, true)],
  [ProAppt('Didier Nkoulou', 9, false), ProAppt('Clarisse Abena', 13.5, true)],
  [
    ProAppt('Joëlle Manga', 10, false),
    ProAppt('Nadège Ngono', 14.5, false),
    ProAppt('Habib Oumarou', 16.5, true),
  ],
  [ProAppt('Sandrine Owona', 9.5, true), ProAppt('Moussa Hamadou', 11.5, false)],
];

class ProRequest {
  const ProRequest(this.id, this.initials, this.name, this.when, this.video, this.bg, this.fg);
  final int id;
  final String initials;
  final String name;
  final DateTime when;
  final bool video;
  final Color bg;
  final Color fg;
}

final proRequests = [
  ProRequest(1, 'PA', 'Paul Atangana', DateTime(2026, 11, 18, 15, 0), true,
      const Color(0xFFCFE0CB), const Color(0xFF24412D)),
  ProRequest(2, 'GE', 'Grâce Ekotto', DateTime(2026, 11, 19, 9, 0), false,
      const Color(0xFFFCE9E0), const Color(0xFF7A3522)),
  ProRequest(3, 'IN', 'Ibrahim Njoya', DateTime(2026, 11, 20, 11, 30), true,
      const Color(0xFFFBF0C9), const Color(0xFF5E4700)),
];

// ---- Fiche patient : Nadège Ngono ----
const patientInfo = LText(
    '38 ans · 1,65 m · Suivie depuis le 24 août', '38 years · 1.65 m · Followed since Aug 24');
const patientTag1 = LText('Prédiabète', 'Prediabetes');
const patientTag2 = LText('Intolérance au lactose', 'Lactose intolerance');
const patientNote = LText(
    'Stress en fin de mois, grignotage le soir. Proposer une collation à 17 h.',
    'Stress at month end, evening snacking. Suggest a snack at 5 pm.');

class Kpi {
  const Kpi(this.value, this.delta);
  final LText value;
  final LText delta;
}

const patientKpis = [
  Kpi(LText('79,6 kg', '79.6 kg'), LText('−4,4 kg', '−4.4 kg')),
  Kpi(LText('92 cm', '92 cm'), LText('−6 cm', '−6 cm')),
  Kpi(LText('1,08 g/L', '1.08 g/L'), LText('−0,18 g/L', '−0.18 g/L')),
];

const patientWeights = [84.0, 83.4, 83.1, 82.5, 82.2, 81.6, 81.4, 80.9, 80.5, 80.2, 79.9, 79.6];

class PatientMeal {
  const PatientMeal(this.text, this.when, this.kcal, {this.late = false});
  final LText text;
  final LText when;
  final int kcal;
  final bool late;
}

const patientMeals = [
  PatientMeal(LText('Poisson braisé, miondo', 'Grilled fish, miondo'),
      LText('Aujourd\'hui · 13:05', 'Today · 13:05'), 540),
  PatientMeal(LText('Bouillie de mil, papaye', 'Millet porridge, papaya'),
      LText('Aujourd\'hui · 07:20', 'Today · 07:20'), 280),
  PatientMeal(LText('Biscuits, soda', 'Biscuits, soda'),
      LText('Hier · 22:10', 'Yesterday · 22:10'), 330,
      late: true),
];

// ---- Compte rendu ----
const reportContext = LText(
    'Nadège Ngono · Séance 4 · 24 novembre', 'Nadège Ngono · Session 4 · November 24');
const reportSummary = LText(
    'La collation de 17 h a bien réduit le grignotage du soir. Poids en baisse régulière.',
    'The 5 pm snack has cut evening snacking. Weight is going down steadily.');
const reportFields = [
  (LText('Poids (kg)', 'Weight (kg)'), LText('79,1', '79.1')),
  (LText('Taille (cm)', 'Waist (cm)'), LText('91,5', '91.5')),
  (LText('Glycémie (g/L)', 'Glucose (g/L)'), LText('1,05', '1.05')),
];
const reportGoals = [
  LText('Garder la collation de 17 h', 'Keep the 5 pm snack'),
  LText('Marcher 30 min, 5 fois par semaine', 'Walk 30 min, 5 times a week'),
  LText('Plantain bouilli plutôt que frit', 'Boiled plantain instead of fried'),
];

/// 3 plans de repas (le jour de la semaine choisit le plan : jour % 3), 4 repas chacun.
const reportPlans = <List<(LText, int)>>[
  [
    (LText('Bouillie de maïs, 1 œuf, papaye', 'Corn porridge, 1 egg, papaya'), 330),
    (LText('Poisson braisé, miondo, crudités', 'Grilled fish, miondo, raw veggies'), 560),
    (LText('1 mangue', '1 mango'), 140),
    (LText('Soupe de légumes, poulet grillé', 'Vegetable soup, grilled chicken'), 520),
  ],
  [
    (LText('Pain complet, avocat, thé', 'Wholemeal bread, avocado, tea'), 340),
    (LText('Ndolé léger, plantain bouilli', 'Light ndolé, boiled plantain'), 590),
    (LText('Yaourt de soja', 'Soy yogurt'), 150),
    (LText('Eru léger, poisson', 'Light eru, fish'), 480),
  ],
  [
    (LText('Koki, banane', 'Koki, banana'), 320),
    (LText('Riz, sauce arachide légère, légumes', 'Rice, light peanut sauce, vegetables'), 540),
    (LText('1 orange, 10 arachides', '1 orange, 10 peanuts'), 130),
    (LText('Poulet DG allégé, légumes vapeur', 'Lighter chicken DG, steamed vegetables'), 560),
  ],
];
