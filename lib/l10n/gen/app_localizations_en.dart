// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tchihali';

  @override
  String get navHome => 'Home';

  @override
  String get navAgenda => 'Schedule';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeAddMeal => 'Add a meal';

  @override
  String get back => 'Back';

  @override
  String get langLabel => 'Language';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get onb1Title => 'Eat well,\nwithout going without.';

  @override
  String get onb1Text =>
      'A qualified dietitian supports you, at your own pace.';

  @override
  String get onb1Start => 'Get started';

  @override
  String get onb1Login => 'I already have an account';

  @override
  String get onb2Title => 'Snap a photo,\nand it\'s logged.';

  @override
  String get onb2Text =>
      'Take a picture of your plate. Your dietitian sees your journal.';

  @override
  String get onb3Card => 'Tue, Nov 24 · 10:30';

  @override
  String get onb3Confirmed => 'Confirmed';

  @override
  String get onb3Title => 'In person\nor by video.';

  @override
  String get onb3Text => 'Book in seconds. Pay by card or Mobile Money.';

  @override
  String get onb3Cta => 'Create my account';

  @override
  String get onbKcal => '540 kcal';

  @override
  String get signupTitle => 'Let\'s create your account';

  @override
  String get signupSub => 'No password: just a code by text message.';

  @override
  String get fieldName => 'Your name';

  @override
  String get fieldPhone => 'Your phone number';

  @override
  String get phoneHint => 'We\'ll text you a 6-digit code.';

  @override
  String get terms =>
      'I accept the terms of use and the protection of my health data.';

  @override
  String get signupCta => 'Get my code';

  @override
  String get codeTitle => 'Enter your code';

  @override
  String codeSub(String phone) {
    return 'Code sent to +237 $phone';
  }

  @override
  String get codeCta => 'Confirm';

  @override
  String get codeResend => 'Resend code';

  @override
  String get qNext => 'Continue';

  @override
  String get qFinish => 'Finish';

  @override
  String get q1Title => 'What is your goal?';

  @override
  String get q1Sub => 'Pick the one that matters most to you.';

  @override
  String get q1o1 => 'Lose weight';

  @override
  String get q1o2 => 'Manage my diabetes';

  @override
  String get q1o3 => 'Eat a balanced diet';

  @override
  String get q1o4 => 'Build muscle';

  @override
  String get q2Title => 'Do you have a health condition?';

  @override
  String get q2Sub => 'You can pick several.';

  @override
  String get q2o1 => 'Prediabetes';

  @override
  String get q2o2 => 'Diabetes';

  @override
  String get q2o3 => 'High blood pressure';

  @override
  String get q2o4 => 'None';

  @override
  String get q3Title => 'Any allergies or intolerances?';

  @override
  String get q3Sub => 'You can pick several.';

  @override
  String get q3o1 => 'Lactose';

  @override
  String get q3o2 => 'Peanuts';

  @override
  String get q3o3 => 'Gluten';

  @override
  String get q3o4 => 'None';

  @override
  String homeHello(String name) {
    return 'Hello $name';
  }

  @override
  String get homeNext => 'Next appointment';

  @override
  String get modeVideo => 'Video';

  @override
  String get homeJoin => 'Waiting room';

  @override
  String get today => 'Today';

  @override
  String get homeMsg =>
      'Well done this week! Tonight, a little less oil in the sauce.';

  @override
  String get homeGoal1 => 'Drink 1.5 L of water';

  @override
  String get homeGoal2 => 'Walk for 30 minutes';

  @override
  String get homeGoal3 => 'Eat 3 servings of vegetables';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalRecipes => 'Recipes';

  @override
  String get journalPrevDay => 'Previous day';

  @override
  String get journalNextDay => 'Next day';

  @override
  String get journalKcalDay => '1,260 / 1,700 kcal';

  @override
  String get journalLunch => 'Lunch';

  @override
  String get journalDish => 'Grilled fish, miondo';

  @override
  String get journalProt => 'Prot.';

  @override
  String get journalCarbs => 'Carbs';

  @override
  String get journalFat => 'Fat';

  @override
  String get journalMood => 'How do you feel?';

  @override
  String get journalSymptoms => 'After the meal';

  @override
  String get mood1 => 'Very bad';

  @override
  String get mood2 => 'Not good';

  @override
  String get mood3 => 'Neutral';

  @override
  String get mood4 => 'Good';

  @override
  String get mood5 => 'Very good';

  @override
  String get sym1 => 'Bloating';

  @override
  String get sym2 => 'Tiredness';

  @override
  String get sym3 => 'Hungry soon';

  @override
  String get sym4 => 'Nothing special';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSureTitle => 'Log out?';

  @override
  String get profileSureText =>
      'Your data stays saved. Log back in with your phone number.';

  @override
  String get profileProgress => 'My progress';

  @override
  String get profileRecord => 'My care record';

  @override
  String get profileHealth => 'My health information';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileHelp => 'Help and contact';

  @override
  String get dirTitle => 'Find my dietitian';

  @override
  String get dirSearch => 'Name or specialty';

  @override
  String get dirFilters => 'Filters';

  @override
  String get dirNext => 'Next available';

  @override
  String get dirBook => 'Book';

  @override
  String get dirAll => 'All';

  @override
  String get modeOffice => 'In person';

  @override
  String get bookWith => 'Appointment with';

  @override
  String get bookPrevMonth => 'Previous month';

  @override
  String get bookNextMonth => 'Next month';

  @override
  String get bookContinue => 'Continue';

  @override
  String bookSlotsOf(String date) {
    return 'Slots for $date';
  }

  @override
  String get bookSlotsNone => 'Slots for —';

  @override
  String get bookFull => 'full';

  @override
  String get weekdayInitials => 'M,T,W,T,F,S,S';

  @override
  String get payTitle => 'Payment';

  @override
  String get payHow => 'Pay with';

  @override
  String get payNumber => 'Mobile Money number';

  @override
  String payCta(String amount) {
    return 'Pay $amount';
  }

  @override
  String get payCancel => 'Free cancellation up to 24 h before';

  @override
  String get payCard => 'Bank card';

  @override
  String get msgOnline => 'Online · replies within 24 h';

  @override
  String get msgCall => 'Video call';

  @override
  String get msgM1 =>
      'Last night\'s dinner: ndolé and plantain. Is the portion okay?';

  @override
  String get msgM2 =>
      'Lovely plate! The portion is perfect. Just a little less oil.';

  @override
  String get msgPhoto => 'Send a photo';

  @override
  String get msgWrite => 'Write a message…';

  @override
  String get msgSend => 'Send';

  @override
  String get progTitle => 'My progress';

  @override
  String get progTabWeight => 'Weight';

  @override
  String get progTabBmi => 'BMI';

  @override
  String get progTabWaist => 'Waist';

  @override
  String get progStart => 'Aug 24';

  @override
  String get progEnd => 'Nov 15';

  @override
  String get progGoal => 'Goal';

  @override
  String get progSince => 'in 12 wks';

  @override
  String get progBadges => 'My badges';

  @override
  String get progB1 => '1st session';

  @override
  String get progB2 => '14-day journal streak';

  @override
  String get progB3 => '−4 kg';

  @override
  String get recTitle => 'My record';

  @override
  String get recTabSession => 'Session';

  @override
  String get recTabPlan => 'Plan';

  @override
  String get recTabDocs => 'Documents';

  @override
  String get recSession => 'Session 3 · Video';

  @override
  String get recDate => 'Tuesday, November 10';

  @override
  String get recSummary =>
      'Great progress: −0.9 kg in 2 weeks. Evening snacking is still the thing to work on.';

  @override
  String get recGoalsTitle => 'Your goals';

  @override
  String get recGoal1 => 'Sugar-free foléré';

  @override
  String get recGoal2 => 'A snack at 5 pm';

  @override
  String get recGoal3 => 'Walk 4 times a week';

  @override
  String get recDownload => 'Download';

  @override
  String get recMealTime1 => '7 am';

  @override
  String get recMealLabel1 => 'Breakfast';

  @override
  String get recMealText1 => 'Millet porridge, 1 egg, papaya';

  @override
  String get recMealTime2 => '1 pm';

  @override
  String get recMealLabel2 => 'Lunch';

  @override
  String get recMealText2 => 'Miondo, grilled fish, raw veggies';

  @override
  String get recMealTime3 => '5 pm';

  @override
  String get recMealLabel3 => 'Snack';

  @override
  String get recMealText3 => '1 mango';

  @override
  String get recMealTime4 => '8 pm';

  @override
  String get recMealLabel4 => 'Dinner';

  @override
  String get recMealText4 => 'Light ndolé, boiled plantain';

  @override
  String get recDoc1 => 'Meal plan';

  @override
  String get recDoc1Meta => 'Nov 10';

  @override
  String get recDoc2 => 'Blood test';

  @override
  String get recDoc2Meta => 'Nov 3';

  @override
  String get recDoc3 => 'Session 3 invoice';

  @override
  String get recDoc3Meta => '12,000 FCFA';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesAll => 'All';

  @override
  String get recipesSlim => 'Weight loss';

  @override
  String get recipesDiabetes => 'Diabetes';

  @override
  String get recipesVeg => 'Vegetarian';

  @override
  String get recipeFav => 'Favorite';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeAdd => 'Add to my journal';

  @override
  String recipeServings(int n) {
    return '$n servings';
  }

  @override
  String get recipeEasy => 'Easy';

  @override
  String get recipeMedium => 'Medium';

  @override
  String get waitLeave => 'Leave';

  @override
  String get waitTitle => 'Waiting room';

  @override
  String get waitCamOff => 'Camera off';

  @override
  String get waitMic => 'Microphone';

  @override
  String get waitCamera => 'Camera';

  @override
  String get waitComing => 'Estelle is on her way';

  @override
  String get waitEta => 'In about 2 minutes';

  @override
  String get waitEnter => 'Join the consultation';

  @override
  String get callLive => 'Live';

  @override
  String get callHang => 'Hang up';

  @override
  String get proSpace => 'Practitioner space';

  @override
  String get proAgenda => 'Schedule';

  @override
  String get proPatients => 'Patients';

  @override
  String get proReports => 'Reports';

  @override
  String get proRole => 'Dietitian';

  @override
  String get proNewSlot => '+ Add a slot';

  @override
  String proWeek(String date) {
    return 'Week of $date';
  }

  @override
  String get proPending => 'Requests to approve';

  @override
  String get proRefuse => 'Decline';

  @override
  String get proAccept => 'Approve';

  @override
  String get proAccepted => 'Approved · patient notified by text';

  @override
  String get proRefused => 'Declined · another slot offered';

  @override
  String get proWrite => 'Write the report';

  @override
  String get proChart => 'Weight over time';

  @override
  String get proChartGoal => 'Goal 75 kg';

  @override
  String get proMeals => 'Latest meals';

  @override
  String get proNotes => 'Private notes';

  @override
  String get proNotePrivate => 'Only visible to you';

  @override
  String get proKpiWeight => 'Weight';

  @override
  String get proKpiWaist => 'Waist';

  @override
  String get proKpiGlucose => 'Fasting glucose';

  @override
  String get proReportTitle => 'Report and plan';

  @override
  String get proMeasures => 'Today\'s measurements';

  @override
  String get proSummary => 'Key takeaways';

  @override
  String get proGoals => 'Goals for 2 weeks';

  @override
  String get proPlan => 'Meal plan';

  @override
  String get proTotal => 'Daily total';

  @override
  String get proSend => 'Send to patient';

  @override
  String get proSent => 'Sent';

  @override
  String proDraftSaved(String time) {
    return 'Draft saved at $time';
  }

  @override
  String proSentAt(String time) {
    return 'Sent at $time';
  }

  @override
  String get proWeekdaysShort => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get errorNetwork => 'Can\'t connect. Check your network.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorSlotTaken =>
      'This slot was just booked. Please pick another one.';

  @override
  String get errorCode => 'Wrong or expired code.';

  @override
  String get errorTooMany => 'Too many attempts. Try again in a few minutes.';

  @override
  String get retry => 'Retry';

  @override
  String get dirNoSlot => '—';

  @override
  String get homeNoAppointment => 'No appointment scheduled';

  @override
  String get homeBookNow => 'Book an appointment';

  @override
  String get homePending => 'Awaiting confirmation';

  @override
  String get journalEmpty => 'No meal logged for this day.';

  @override
  String get journalAddMeal => 'Add a meal';

  @override
  String get journalDeleteMeal => 'Delete this meal';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealSnack => 'Snack';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get addMealTitle => 'Add a meal';

  @override
  String get addMealPhoto => 'Meal photo';

  @override
  String get photoCamera => 'Take a photo';

  @override
  String get photoGallery => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get addMealType => 'Meal';

  @override
  String get addMealName => 'Dish name';

  @override
  String get addMealKcal => 'Calories (kcal)';

  @override
  String get addMealProtein => 'Protein (g)';

  @override
  String get addMealCarbs => 'Carbs (g)';

  @override
  String get addMealFat => 'Fat (g)';

  @override
  String get addMealSave => 'Save meal';

  @override
  String get addMealInvalid => 'Enter the dish name and calories.';

  @override
  String progSinceWeeks(int n) {
    return 'in $n wks';
  }

  @override
  String get progNoData =>
      'No measurements yet. Add your weight to track your progress.';

  @override
  String get progAddMeasure => 'Add a measurement';

  @override
  String get progWeightLabel => 'Weight (kg)';

  @override
  String get progWaistLabel => 'Waist (cm)';

  @override
  String get progSave => 'Save';

  @override
  String get progMeasureInvalid => 'Enter at least one valid measurement.';

  @override
  String get recNoSession => 'No report yet.';

  @override
  String get recNoPlan => 'No meal plan yet.';

  @override
  String get recNoDocs => 'No documents.';

  @override
  String get recOpenError => 'Could not open the document.';

  @override
  String recSessionLabel(int n, String mode) {
    return 'Session $n · $mode';
  }

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'No notifications.';

  @override
  String notifAppointmentConfirmed(String date, String dietitian) {
    return 'Your appointment on $date with $dietitian is confirmed.';
  }

  @override
  String notifAppointmentRefused(String date) {
    return 'Your request for $date could not be accepted. Please pick another slot.';
  }

  @override
  String notifReportSent(int n) {
    return 'Your report for session $n is available in your record.';
  }

  @override
  String notifNewMessage(String who) {
    return 'New message from $who.';
  }

  @override
  String notifAppointmentRequest(String who, String date) {
    return 'New request from $who for $date.';
  }

  @override
  String get profileEditName => 'Edit my name';

  @override
  String get profileSave => 'Save';
}
