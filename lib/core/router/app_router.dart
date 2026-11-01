import 'package:go_router/go_router.dart';
import '../../features/character/presentation/screens/create_character_screen.dart';
import '../../features/life_engine/presentation/screens/death_screen.dart';
import '../../features/life_engine/presentation/screens/life_screen.dart';
import '../../features/onboarding/presentation/screens/main_menu_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/saves_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/main_menu',
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/create_character',
      builder: (context, state) => const CreateCharacterScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const LifeScreen(),
    ),
    GoRoute(
      path: '/death',
      builder: (context, state) => const DeathScreen(),
    ),
    GoRoute(
      path: '/saves',
      builder: (context, state) => const SavesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
