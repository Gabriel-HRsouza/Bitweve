import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bitweve/features/hub/player_status_bar.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/audio_service.dart';
import 'core/router/app_router.dart';
import 'core/settings/game_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/game_palette.dart';
import 'shared/ui/motion.dart';
import 'shared/ui/notification_host.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
  await AudioService().init();
  GameSheet.statusBuilder = () => const PlayerStatusBar();
  runApp(const ProviderScope(child: BitWeveApp()));
}

class BitWeveApp extends ConsumerWidget {
  const BitWeveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final dark = AppTheme.darkTheme();
    final light = AppTheme.lightTheme();
    return MaterialApp.router(
      key: ValueKey(settings.language),
      title: 'BitWeve',
      debugShowCheckedModeBanner: false,
      theme: settings.highContrast ? _contrast(light, GamePalette.light) : light,
      darkTheme: settings.highContrast ? _contrast(dark, GamePalette.dark) : dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: settings.motionOn ? const Duration(milliseconds: 300) : Duration.zero,
      routerConfig: appRouter,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: MotionScope(
            enabled: settings.motionOn,
            child: NotificationHost(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }

  /// Alto contraste: textos secundários mais fortes e bordas mais visíveis.
  ThemeData _contrast(ThemeData t, GamePalette p) {
    final hc = p.copyWith(
      textDim: p.text,
      textMuted: p.isDark ? const Color(0xFFD5D8F0) : const Color(0xFF2B2F52),
      border: p.isDark ? const Color(0xFF6B72B8) : const Color(0xFF8A90C0),
    );
    return t.copyWith(extensions: [hc]);
  }
}
