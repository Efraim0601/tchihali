import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tchihali/app/router.dart';
import 'package:tchihali/main.dart';

/// Parcours en mode démo (aucune adresse d'API : données fictives, aucun réseau).
/// Démonte l'application et laisse passer les dernières images (chargement des polices).
Future<void> _dispose(WidgetTester t) async {
  // Attend la fin du chargement des polices avant de démonter (sinon une image reste planifiée).
  await t.runAsync(() => GoogleFonts.pendingFonts());
  await t.pump(const Duration(milliseconds: 100));
  await t.pumpWidget(const SizedBox.shrink());
  await t.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting();
  });

  Future<void> settle(WidgetTester t) async {
    // Des animations infinies (pulsation, flottement) empêchent pumpAndSettle.
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets(
    'onboarding -> inscription -> code -> questionnaire -> annuaire',
    (t) async {
      SharedPreferences.setMockInitialValues({});
      t.view.physicalSize = const Size(780, 1688); // 390 x 844 à l'échelle 2
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);

      router.go(
        '/onboarding/1',
      ); // le routeur est global : on repart de l'accueil
      await t.pumpWidget(const ProviderScope(child: TchihaliApp()));
      await settle(t);
      expect(find.textContaining('Bien manger'), findsOneWidget);

      await t.tap(find.text('Commencer'));
      await settle(t);
      expect(find.textContaining('Une photo'), findsOneWidget);

      await t.tap(find.text('Suivant'));
      await settle(t);
      expect(find.textContaining('Au cabinet'), findsOneWidget);

      await t.tap(find.text('Créer mon compte'));
      await settle(t);
      expect(find.text('Créons votre compte'), findsOneWidget);

      await t.tap(find.text('Recevoir mon code'));
      await settle(t);
      expect(find.text('Entrez votre code'), findsOneWidget);

      await t.enterText(
        find.byType(EditableText, skipOffstage: false),
        '123456',
      );
      await settle(t);
      await t.tap(find.text('Valider'));
      await settle(t);
      expect(find.text('Quel est votre objectif ?'), findsOneWidget);

      await t.tap(find.text('Continuer'));
      await settle(t);
      await t.tap(find.text('Continuer'));
      await settle(t);
      await t.tap(find.text('Terminer'));
      await settle(t);
      expect(find.text('Trouver ma diététicienne'), findsOneWidget);
      expect(find.text('Estelle Mbarga'), findsOneWidget);
      await _dispose(t);
    },
  );

  testWidgets('le choix de langue change toute l\'interface', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(780, 1688);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);

    router.go(
      '/onboarding/1',
    ); // le routeur est global : on repart de l'accueil
    await t.pumpWidget(const ProviderScope(child: TchihaliApp()));
    await settle(t);
    await t.tap(find.text('EN'));
    await settle(t);
    expect(find.textContaining('Eat well'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    await _dispose(t);
  });
}
