import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';
import 'package:bitweve/features/life_engine/systems/dating_system.dart';
import 'package:bitweve/features/life_engine/systems/relationship_system.dart';
import 'package:bitweve/features/parties/data/party_catalog.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/romance_rules.dart';
import 'package:bitweve/features/underworld/data/store_catalog.dart';
import 'package:bitweve/features/underworld/models/minigame_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService dbService;
  late LifeEngineService engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService(database: db);
    engine = LifeEngineService(databaseService: dbService, rng: Random(7));
    await engine.initDatasets();
  });

  tearDown(() async => db.close());

  LifeEngineState healthy(LifeEngineState s) => s.copyWith(
      character: s.character.copyWith(health: 95, smarts: 80, discipline: 80, stress: 5, energy: 100, charisma: 70, looks: 70));

  Future<LifeEngineState> ageTo(LifeEngineState s, int age) async {
    while (s.character.currentAge < age && s.character.isAlive) {
      s = await engine.advanceYear(s);
      while (s.pendingEvents.isNotEmpty) {
        s = await engine.chooseEvent(s, 0);
      }
      s = healthy(s);
    }
    return s;
  }

  Future<LifeEngineState> reload(LifeEngineState s) async {
    final data = await dbService.loadFullLifeData(s.saveId);
    return LifeEngineState(
      saveId: data!.save.id,
      slotName: data.save.slotName,
      character: data.character,
      npcs: data.npcs,
      properties: data.properties,
      investments: data.investments,
      logs: data.logs,
      extras: data.extras,
    );
  }

  group('Catálogo de lojas', () {
    test('gera 1000 lojas com nomes únicos e todas as categorias', () {
      final all = StoreCatalog.all;
      expect(all.length, 1000);
      expect(all.map((s) => s.name).toSet().length, 1000);
      expect(all.map((s) => s.category.id).toSet().length, StoreCatalog.categories.length);
      expect(StoreCatalog.byId('st_999')!.index, 999);
      expect(all.every((s) => s.difficulty >= 1 && s.difficulty <= 5 && s.lootValue > 0), isTrue);
    });
  });

  group('Regras de romance', () {
    test('adultos só com adultos, adolescentes só com idade próxima', () {
      expect(RomanceRules.romanceAllowed(25, 30), isTrue);
      expect(RomanceRules.romanceAllowed(16, 15), isTrue);
      expect(RomanceRules.romanceAllowed(16, 19), isFalse);
      expect(RomanceRules.romanceAllowed(14, 26), isFalse);
      expect(RomanceRules.romanceAllowed(12, 12), isFalse);
      expect(RomanceRules.intimacyAllowed(17, 17), isFalse);
      expect(RomanceRules.intimacyAllowed(18, 30), isTrue);
    });

    test('menores não recebem opções de flerte com adultos nem intimidade', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 15);
      final adult = s.npcs.first.copyWith(id: 'adult', age: 30, relationshipType: RelationshipType.friend);
      final actions = RelationshipSystem.actionsFor(adult, 15).map((a) => a.id).toList();
      expect(actions, isNot(contains('flirt')));
      expect(actions, isNot(contains('intimacy')));
      final partner = adult.copyWith(age: 15, relationshipType: RelationshipType.partner);
      expect(RelationshipSystem.actionsFor(partner, 15).map((a) => a.id), isNot(contains('intimacy')));
    });
  });

  group('Escola', () {
    test('escola cria turma, professores e persiste ações', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 8);
      expect(s.extras.education.inSchool, isTrue);
      expect(s.extras.school.schoolName, isNotEmpty);
      expect(s.npcs.where((n) => n.relationshipType == RelationshipType.classmate).length, greaterThanOrEqualTo(7));
      expect(s.npcs.where((n) => n.relationshipType == RelationshipType.teacher).length, greaterThanOrEqualTo(3));

      final before = s.extras.school.performance;
      s = await engine.attendClass(s);
      expect(s.extras.school.performance, greaterThan(before));
      s = await engine.takeExam(s, 1.0);
      expect(s.extras.school.examsThisYear, 1);
      s = await engine.joinClub(s, 'chess');
      expect(s.extras.school.clubs, contains('chess'));

      final loaded = await reload(s);
      expect(loaded.extras.school.clubs, contains('chess'));
      expect(loaded.extras.school.examsThisYear, 1);
    });

    test('três advertências geram suspensão', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 10);
      s = s.copyWith(extras: s.extras..school.warnings = 2);
      // força ser pego: carisma 0
      s = s.copyWith(character: s.character.copyWith(charisma: 0));
      for (var i = 0; i < 3 && !s.extras.school.suspended; i++) {
        s = await engine.misbehave(s);
      }
      expect(s.extras.school.warnings, greaterThanOrEqualTo(2));
    });
  });

  group('Submundo e justiça', () {
    test('crime bem-sucedido em loja gera estoque e falha pode levar a julgamento', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 18);
      final (ok, rep) = await engine.commitCrime(s, 'shoplift', const MinigameResult(success: true, performance: 1), storeId: 'st_5');
      expect(rep.title, isNotEmpty);
      expect(ok.extras.crime.successes + ok.extras.crime.failures, 1);
      s = ok;
      // Força uma prisão e julgamento
      var guard = 0;
      while (s.extras.crime.pendingCase == null && guard++ < 30) {
        s = s.copyWith(extras: s.extras..actionsThisYear.clear()..crime.heat = 100, character: s.character.copyWith(energy: 100));
        final (next, _) = await engine.commitCrime(s, 'pickpocket', const MinigameResult(success: false, performance: 0));
        s = next;
      }
      expect(s.extras.crime.pendingCase, isNotNull);
      expect(s.character.criminalRecord, isTrue);
      final (judged, verdict) = await engine.trial(s, 'public', 'guilty');
      expect(verdict, isNotEmpty);
      expect(judged.extras.crime.pendingCase, isNull);
      expect(judged.extras.crime.record, isNotEmpty);
    });

    test('prisão: pena é cumprida com a passagem dos anos', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 20);
      s = s.copyWith(extras: s.extras..crime.inPrison = true..crime.sentence = 2..crime.served = 0..crime.prisonName = 'Teste');
      s = await engine.prisonAction(s, 'work');
      expect(s.extras.crime.prisonSavings, greaterThan(0));
      s = await ageTo(s, 22);
      expect(s.extras.crime.inPrison, isFalse);
    });
  });

  group('Rede social, namoro e festas', () {
    test('posts geram curtidas, seguidores e persistem', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 16);
      s = await engine.createSocialAccount(s, 'teste.bw');
      expect(s.extras.social.hasAccount, isTrue);
      s = await engine.publishPost(s, 'photos', 0, 'Minha primeira foto');
      expect(s.extras.social.posts.length, 1);
      final loaded = await reload(s);
      expect(loaded.extras.social.posts.first.caption, 'Minha primeira foto');
      s = await engine.deletePost(loaded, loaded.extras.social.posts.first.id);
      expect(s.extras.social.posts, isEmpty);
    });

    test('app de namoro exige 18+ e gera perfis adultos', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 17);
      s = await engine.datingProfile(s, 'Oi', ['music'], 'serious', 18, 30);
      expect(s.extras.dating.hasProfile, isFalse);
      s = await ageTo(s, 22);
      s = await engine.datingProfile(s, 'Oi', ['music', 'travel'], 'serious', 18, 30);
      expect(s.extras.dating.hasProfile, isTrue);
      final deck = DatingSystem.deck(s);
      expect(deck, isNotEmpty);
      expect(deck.every((p) => p.age >= 18), isTrue);
      var matches = 0;
      for (final p in deck.take(10)) {
        final (next, m) = await engine.datingLike(s, p.id);
        s = next;
        if (m) matches++;
      }
      expect(s.extras.dating.swiped.length, greaterThanOrEqualTo(10));
      expect(s.extras.dating.matches.length, matches);
    });

    test('festa cobra custo e altera relação dos convidados', () async {
      var s = await engine.createRandomLife();
      s = await ageTo(s, 20);
      s = s.copyWith(character: s.character.copyWith(bankBalance: 50000));
      final guests = s.npcs.where((n) => n.isAlive).take(3).map((n) => n.id).toList();
      final (out, rep) = await engine.hostParty(
          s, PartyPlan(typeId: 'friends', guestIds: guests, budget: 1, decor: 'balloons', food: 'pizza', music: 'playlist', activity: 'games'));
      expect(rep.guests.length, guests.length);
      expect(out.character.bankBalance, lessThan(50000));
    });
  });
}
