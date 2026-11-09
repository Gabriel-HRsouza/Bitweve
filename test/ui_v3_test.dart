import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/features/dating/presentation/dating_app_sheet.dart';
import 'package:bitweve/features/hub/player_status_bar.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/minigames/games/bluff_game.dart';
import 'package:bitweve/features/minigames/games/maze_game.dart';
import 'package:bitweve/features/minigames/games/runner_game.dart';
import 'package:bitweve/features/minigames/games/safe_game.dart';
import 'package:bitweve/features/minigames/games/sequence_game.dart';
import 'package:bitweve/features/parties/presentation/party_planner_sheet.dart';
import 'package:bitweve/features/properties/presentation/properties_sheet.dart';
import 'package:bitweve/features/relationships/presentation/person_profile_sheet.dart';
import 'package:bitweve/features/relationships/presentation/relationships_sheet.dart';
import 'package:bitweve/features/school/presentation/school_sheet.dart';
import 'package:bitweve/features/social_media/presentation/social_app_sheet.dart';
import 'package:bitweve/features/underworld/presentation/justice_sheets.dart';
import 'package:bitweve/features/underworld/presentation/underworld_sheet.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

/// Renderiza cada tela nova em tamanhos de celular, tablet e desktop para
/// detectar erros de layout (overflow) e exceções em tempo de execução.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GameSheet.statusBuilder = () => const PlayerStatusBar();

  late ProviderContainer container;
  late AppDatabase db;

  Future<void> boot(WidgetTester tester, int age) async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [databaseServiceProvider.overrideWithValue(DatabaseService(database: db))]);
    await tester.runAsync(() async {
      final n = container.read(lifeEngineProvider.notifier);
      // aguarda o carregamento inicial
      for (var i = 0; i < 50 && container.read(lifeEngineProvider).isLoading; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      await n.startRandomLife();
      var s = container.read(lifeEngineProvider).value!;
      while (s.character.currentAge < age) {
        s = (await n.advanceYear())!;
        while (s.pendingEvents.isNotEmpty) {
          s = (await n.chooseEvent(0))!;
        }
        // mantém o personagem vivo e saudável
        n.state = AsyncValue.data(s.copyWith(character: s.character.copyWith(health: 95, smarts: 85, bankBalance: 2000000)));
        s = container.read(lifeEngineProvider).value!;
      }
    });
  }

  Future<void> show(WidgetTester tester, Widget sheet, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        home: MotionScope(enabled: false, child: Scaffold(body: sheet)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  const sizes = {'celular': Size(390, 844), 'tablet': Size(820, 1180), 'desktop': Size(1440, 900)};

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('telas da vida escolar, social e submundo renderizam em todos os tamanhos', (tester) async {
    await boot(tester, 15);
    final s = container.read(lifeEngineProvider).value!;
    final someone = s.npcs.firstWhere((n) => n.isAlive);
    final sheets = <String, Widget>{
      'escola': const SchoolSheet(),
      'relações': const RelationshipsSheet(initialTab: 1),
      'perfil': PersonProfileSheet(npcId: someone.id),
      'pulso': const SocialAppSheet(),
      'festa': const PartyPlannerSheet(),
      'submundo': const UnderworldSheet(),
      'tribunal': const TrialSheet(),
      'prisão': const PrisonSheet(),
    };
    for (final size in sizes.entries) {
      for (final e in sheets.entries) {
        await show(tester, e.value, size.value);
        expect(tester.takeException(), isNull, reason: '${e.key} @ ${size.key}');
      }
    }
    // Abas internas da escola e do submundo
    await show(tester, const SchoolSheet(), sizes['celular']!);
    for (final tab in ['Atividades', 'Colegas', 'Professores']) {
      await tester.ensureVisible(find.text(tab));
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'escola/$tab');
    }
    await show(tester, const UnderworldSheet(), sizes['celular']!);
    for (final tab in ['Lojas (1.000)', 'Organizações', 'Ficha & Justiça']) {
      await tester.ensureVisible(find.text(tab));
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'submundo/$tab');
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('faculdade, namoro e imóveis (adulto) renderizam', (tester) async {
    await boot(tester, 19);
    await tester.runAsync(() async {
      final n = container.read(lifeEngineProvider.notifier);
      await n.act((v, st) => v.enroll(st, 'business', 'cash', 'ead_conecta'));
      await n.act((v, st) => v.buyPropertyListing(st, 'p_house', false));
      await n.act((v, st) => v.datingProfile(st, 'Oi!', ['music', 'travel'], 'serious', 18, 30));
    });
    final sheets = <String, Widget>{
      'faculdade': const SchoolSheet(),
      'faísca': const DatingAppSheet(),
      'imóveis': const PropertiesSheet(),
    };
    for (final size in sizes.entries) {
      for (final e in sheets.entries) {
        await show(tester, e.value, size.value);
        expect(tester.takeException(), isNull, reason: '${e.key} @ ${size.key}');
      }
    }
    final st = container.read(lifeEngineProvider).value!;
    expect(st.extras.education.inHigherEd, isTrue, reason: 'matrícula no EAD deve ser aprovada (entrada fácil)');
    await show(tester, const SchoolSheet(), sizes['celular']!);
    for (final tab in ['Atividades', 'Colegas', 'Carreira']) {
      await tester.ensureVisible(find.text(tab));
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'faculdade/$tab');
    }
    await show(tester, const DatingAppSheet(), sizes['celular']!);
    for (final tab in ['Perfil']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: 'faísca/$tab');
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('minigames rodam, respondem a controles e terminam', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final games = <String, Widget Function(void Function(bool, double, int))>{
      'labirinto': (f) => MazeGame(difficulty: 3, seed: 1, onFinish: f),
      'lábia': (f) => BluffGame(difficulty: 2, seed: 1, onFinish: f),
      'cofre': (f) => SafeGame(difficulty: 2, seed: 1, onFinish: f),
      'memória': (f) => SequenceGame(difficulty: 2, seed: 1, onFinish: f),
      'fuga': (f) => RunnerGame(difficulty: 2, seed: 1, onFinish: f),
    };
    for (final g in games.entries) {
      bool? done;
      double perf = -1;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme(),
        home: Scaffold(body: g.value((ok, p, _) {
          done = ok;
          perf = p;
        })),
      ));
      // interage: toques e setas
      for (var i = 0; i < 30 && done == null; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        final pads = find.byType(GestureDetector);
        if (pads.evaluate().isNotEmpty) await tester.tap(pads.last, warnIfMissed: false);
      }
      // deixa o tempo esgotar
      for (var i = 0; i < 400 && done == null; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        final pads = find.byType(GestureDetector);
        if (i % 3 == 0 && pads.evaluate().isNotEmpty) await tester.tap(pads.last, warnIfMissed: false);
      }
      expect(done, isNotNull, reason: '${g.key} deveria terminar');
      expect(perf, inInclusiveRange(0, 1), reason: g.key);
      expect(tester.takeException(), isNull, reason: g.key);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
