import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/tch_bottom_nav.dart';
import '../data/api/api_config.dart';
import 'auth_gate.dart';
import '../features/auth/auth_screens.dart';
import '../features/questionnaire/questionnaire_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/directory/directory_screen.dart';
import '../features/payment/payment_screen.dart';
import '../features/pro/pro_agenda_screen.dart';
import '../features/pro/pro_chat.dart';
import '../features/pro/pro_lists.dart';
import '../features/pro/pro_patient_screen.dart';
import '../features/pro/pro_report_screen.dart';
import '../features/pro/pro_shell.dart';
import '../features/video/call_screen.dart';
import '../features/video/waiting_room_screen.dart';
import '../features/home/home_screen.dart';
import '../data/recipes.dart';
import '../features/journal/add_meal_screen.dart';
import '../features/legal/legal_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/messages/messages_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/recipes/recipe_detail_screen.dart';
import '../features/recipes/recipes_screen.dart';
import '../features/record/record_screen.dart';
import '../features/profile/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/onboarding/onboarding_screens.dart';

/// Mode API : il faut être connecté (sauf onboarding / inscription) ; l'espace praticien
/// est réservé au rôle « dietitian ». En mode démo, tout est accessible.
String? _guard(BuildContext context, GoRouterState state) {
  if (!ApiConfig.isConfigured) return null;
  final loc = state.uri.path;
  final isPublic =
      loc.startsWith('/onboarding') ||
      loc.startsWith('/signup') ||
      loc.startsWith('/legal');
  if (!authGate.signedIn) return isPublic ? null : '/onboarding/1';
  // Un diététicien n'utilise que l'espace praticien ; un patient n'y accède pas.
  if (authGate.role == 'dietitian') {
    return loc.startsWith('/pro') ? null : '/pro/agenda';
  }
  if (loc.startsWith('/onboarding')) return '/home';
  if (loc.startsWith('/pro')) return '/home';
  return null;
}

final router = GoRouter(
  initialLocation: '/onboarding/1',
  refreshListenable: authGate,
  redirect: _guard,
  routes: [
    GoRoute(path: '/onboarding/1', builder: (_, _) => const WelcomeScreen()),
    GoRoute(
      path: '/onboarding/2',
      builder: (_, _) => const Onboarding2Screen(),
    ),
    GoRoute(
      path: '/onboarding/3',
      builder: (_, _) => const Onboarding3Screen(),
    ),
    GoRoute(
      path: '/legal/terms',
      builder: (_, _) => const LegalScreen(kind: LegalKind.terms),
    ),
    GoRoute(
      path: '/legal/privacy',
      builder: (_, _) => const LegalScreen(kind: LegalKind.privacy),
    ),
    GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
    GoRoute(path: '/signup/code', builder: (_, _) => const SmsCodeScreen()),
    GoRoute(path: '/questionnaire', redirect: (_, _) => '/questionnaire/1'),
    GoRoute(
      path: '/questionnaire/:step',
      builder: (_, state) => QuestionnaireScreen(
        step: (int.tryParse(state.pathParameters['step'] ?? '') ?? 1).clamp(
          1,
          3,
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Scaffold(
        body: shell,
        bottomNavigationBar: TchBottomNav(
          currentIndex: shell.currentIndex,
          onTap: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/directory',
              builder: (_, _) => const DirectoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journal',
              builder: (_, _) => const JournalScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, state) =>
                      AddMealScreen(recipe: state.extra as Recipe?),
                ),
                GoRoute(
                  path: 'recipes',
                  builder: (_, _) => const RecipesScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (_, _) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'progress',
                  builder: (_, _) => const ProgressScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (_, _) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'record',
                  builder: (_, _) => const RecordScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/journal/recipes/:id',
      builder: (_, state) =>
          RecipeDetailScreen(id: state.pathParameters['id']!),
    ),
    // Espace praticien (tablette / web) : menu latéral commun.
    ShellRoute(
      builder: (_, state, child) =>
          ProShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: '/pro/agenda',
          builder: (_, _) => const ProAgendaScreen(),
        ),
        GoRoute(
          path: '/pro/patients',
          builder: (_, _) => const ProPatientsScreen(forReports: false),
        ),
        GoRoute(
          path: '/pro/reports',
          builder: (_, _) => const ProPatientsScreen(forReports: true),
        ),
        GoRoute(
          path: '/pro/messages',
          builder: (_, _) => const ProConversationsScreen(),
        ),
        GoRoute(
          path: '/pro/messages/:id',
          builder: (_, state) =>
              ProChatScreen(patientId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/pro/patients/:id',
          builder: (_, state) =>
              ProPatientScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/pro/reports/:id',
          builder: (_, state) =>
              ProReportScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(path: '/booking', builder: (_, _) => const BookingScreen()),
    GoRoute(path: '/booking/payment', builder: (_, _) => const PaymentScreen()),
    GoRoute(
      path: '/video/waiting',
      builder: (_, _) => const WaitingRoomScreen(),
    ),
    GoRoute(path: '/video/call', builder: (_, _) => const CallScreen()),
  ],
);
