// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Tchihali';

  @override
  String get navHome => 'Accueil';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeAddMeal => 'Ajouter un repas';

  @override
  String get back => 'Retour';

  @override
  String get langLabel => 'Langue';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get onb1Title => 'Bien manger,\nsans vous priver.';

  @override
  String get onb1Text =>
      'Une diététicienne diplômée vous accompagne, à votre rythme.';

  @override
  String get onb1Start => 'Commencer';

  @override
  String get onb1Login => 'J\'ai déjà un compte';

  @override
  String get onb2Title => 'Une photo,\net c\'est noté.';

  @override
  String get onb2Text =>
      'Photographiez votre assiette. Votre diététicienne voit votre journal.';

  @override
  String get onb3Card => 'Mardi 24 nov. · 10:30';

  @override
  String get onb3Confirmed => 'Confirmé';

  @override
  String get onb3Title => 'Au cabinet\nou en vidéo.';

  @override
  String get onb3Text =>
      'Réservez en un instant. Payez par carte ou Mobile Money.';

  @override
  String get onb3Cta => 'Créer mon compte';

  @override
  String get onbKcal => '540 kcal';

  @override
  String get signupTitle => 'Créons votre compte';

  @override
  String get signupSub => 'Pas de mot de passe : un simple code par SMS.';

  @override
  String get fieldName => 'Votre nom';

  @override
  String get fieldPhone => 'Votre numéro de téléphone';

  @override
  String get phoneHint => 'Nous vous envoyons un code à 6 chiffres.';

  @override
  String get terms =>
      'J\'accepte les conditions d\'utilisation et la protection de mes données de santé.';

  @override
  String get signupCta => 'Recevoir mon code';

  @override
  String get codeTitle => 'Entrez votre code';

  @override
  String codeSub(String phone) {
    return 'Code envoyé au +237 $phone';
  }

  @override
  String get codeCta => 'Valider';

  @override
  String get codeResend => 'Renvoyer le code';

  @override
  String get qNext => 'Continuer';

  @override
  String get qFinish => 'Terminer';

  @override
  String get q1Title => 'Quel est votre objectif ?';

  @override
  String get q1Sub => 'Choisissez celui qui compte le plus pour vous.';

  @override
  String get q1o1 => 'Perdre du poids';

  @override
  String get q1o2 => 'Mieux gérer mon diabète';

  @override
  String get q1o3 => 'Manger plus équilibré';

  @override
  String get q1o4 => 'Prendre du muscle';

  @override
  String get q2Title => 'Avez-vous un problème de santé ?';

  @override
  String get q2Sub => 'Plusieurs choix possibles.';

  @override
  String get q2o1 => 'Prédiabète';

  @override
  String get q2o2 => 'Diabète';

  @override
  String get q2o3 => 'Hypertension';

  @override
  String get q2o4 => 'Aucun';

  @override
  String get q3Title => 'Des allergies ou intolérances ?';

  @override
  String get q3Sub => 'Plusieurs choix possibles.';

  @override
  String get q3o1 => 'Lactose';

  @override
  String get q3o2 => 'Arachides';

  @override
  String get q3o3 => 'Gluten';

  @override
  String get q3o4 => 'Aucune';

  @override
  String homeHello(String name) {
    return 'Bonjour $name';
  }

  @override
  String get homeNext => 'Prochain rendez-vous';

  @override
  String get modeVideo => 'Vidéo';

  @override
  String get homeJoin => 'Salle d\'attente';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get homeMsg =>
      'Bravo pour cette semaine ! Ce soir, moins d\'huile dans la sauce.';

  @override
  String get homeGoal1 => 'Boire 1,5 L d\'eau';

  @override
  String get homeGoal2 => 'Marcher 30 minutes';

  @override
  String get homeGoal3 => 'Manger 3 portions de légumes';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalRecipes => 'Recettes';

  @override
  String get journalPrevDay => 'Jour précédent';

  @override
  String get journalNextDay => 'Jour suivant';

  @override
  String get journalKcalDay => '1 260 / 1 700 kcal';

  @override
  String get journalLunch => 'Déjeuner';

  @override
  String get journalDish => 'Poisson braisé, miondo';

  @override
  String get journalProt => 'Prot.';

  @override
  String get journalCarbs => 'Gluc.';

  @override
  String get journalFat => 'Lip.';

  @override
  String get journalMood => 'Comment vous sentez-vous ?';

  @override
  String get journalSymptoms => 'Après le repas';

  @override
  String get mood1 => 'Très mal';

  @override
  String get mood2 => 'Pas bien';

  @override
  String get mood3 => 'Neutre';

  @override
  String get mood4 => 'Bien';

  @override
  String get mood5 => 'Très bien';

  @override
  String get sym1 => 'Ballonnements';

  @override
  String get sym2 => 'Fatigue';

  @override
  String get sym3 => 'Faim rapide';

  @override
  String get sym4 => 'Rien de spécial';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileEdit => 'Modifier';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileSureTitle => 'Se déconnecter ?';

  @override
  String get profileSureText =>
      'Vos données restent sauvegardées. Reconnectez-vous avec votre numéro.';

  @override
  String get profileProgress => 'Mes progrès';

  @override
  String get profileRecord => 'Mon carnet de suivi';

  @override
  String get profileHealth => 'Mes informations de santé';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileHelp => 'Aide et contact';

  @override
  String get dirTitle => 'Trouver ma diététicienne';

  @override
  String get dirSearch => 'Nom ou spécialité';

  @override
  String get dirFilters => 'Filtres';

  @override
  String get dirNext => 'Prochain créneau';

  @override
  String get dirBook => 'Réserver';

  @override
  String get dirAll => 'Tous';

  @override
  String get modeOffice => 'Cabinet';

  @override
  String get bookWith => 'Rendez-vous avec';

  @override
  String get bookPrevMonth => 'Mois précédent';

  @override
  String get bookNextMonth => 'Mois suivant';

  @override
  String get bookContinue => 'Continuer';

  @override
  String bookSlotsOf(String date) {
    return 'Créneaux du $date';
  }

  @override
  String get bookSlotsNone => 'Créneaux du —';

  @override
  String get bookFull => 'complet';

  @override
  String get weekdayInitials => 'L,M,M,J,V,S,D';

  @override
  String get payTitle => 'Paiement';

  @override
  String get payHow => 'Payer avec';

  @override
  String get payNumber => 'Numéro Mobile Money';

  @override
  String payCta(String amount) {
    return 'Payer $amount';
  }

  @override
  String get payCancel => 'Annulation gratuite jusqu\'à 24 h avant';

  @override
  String get payCard => 'Carte bancaire';

  @override
  String get msgOnline => 'En ligne · répond sous 24 h';

  @override
  String get msgCall => 'Appel vidéo';

  @override
  String get msgM1 =>
      'Mon dîner d\'hier : ndolé et plantain. La portion est bonne ?';

  @override
  String get msgM2 =>
      'Très belle assiette ! La portion est parfaite. Juste un peu moins d\'huile.';

  @override
  String get msgPhoto => 'Envoyer une photo';

  @override
  String get msgWrite => 'Écrire un message…';

  @override
  String get msgSend => 'Envoyer';

  @override
  String get progTitle => 'Mes progrès';

  @override
  String get progTabWeight => 'Poids';

  @override
  String get progTabBmi => 'IMC';

  @override
  String get progTabWaist => 'Taille';

  @override
  String get progStart => '24 août';

  @override
  String get progEnd => '15 nov.';

  @override
  String get progGoal => 'Objectif';

  @override
  String get progSince => 'en 12 sem.';

  @override
  String get progBadges => 'Mes badges';

  @override
  String get progB1 => '1re séance';

  @override
  String get progB2 => '14 jours de journal';

  @override
  String get progB3 => '−4 kg';

  @override
  String get recTitle => 'Mon carnet';

  @override
  String get recTabSession => 'Séance';

  @override
  String get recTabPlan => 'Plan';

  @override
  String get recTabDocs => 'Documents';

  @override
  String get recSession => 'Séance 3 · Vidéo';

  @override
  String get recDate => 'Mardi 10 novembre';

  @override
  String get recSummary =>
      'Belle progression : −0,9 kg en 2 semaines. Le grignotage du soir reste à travailler.';

  @override
  String get recGoalsTitle => 'Vos objectifs';

  @override
  String get recGoal1 => 'Foléré sans sucre';

  @override
  String get recGoal2 => 'Une collation à 17 h';

  @override
  String get recGoal3 => 'Marcher 4 fois par semaine';

  @override
  String get recDownload => 'Télécharger';

  @override
  String get recMealTime1 => '7 h';

  @override
  String get recMealLabel1 => 'Petit-déjeuner';

  @override
  String get recMealText1 => 'Bouillie de mil, 1 œuf, papaye';

  @override
  String get recMealTime2 => '13 h';

  @override
  String get recMealLabel2 => 'Déjeuner';

  @override
  String get recMealText2 => 'Miondo, poisson braisé, crudités';

  @override
  String get recMealTime3 => '17 h';

  @override
  String get recMealLabel3 => 'Collation';

  @override
  String get recMealText3 => '1 mangue';

  @override
  String get recMealTime4 => '20 h';

  @override
  String get recMealLabel4 => 'Dîner';

  @override
  String get recMealText4 => 'Ndolé léger, plantain bouilli';

  @override
  String get recDoc1 => 'Plan alimentaire';

  @override
  String get recDoc1Meta => '10 nov.';

  @override
  String get recDoc2 => 'Bilan sanguin';

  @override
  String get recDoc2Meta => '3 nov.';

  @override
  String get recDoc3 => 'Facture séance 3';

  @override
  String get recDoc3Meta => '12 000 FCFA';

  @override
  String get recipesTitle => 'Recettes';

  @override
  String get recipesAll => 'Toutes';

  @override
  String get recipesSlim => 'Minceur';

  @override
  String get recipesDiabetes => 'Diabète';

  @override
  String get recipesVeg => 'Végétarien';

  @override
  String get recipeFav => 'Favori';

  @override
  String get recipeIngredients => 'Ingrédients';

  @override
  String get recipeAdd => 'Ajouter à mon journal';

  @override
  String recipeServings(int n) {
    return '$n portions';
  }

  @override
  String get recipeEasy => 'Facile';

  @override
  String get recipeMedium => 'Moyen';

  @override
  String get waitLeave => 'Quitter';

  @override
  String get waitTitle => 'Salle d\'attente';

  @override
  String get waitCamOff => 'Caméra coupée';

  @override
  String get waitMic => 'Micro';

  @override
  String get waitCamera => 'Caméra';

  @override
  String get waitComing => 'Estelle arrive';

  @override
  String get waitEta => 'Dans 2 minutes environ';

  @override
  String get waitEnter => 'Entrer en consultation';

  @override
  String get callLive => 'En cours';

  @override
  String get callHang => 'Raccrocher';

  @override
  String get proSpace => 'Espace praticien';

  @override
  String get proAgenda => 'Agenda';

  @override
  String get proPatients => 'Patients';

  @override
  String get proReports => 'Comptes rendus';

  @override
  String get proRole => 'Diététicienne';

  @override
  String get proNewSlot => '+ Ajouter un créneau';

  @override
  String proWeek(String date) {
    return 'Semaine du $date';
  }

  @override
  String get proPending => 'Demandes à valider';

  @override
  String get proRefuse => 'Refuser';

  @override
  String get proAccept => 'Valider';

  @override
  String get proAccepted => 'Validé · patient prévenu par SMS';

  @override
  String get proRefused => 'Refusé · autre créneau proposé';

  @override
  String get proWrite => 'Rédiger le compte rendu';

  @override
  String get proChart => 'Évolution du poids';

  @override
  String get proChartGoal => 'Objectif 75 kg';

  @override
  String get proMeals => 'Derniers repas';

  @override
  String get proNotes => 'Notes privées';

  @override
  String get proNotePrivate => 'Visible uniquement par vous';

  @override
  String get proKpiWeight => 'Poids';

  @override
  String get proKpiWaist => 'Tour de taille';

  @override
  String get proKpiGlucose => 'Glycémie à jeun';

  @override
  String get proReportTitle => 'Compte rendu et plan';

  @override
  String get proMeasures => 'Mesures du jour';

  @override
  String get proSummary => 'Ce qu\'il faut retenir';

  @override
  String get proGoals => 'Objectifs pour 2 semaines';

  @override
  String get proPlan => 'Plan alimentaire';

  @override
  String get proTotal => 'Total du jour';

  @override
  String get proSend => 'Envoyer à la patiente';

  @override
  String get proSent => 'Envoyé';

  @override
  String proDraftSaved(String time) {
    return 'Brouillon enregistré à $time';
  }

  @override
  String proSentAt(String time) {
    return 'Envoyé à $time';
  }

  @override
  String get proWeekdaysShort => 'Lun,Mar,Mer,Jeu,Ven,Sam,Dim';
}
