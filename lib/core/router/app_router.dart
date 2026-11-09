import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/character/presentation/screens/create_character_screen.dart';
import '../../features/life_engine/presentation/screens/death_screen.dart';
import '../../features/life_engine/presentation/screens/life_screen.dart';
import '../../features/onboarding/presentation/screens/main_menu_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/saves_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/ui/motion.dart';

/// Transição de página: fade + leve deslize/escala (desligada com movimento reduzido).
CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondary, child) {
      if (!context.motion) return child;
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: ScaleTransition(scale: Tween(begin: 0.985, end: 1.0).animate(curved), child: child),
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _page(s, const SplashScreen())),
    GoRoute(path: '/main_menu', pageBuilder: (c, s) => _page(s, const MainMenuScreen())),
    GoRoute(path: '/create_character', pageBuilder: (c, s) => _page(s, const CreateCharacterScreen())),
    GoRoute(path: '/game', pageBuilder: (c, s) => _page(s, const LifeScreen())),
    GoRoute(path: '/death', pageBuilder: (c, s) => _page(s, const DeathScreen())),
    GoRoute(path: '/saves', pageBuilder: (c, s) => _page(s, const SavesScreen())),
    GoRoute(path: '/settings', pageBuilder: (c, s) => _page(s, const SettingsScreen())),
  ],
);
