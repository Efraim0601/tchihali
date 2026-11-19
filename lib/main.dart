import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/locale_provider.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'data/auth_repository.dart';
import 'features/auth/signup_state.dart';
import 'l10n/gen/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final container = ProviderContainer();
  // Reprend la session enregistrée sur le téléphone (mode API) avant d'afficher le premier écran.
  final user = await container.read(authRepositoryProvider).restore();
  if (user != null) {
    container
        .read(signupProvider.notifier)
        .set(user.fullName, toLocalPhone(user.phone));
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const TchihaliApp()),
  );
}

class TchihaliApp extends ConsumerStatefulWidget {
  const TchihaliApp({super.key});

  @override
  ConsumerState<TchihaliApp> createState() => _TchihaliAppState();
}

class _TchihaliAppState extends ConsumerState<TchihaliApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(localeProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      theme: Tch.theme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
