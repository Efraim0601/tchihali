import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Tchihali'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// No description provided for @navJournal.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @homeAddMeal.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un repas'**
  String get homeAddMeal;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @langLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get langLabel;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @onb1Title.
  ///
  /// In fr, this message translates to:
  /// **'Bien manger,\nsans vous priver.'**
  String get onb1Title;

  /// No description provided for @onb1Text.
  ///
  /// In fr, this message translates to:
  /// **'Une diététicienne diplômée vous accompagne, à votre rythme.'**
  String get onb1Text;

  /// No description provided for @onb1Start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onb1Start;

  /// No description provided for @onb1Login.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get onb1Login;

  /// No description provided for @onb2Title.
  ///
  /// In fr, this message translates to:
  /// **'Une photo,\net c\'est noté.'**
  String get onb2Title;

  /// No description provided for @onb2Text.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez votre assiette. Votre diététicienne voit votre journal.'**
  String get onb2Text;

  /// No description provided for @onb3Card.
  ///
  /// In fr, this message translates to:
  /// **'Mardi 24 nov. · 10:30'**
  String get onb3Card;

  /// No description provided for @onb3Confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get onb3Confirmed;

  /// No description provided for @onb3Title.
  ///
  /// In fr, this message translates to:
  /// **'Au cabinet\nou en vidéo.'**
  String get onb3Title;

  /// No description provided for @onb3Text.
  ///
  /// In fr, this message translates to:
  /// **'Réservez en un instant. Payez par carte ou Mobile Money.'**
  String get onb3Text;

  /// No description provided for @onb3Cta.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get onb3Cta;

  /// No description provided for @onbKcal.
  ///
  /// In fr, this message translates to:
  /// **'540 kcal'**
  String get onbKcal;

  /// No description provided for @signupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créons votre compte'**
  String get signupTitle;

  /// No description provided for @signupSub.
  ///
  /// In fr, this message translates to:
  /// **'Pas de mot de passe : un simple code par SMS.'**
  String get signupSub;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get fieldName;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro de téléphone'**
  String get fieldPhone;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous envoyons un code à 6 chiffres.'**
  String get phoneHint;

  /// No description provided for @terms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions d\'utilisation et la protection de mes données de santé.'**
  String get terms;

  /// No description provided for @signupCta.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir mon code'**
  String get signupCta;

  /// No description provided for @codeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code'**
  String get codeTitle;

  /// No description provided for @codeSub.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé au +237 {phone}'**
  String codeSub(String phone);

  /// No description provided for @codeCta.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get codeCta;

  /// No description provided for @codeResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get codeResend;

  /// No description provided for @qNext.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get qNext;

  /// No description provided for @qFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get qFinish;

  /// No description provided for @q1Title.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre objectif ?'**
  String get q1Title;

  /// No description provided for @q1Sub.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez celui qui compte le plus pour vous.'**
  String get q1Sub;

  /// No description provided for @q1o1.
  ///
  /// In fr, this message translates to:
  /// **'Perdre du poids'**
  String get q1o1;

  /// No description provided for @q1o2.
  ///
  /// In fr, this message translates to:
  /// **'Mieux gérer mon diabète'**
  String get q1o2;

  /// No description provided for @q1o3.
  ///
  /// In fr, this message translates to:
  /// **'Manger plus équilibré'**
  String get q1o3;

  /// No description provided for @q1o4.
  ///
  /// In fr, this message translates to:
  /// **'Prendre du muscle'**
  String get q1o4;

  /// No description provided for @q2Title.
  ///
  /// In fr, this message translates to:
  /// **'Avez-vous un problème de santé ?'**
  String get q2Title;

  /// No description provided for @q2Sub.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs choix possibles.'**
  String get q2Sub;

  /// No description provided for @q2o1.
  ///
  /// In fr, this message translates to:
  /// **'Prédiabète'**
  String get q2o1;

  /// No description provided for @q2o2.
  ///
  /// In fr, this message translates to:
  /// **'Diabète'**
  String get q2o2;

  /// No description provided for @q2o3.
  ///
  /// In fr, this message translates to:
  /// **'Hypertension'**
  String get q2o3;

  /// No description provided for @q2o4.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get q2o4;

  /// No description provided for @q3Title.
  ///
  /// In fr, this message translates to:
  /// **'Des allergies ou intolérances ?'**
  String get q3Title;

  /// No description provided for @q3Sub.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs choix possibles.'**
  String get q3Sub;

  /// No description provided for @q3o1.
  ///
  /// In fr, this message translates to:
  /// **'Lactose'**
  String get q3o1;

  /// No description provided for @q3o2.
  ///
  /// In fr, this message translates to:
  /// **'Arachides'**
  String get q3o2;

  /// No description provided for @q3o3.
  ///
  /// In fr, this message translates to:
  /// **'Gluten'**
  String get q3o3;

  /// No description provided for @q3o4.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get q3o4;

  /// No description provided for @homeHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String homeHello(String name);

  /// No description provided for @homeNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochain rendez-vous'**
  String get homeNext;

  /// No description provided for @modeVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get modeVideo;

  /// No description provided for @homeJoin.
  ///
  /// In fr, this message translates to:
  /// **'Salle d\'attente'**
  String get homeJoin;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @homeMsg.
  ///
  /// In fr, this message translates to:
  /// **'Bravo pour cette semaine ! Ce soir, moins d\'huile dans la sauce.'**
  String get homeMsg;

  /// No description provided for @homeGoal1.
  ///
  /// In fr, this message translates to:
  /// **'Boire 1,5 L d\'eau'**
  String get homeGoal1;

  /// No description provided for @homeGoal2.
  ///
  /// In fr, this message translates to:
  /// **'Marcher 30 minutes'**
  String get homeGoal2;

  /// No description provided for @homeGoal3.
  ///
  /// In fr, this message translates to:
  /// **'Manger 3 portions de légumes'**
  String get homeGoal3;

  /// No description provided for @journalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalRecipes.
  ///
  /// In fr, this message translates to:
  /// **'Recettes'**
  String get journalRecipes;

  /// No description provided for @journalPrevDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour précédent'**
  String get journalPrevDay;

  /// No description provided for @journalNextDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour suivant'**
  String get journalNextDay;

  /// No description provided for @journalKcalDay.
  ///
  /// In fr, this message translates to:
  /// **'1 260 / 1 700 kcal'**
  String get journalKcalDay;

  /// No description provided for @journalLunch.
  ///
  /// In fr, this message translates to:
  /// **'Déjeuner'**
  String get journalLunch;

  /// No description provided for @journalDish.
  ///
  /// In fr, this message translates to:
  /// **'Poisson braisé, miondo'**
  String get journalDish;

  /// No description provided for @journalProt.
  ///
  /// In fr, this message translates to:
  /// **'Prot.'**
  String get journalProt;

  /// No description provided for @journalCarbs.
  ///
  /// In fr, this message translates to:
  /// **'Gluc.'**
  String get journalCarbs;

  /// No description provided for @journalFat.
  ///
  /// In fr, this message translates to:
  /// **'Lip.'**
  String get journalFat;

  /// No description provided for @journalMood.
  ///
  /// In fr, this message translates to:
  /// **'Comment vous sentez-vous ?'**
  String get journalMood;

  /// No description provided for @journalSymptoms.
  ///
  /// In fr, this message translates to:
  /// **'Après le repas'**
  String get journalSymptoms;

  /// No description provided for @mood1.
  ///
  /// In fr, this message translates to:
  /// **'Très mal'**
  String get mood1;

  /// No description provided for @mood2.
  ///
  /// In fr, this message translates to:
  /// **'Pas bien'**
  String get mood2;

  /// No description provided for @mood3.
  ///
  /// In fr, this message translates to:
  /// **'Neutre'**
  String get mood3;

  /// No description provided for @mood4.
  ///
  /// In fr, this message translates to:
  /// **'Bien'**
  String get mood4;

  /// No description provided for @mood5.
  ///
  /// In fr, this message translates to:
  /// **'Très bien'**
  String get mood5;

  /// No description provided for @sym1.
  ///
  /// In fr, this message translates to:
  /// **'Ballonnements'**
  String get sym1;

  /// No description provided for @sym2.
  ///
  /// In fr, this message translates to:
  /// **'Fatigue'**
  String get sym2;

  /// No description provided for @sym3.
  ///
  /// In fr, this message translates to:
  /// **'Faim rapide'**
  String get sym3;

  /// No description provided for @sym4.
  ///
  /// In fr, this message translates to:
  /// **'Rien de spécial'**
  String get sym4;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get profileEdit;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get profileCancel;

  /// No description provided for @profileSureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get profileSureTitle;

  /// No description provided for @profileSureText.
  ///
  /// In fr, this message translates to:
  /// **'Vos données restent sauvegardées. Reconnectez-vous avec votre numéro.'**
  String get profileSureText;

  /// No description provided for @profileProgress.
  ///
  /// In fr, this message translates to:
  /// **'Mes progrès'**
  String get profileProgress;

  /// No description provided for @profileRecord.
  ///
  /// In fr, this message translates to:
  /// **'Mon carnet de suivi'**
  String get profileRecord;

  /// No description provided for @profileHealth.
  ///
  /// In fr, this message translates to:
  /// **'Mes informations de santé'**
  String get profileHealth;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide et contact'**
  String get profileHelp;

  /// No description provided for @dirTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouver ma diététicienne'**
  String get dirTitle;

  /// No description provided for @dirSearch.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou spécialité'**
  String get dirSearch;

  /// No description provided for @dirFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get dirFilters;

  /// No description provided for @dirNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochain créneau'**
  String get dirNext;

  /// No description provided for @dirBook.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get dirBook;

  /// No description provided for @dirAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get dirAll;

  /// No description provided for @modeOffice.
  ///
  /// In fr, this message translates to:
  /// **'Cabinet'**
  String get modeOffice;

  /// No description provided for @bookWith.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous avec'**
  String get bookWith;

  /// No description provided for @bookPrevMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois précédent'**
  String get bookPrevMonth;

  /// No description provided for @bookNextMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois suivant'**
  String get bookNextMonth;

  /// No description provided for @bookContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get bookContinue;

  /// No description provided for @bookSlotsOf.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux du {date}'**
  String bookSlotsOf(String date);

  /// No description provided for @bookSlotsNone.
  ///
  /// In fr, this message translates to:
  /// **'Créneaux du —'**
  String get bookSlotsNone;

  /// No description provided for @bookFull.
  ///
  /// In fr, this message translates to:
  /// **'complet'**
  String get bookFull;

  /// No description provided for @weekdayInitials.
  ///
  /// In fr, this message translates to:
  /// **'L,M,M,J,V,S,D'**
  String get weekdayInitials;

  /// No description provided for @payTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get payTitle;

  /// No description provided for @payHow.
  ///
  /// In fr, this message translates to:
  /// **'Payer avec'**
  String get payHow;

  /// No description provided for @payNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro Mobile Money'**
  String get payNumber;

  /// No description provided for @payCta.
  ///
  /// In fr, this message translates to:
  /// **'Payer {amount}'**
  String payCta(String amount);

  /// No description provided for @payCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annulation gratuite jusqu\'à 24 h avant'**
  String get payCancel;

  /// No description provided for @payCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte bancaire'**
  String get payCard;

  /// No description provided for @msgOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne · répond sous 24 h'**
  String get msgOnline;

  /// No description provided for @msgCall.
  ///
  /// In fr, this message translates to:
  /// **'Appel vidéo'**
  String get msgCall;

  /// No description provided for @msgM1.
  ///
  /// In fr, this message translates to:
  /// **'Mon dîner d\'hier : ndolé et plantain. La portion est bonne ?'**
  String get msgM1;

  /// No description provided for @msgM2.
  ///
  /// In fr, this message translates to:
  /// **'Très belle assiette ! La portion est parfaite. Juste un peu moins d\'huile.'**
  String get msgM2;

  /// No description provided for @msgPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une photo'**
  String get msgPhoto;

  /// No description provided for @msgWrite.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message…'**
  String get msgWrite;

  /// No description provided for @msgSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get msgSend;

  /// No description provided for @progTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes progrès'**
  String get progTitle;

  /// No description provided for @progTabWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get progTabWeight;

  /// No description provided for @progTabBmi.
  ///
  /// In fr, this message translates to:
  /// **'IMC'**
  String get progTabBmi;

  /// No description provided for @progTabWaist.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get progTabWaist;

  /// No description provided for @progStart.
  ///
  /// In fr, this message translates to:
  /// **'24 août'**
  String get progStart;

  /// No description provided for @progEnd.
  ///
  /// In fr, this message translates to:
  /// **'15 nov.'**
  String get progEnd;

  /// No description provided for @progGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get progGoal;

  /// No description provided for @progSince.
  ///
  /// In fr, this message translates to:
  /// **'en 12 sem.'**
  String get progSince;

  /// No description provided for @progBadges.
  ///
  /// In fr, this message translates to:
  /// **'Mes badges'**
  String get progBadges;

  /// No description provided for @progB1.
  ///
  /// In fr, this message translates to:
  /// **'1re séance'**
  String get progB1;

  /// No description provided for @progB2.
  ///
  /// In fr, this message translates to:
  /// **'14 jours de journal'**
  String get progB2;

  /// No description provided for @progB3.
  ///
  /// In fr, this message translates to:
  /// **'−4 kg'**
  String get progB3;

  /// No description provided for @recTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon carnet'**
  String get recTitle;

  /// No description provided for @recTabSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance'**
  String get recTabSession;

  /// No description provided for @recTabPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get recTabPlan;

  /// No description provided for @recTabDocs.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get recTabDocs;

  /// No description provided for @recSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance 3 · Vidéo'**
  String get recSession;

  /// No description provided for @recDate.
  ///
  /// In fr, this message translates to:
  /// **'Mardi 10 novembre'**
  String get recDate;

  /// No description provided for @recSummary.
  ///
  /// In fr, this message translates to:
  /// **'Belle progression : −0,9 kg en 2 semaines. Le grignotage du soir reste à travailler.'**
  String get recSummary;

  /// No description provided for @recGoalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos objectifs'**
  String get recGoalsTitle;

  /// No description provided for @recGoal1.
  ///
  /// In fr, this message translates to:
  /// **'Foléré sans sucre'**
  String get recGoal1;

  /// No description provided for @recGoal2.
  ///
  /// In fr, this message translates to:
  /// **'Une collation à 17 h'**
  String get recGoal2;

  /// No description provided for @recGoal3.
  ///
  /// In fr, this message translates to:
  /// **'Marcher 4 fois par semaine'**
  String get recGoal3;

  /// No description provided for @recDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get recDownload;

  /// No description provided for @recMealTime1.
  ///
  /// In fr, this message translates to:
  /// **'7 h'**
  String get recMealTime1;

  /// No description provided for @recMealLabel1.
  ///
  /// In fr, this message translates to:
  /// **'Petit-déjeuner'**
  String get recMealLabel1;

  /// No description provided for @recMealText1.
  ///
  /// In fr, this message translates to:
  /// **'Bouillie de mil, 1 œuf, papaye'**
  String get recMealText1;

  /// No description provided for @recMealTime2.
  ///
  /// In fr, this message translates to:
  /// **'13 h'**
  String get recMealTime2;

  /// No description provided for @recMealLabel2.
  ///
  /// In fr, this message translates to:
  /// **'Déjeuner'**
  String get recMealLabel2;

  /// No description provided for @recMealText2.
  ///
  /// In fr, this message translates to:
  /// **'Miondo, poisson braisé, crudités'**
  String get recMealText2;

  /// No description provided for @recMealTime3.
  ///
  /// In fr, this message translates to:
  /// **'17 h'**
  String get recMealTime3;

  /// No description provided for @recMealLabel3.
  ///
  /// In fr, this message translates to:
  /// **'Collation'**
  String get recMealLabel3;

  /// No description provided for @recMealText3.
  ///
  /// In fr, this message translates to:
  /// **'1 mangue'**
  String get recMealText3;

  /// No description provided for @recMealTime4.
  ///
  /// In fr, this message translates to:
  /// **'20 h'**
  String get recMealTime4;

  /// No description provided for @recMealLabel4.
  ///
  /// In fr, this message translates to:
  /// **'Dîner'**
  String get recMealLabel4;

  /// No description provided for @recMealText4.
  ///
  /// In fr, this message translates to:
  /// **'Ndolé léger, plantain bouilli'**
  String get recMealText4;

  /// No description provided for @recDoc1.
  ///
  /// In fr, this message translates to:
  /// **'Plan alimentaire'**
  String get recDoc1;

  /// No description provided for @recDoc1Meta.
  ///
  /// In fr, this message translates to:
  /// **'10 nov.'**
  String get recDoc1Meta;

  /// No description provided for @recDoc2.
  ///
  /// In fr, this message translates to:
  /// **'Bilan sanguin'**
  String get recDoc2;

  /// No description provided for @recDoc2Meta.
  ///
  /// In fr, this message translates to:
  /// **'3 nov.'**
  String get recDoc2Meta;

  /// No description provided for @recDoc3.
  ///
  /// In fr, this message translates to:
  /// **'Facture séance 3'**
  String get recDoc3;

  /// No description provided for @recDoc3Meta.
  ///
  /// In fr, this message translates to:
  /// **'12 000 FCFA'**
  String get recDoc3Meta;

  /// No description provided for @recipesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recettes'**
  String get recipesTitle;

  /// No description provided for @recipesAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get recipesAll;

  /// No description provided for @recipesSlim.
  ///
  /// In fr, this message translates to:
  /// **'Minceur'**
  String get recipesSlim;

  /// No description provided for @recipesDiabetes.
  ///
  /// In fr, this message translates to:
  /// **'Diabète'**
  String get recipesDiabetes;

  /// No description provided for @recipesVeg.
  ///
  /// In fr, this message translates to:
  /// **'Végétarien'**
  String get recipesVeg;

  /// No description provided for @recipeFav.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get recipeFav;

  /// No description provided for @recipeIngredients.
  ///
  /// In fr, this message translates to:
  /// **'Ingrédients'**
  String get recipeIngredients;

  /// No description provided for @recipeAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à mon journal'**
  String get recipeAdd;

  /// No description provided for @recipeServings.
  ///
  /// In fr, this message translates to:
  /// **'{n} portions'**
  String recipeServings(int n);

  /// No description provided for @recipeEasy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get recipeEasy;

  /// No description provided for @recipeMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get recipeMedium;

  /// No description provided for @waitLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get waitLeave;

  /// No description provided for @waitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Salle d\'attente'**
  String get waitTitle;

  /// No description provided for @waitCamOff.
  ///
  /// In fr, this message translates to:
  /// **'Caméra coupée'**
  String get waitCamOff;

  /// No description provided for @waitMic.
  ///
  /// In fr, this message translates to:
  /// **'Micro'**
  String get waitMic;

  /// No description provided for @waitCamera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get waitCamera;

  /// No description provided for @waitComing.
  ///
  /// In fr, this message translates to:
  /// **'Estelle arrive'**
  String get waitComing;

  /// No description provided for @waitEta.
  ///
  /// In fr, this message translates to:
  /// **'Dans 2 minutes environ'**
  String get waitEta;

  /// No description provided for @waitEnter.
  ///
  /// In fr, this message translates to:
  /// **'Entrer en consultation'**
  String get waitEnter;

  /// No description provided for @callLive.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get callLive;

  /// No description provided for @callHang.
  ///
  /// In fr, this message translates to:
  /// **'Raccrocher'**
  String get callHang;

  /// No description provided for @proSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace praticien'**
  String get proSpace;

  /// No description provided for @proAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get proAgenda;

  /// No description provided for @proPatients.
  ///
  /// In fr, this message translates to:
  /// **'Patients'**
  String get proPatients;

  /// No description provided for @proReports.
  ///
  /// In fr, this message translates to:
  /// **'Comptes rendus'**
  String get proReports;

  /// No description provided for @proRole.
  ///
  /// In fr, this message translates to:
  /// **'Diététicienne'**
  String get proRole;

  /// No description provided for @proNewSlot.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter un créneau'**
  String get proNewSlot;

  /// No description provided for @proWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine du {date}'**
  String proWeek(String date);

  /// No description provided for @proPending.
  ///
  /// In fr, this message translates to:
  /// **'Demandes à valider'**
  String get proPending;

  /// No description provided for @proRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get proRefuse;

  /// No description provided for @proAccept.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get proAccept;

  /// No description provided for @proAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Validé · patient prévenu par SMS'**
  String get proAccepted;

  /// No description provided for @proRefused.
  ///
  /// In fr, this message translates to:
  /// **'Refusé · autre créneau proposé'**
  String get proRefused;

  /// No description provided for @proWrite.
  ///
  /// In fr, this message translates to:
  /// **'Rédiger le compte rendu'**
  String get proWrite;

  /// No description provided for @proChart.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du poids'**
  String get proChart;

  /// No description provided for @proChartGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif 75 kg'**
  String get proChartGoal;

  /// No description provided for @proMeals.
  ///
  /// In fr, this message translates to:
  /// **'Derniers repas'**
  String get proMeals;

  /// No description provided for @proNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes privées'**
  String get proNotes;

  /// No description provided for @proNotePrivate.
  ///
  /// In fr, this message translates to:
  /// **'Visible uniquement par vous'**
  String get proNotePrivate;

  /// No description provided for @proKpiWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get proKpiWeight;

  /// No description provided for @proKpiWaist.
  ///
  /// In fr, this message translates to:
  /// **'Tour de taille'**
  String get proKpiWaist;

  /// No description provided for @proKpiGlucose.
  ///
  /// In fr, this message translates to:
  /// **'Glycémie à jeun'**
  String get proKpiGlucose;

  /// No description provided for @proReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte rendu et plan'**
  String get proReportTitle;

  /// No description provided for @proMeasures.
  ///
  /// In fr, this message translates to:
  /// **'Mesures du jour'**
  String get proMeasures;

  /// No description provided for @proSummary.
  ///
  /// In fr, this message translates to:
  /// **'Ce qu\'il faut retenir'**
  String get proSummary;

  /// No description provided for @proGoals.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs pour 2 semaines'**
  String get proGoals;

  /// No description provided for @proPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan alimentaire'**
  String get proPlan;

  /// No description provided for @proTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total du jour'**
  String get proTotal;

  /// No description provided for @proSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à la patiente'**
  String get proSend;

  /// No description provided for @proSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get proSent;

  /// No description provided for @proDraftSaved.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon enregistré à {time}'**
  String proDraftSaved(String time);

  /// No description provided for @proSentAt.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé à {time}'**
  String proSentAt(String time);

  /// No description provided for @proWeekdaysShort.
  ///
  /// In fr, this message translates to:
  /// **'Lun,Mar,Mer,Jeu,Ven,Sam,Dim'**
  String get proWeekdaysShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
