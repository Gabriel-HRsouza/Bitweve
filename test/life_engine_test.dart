import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';
import 'package:bitweve/features/progression/data/progression_catalog.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService dbService;
  late LifeEngineService engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService(database: db);
    engine = LifeEngineService(databaseService: dbService, rng: Random(42));
    await engine.initDatasets();
  });

  tearDown(() async => db.close());

  LifeEngineState withMoney(LifeEngineState s, double v) => s.copyWith(character: s.character.copyWith(bankBalance: v));

  Future<LifeEngineState> ageTo(LifeEngineState s, int age) async {
    while (s.character.currentAge < age && s.character.isAlive) {
      s = await engine.advanceYear(s);
      // resolve eventos pendentes sempre com a 1ª escolha
      while (s.pendingEvents.isNotEmpty) {
        s = await engine.chooseEvent(s, 0);
      }
      // mantém o personagem saudável para o teste não morrer por acaso
      s = s.copyWith(character: s.character.copyWith(health: 95, smarts: 90, discipline: 90, stress: 5));
    }
    return s;
  }

  group('Criação e persistência', () {
    test('cria vida personalizada com família, traços e aparência', () async {
      final avatar = AvatarConfig.random(gender: 'female').copyWith(outfit: OutfitStyle.executive, bodyType: BodyType.athletic);
      final s = await engine.createLife(CharacterSetup(
        firstName: 'Ana',
        lastName: 'Lima',
        gender: 'female',
        birthDay: 12,
        birthMonth: 6,
        birthYear: 2026,
        countryId: 'br',
        familyWealth: 'rich',
        siblings: 2,
        personality: 'analytical',
        traits: const ['memory'],
        avatar: avatar,
      ));
      expect(s.character.fullName, 'Ana Lima');
      expect(s.character.country, 'Brasil');
      expect(s.npcs.where((n) => n.isParent).length, 2);
      expect(s.npcs.where((n) => n.isSibling).length, 2);
      expect(s.extras.familyWealth, 'rich');
      expect(s.extras.birthDay, 12);
      expect(s.character.avatarConfig.outfit, OutfitStyle.executive);

      final loaded = await dbService.loadFullLifeData(s.saveId);
      expect(loaded, isNotNull);
      expect(loaded!.extras.traits, contains('memory'));
      expect(loaded.character.avatarConfig.bodyType, BodyType.athletic);
    });

    test('veículos, cripto, empresas e saúde persistem após recarregar (bug da v1.0)', () async {
      var s = withMoney(await engine.createRandomLife(countryId: 'br'), 3000000);
      s = await ageTo(s, 18);
      s = withMoney(s.copyWith(character: s.character.copyWith(hasDriversLicense: true)), 3000000);
      s = await engine.buyVehicleListing(s, 'v_hatch');
      s = await engine.buyCrypto(s, 'BTC', 5000);
      s = await engine.startBusiness(s, 'BitWeve Labs', 'tech_startup');
      s = await engine.toggleHealthInsurance(s);
      expect(s.extras.vehicles, hasLength(1));

      final loaded = await dbService.loadFullLifeData(s.saveId);
      expect(loaded!.extras.vehicles, hasLength(1));
      expect(loaded.extras.crypto.firstWhere((c) => c.symbol == 'BTC').ownedUnits, greaterThan(0));
      expect(loaded.extras.businesses, hasLength(1));
      expect(loaded.extras.hasInsurance, isTrue);
    });

    test('excluir vida remove todos os dados', () async {
      final s = await engine.createRandomLife();
      await dbService.deleteSave(s.saveId);
      expect(await dbService.loadFullLifeData(s.saveId), isNull);
      expect(await dbService.getSaveSummaries(), isEmpty);
    });
  });

  group('Passagem de anos', () {
    test('cada aniversário gera mensagem obrigatória e resumo anual', () async {
      var s = await engine.createRandomLife();
      s = await engine.advanceYear(s);
      expect(s.character.currentAge, 1);
      expect(s.lastYearSummary, isNotNull);
      expect(s.lastYearSummary!.headline, 'Você completou 1 ano!');
      expect(s.logs.any((l) => l.category == 'chronicle' && l.age == 1), isTrue);

      s = await ageTo(s, 17);
      s = await engine.advanceYear(s); // resumo é transitório: lido logo após o aniversário
      expect(s.lastYearSummary!.headline, 'Você completou 18 anos!');
      expect(s.lastYearSummary!.subtitle, contains('novo capítulo'));
    });

    test('NPCs envelhecem e a escola progride até a formatura', () async {
      var s = await engine.createRandomLife();
      final father = s.npcs.firstWhere((n) => n.relationshipType == RelationshipType.father);
      s = await ageTo(s, 10);
      expect(s.extras.education.stage, 'elementary');
      final f = s.npcs.firstWhere((n) => n.id == father.id);
      expect(f.age, father.age + 10);

      s = await ageTo(s, 22);
      expect(s.extras.education.hasHighSchool, isTrue);
      expect(s.character.educationLevel, 'high_school');
    });

    test('ações têm limite anual e energia', () async {
      var s = await ageTo(await engine.createRandomLife(), 14);
      for (var i = 0; i < 6; i++) {
        s = await engine.studyExtra(s);
      }
      expect(s.extras.actionsThisYear['study'], 4);
      expect(s.notices.any((n) => n.kind == NoticeKind.warning), isTrue);
    });
  });

  group('Eventos', () {
    test('escolha aplica efeitos reais e registra resultado', () async {
      var s = withMoney(await engine.createRandomLife(), 1000);
      const ev = LifeEvent(
        id: 'test_ev',
        category: 'financeiro',
        minAge: 0,
        maxAge: 100,
        title: 'Teste',
        description: 'Evento de teste',
        choices: [
          EventChoice(label: 'Ganhar', resultText: 'Ganhou!', effects: {'money': 500, 'followers': 1000, 'addNpc': 'friend'}),
        ],
      );
      s = s.copyWith(pendingEvents: const [PendingEvent(ev)]);
      final npcsBefore = s.npcs.length;
      s = await engine.chooseEvent(s, 0);
      expect(s.character.bankBalance, 1500);
      expect(s.extras.followers, 1000);
      expect(s.npcs.length, npcsBefore + 1);
      expect(s.pendingEvents, isEmpty);
      expect(s.lastOutcome!.deltas['money'], 500);
    });

    test('envelhecer sorteia eventos compatíveis com a idade', () async {
      var s = await engine.createRandomLife();
      var seen = 0;
      for (var i = 0; i < 30; i++) {
        s = await engine.advanceYear(s);
        for (final p in s.pendingEvents) {
          expect(s.character.currentAge, inInclusiveRange(p.event.minAge, p.event.maxAge));
          seen++;
        }
        while (s.pendingEvents.isNotEmpty) {
          s = await engine.chooseEvent(s, 0);
        }
        s = s.copyWith(character: s.character.copyWith(health: 95));
      }
      expect(seen, greaterThan(5));
    });
  });

  group('Carreira e educação', () {
    test('contratação, salário anual, demissão real', () async {
      var s = await ageTo(await engine.createRandomLife(), 18);
      s = s.copyWith(character: s.character.copyWith(educationLevel: 'high_school', smarts: 80, charisma: 70));
      s.extras.education.completedDegrees.add('high_school');
      s = await engine.applyForJob(s, 'adm_office', interviewBonus: 1);
      expect(s.character.currentJobId, 'adm_office');
      expect(s.character.currentJobTitle, 'Assistente Administrativo');
      expect(s.extras.jobHistory, hasLength(1));

      final before = s.character.bankBalance;
      s = await engine.advanceYear(s);
      expect(s.extras.counter('salariesReceived'), 1);
      expect(s.character.bankBalance, greaterThan(before - 20000));

      if (s.character.currentJobTitle != null) {
        s = await engine.quitJob(s);
        expect(s.character.currentJobTitle, isNull);
        expect(s.character.currentSalary, isNull);
      }
    });

    test('requisitos bloqueiam vaga sem diploma', () async {
      var s = await ageTo(await engine.createRandomLife(), 18);
      s = await engine.applyForJob(s, 'med_doctor', interviewBonus: 1);
      expect(s.character.currentJobId, isNot('med_doctor'));
      expect(s.notices.first.kind, NoticeKind.warning);
    });

    test('faculdade com financiamento estudantil e formatura', () async {
      var s = await ageTo(await engine.createRandomLife(), 18);
      s = s.copyWith(character: s.character.copyWith(smarts: 95, educationLevel: 'high_school'));
      if (!s.extras.education.hasHighSchool) s.extras.education.completedDegrees.add('high_school');
      s.extras.education.stage = 'hs_graduate';
      for (var i = 0; i < 2 && !s.extras.education.inHigherEd; i++) {
        s = await engine.enroll(s, 'business', 'loan');
      }
      expect(s.extras.education.degreeId, 'business');
      // Com notas altas pode vir bolsa integral; senão, o curso é financiado.
      expect(s.extras.loans.isNotEmpty || s.extras.education.scholarshipPct == 1.0, isTrue);
      s = await ageTo(s, 24);
      expect(s.extras.education.completedDegrees, contains('business'));
      expect(s.character.educationLevel, 'college');
    });

    test('curso de autoescola libera carteira de motorista', () async {
      var s = withMoney(await ageTo(await engine.createRandomLife(), 18), 10000);
      s = await engine.takeCourse(s, 'driving');
      expect(s.character.hasDriversLicense, isTrue);
    });
  });

  group('Finanças, compras e relacionamentos', () {
    test('compra de item altera saldo, inventário e atributos', () async {
      var s = withMoney(await ageTo(await engine.createRandomLife(), 12), 20000);
      s = await engine.buyItem(s, 'ph_pro');
      expect(s.character.bankBalance, 20000 - 9500);
      expect(s.extras.inventory.single.itemId, 'ph_pro');
      s = await engine.sellItem(s, s.extras.inventory.single.id);
      expect(s.extras.inventory, isEmpty);
      expect(s.character.bankBalance, greaterThan(20000 - 9500));
    });

    test('compra de imóvel e patrimônio líquido', () async {
      var s = withMoney(await ageTo(await engine.createRandomLife(), 18), 1000000);
      final before = s.netWorth;
      s = await engine.buyPropertyListing(s, 'p_apartment', false);
      expect(s.properties, hasLength(1));
      // patrimônio preservado (+ recompensas de conquistas desbloqueadas na compra)
      expect(s.netWorth, greaterThanOrEqualTo(before - 1));
      expect(await dbService.unlockedAchievements(), contains('homeowner'));
      expect(s.extras.homePropertyId, s.properties.single.id);
    });

    test('empréstimo entra no saldo e no patrimônio negativo', () async {
      var s = await ageTo(await engine.createRandomLife(), 18);
      s = s.copyWith(character: s.character.copyWith(creditScore: 750, currentSalary: 60000, currentJobTitle: 'Teste'));
      final nw = s.netWorth;
      s = await engine.takeLoan(s, 5000);
      expect(s.extras.loans, hasLength(1));
      expect(s.netWorth, closeTo(nw, 1));
      s = await engine.payLoan(s, s.extras.loans.single.id, 5000);
      expect(s.extras.loans, isEmpty);
    });

    test('investimento rende com o tempo', () async {
      var s = withMoney(await ageTo(await engine.createRandomLife(), 18), 50000);
      s = await engine.investMoney(s, 'fixed_income', 'Tesouro Selic', 'SELIC', 10000);
      expect(s.character.bankBalance, 40000);
      s = await engine.advanceYear(s);
      expect(s.investments.single.currentValue, greaterThan(10000));
    });

    test('interação muda relacionamento e registra memória', () async {
      var s = await ageTo(await engine.createRandomLife(), 8);
      final mom = s.npcs.firstWhere((n) => n.relationshipType == RelationshipType.mother);
      s = s.copyWith(npcs: s.npcs.map((n) => n.id == mom.id ? n.copyWith(relationshipLevel: 50) : n).toList());
      s = await engine.interactWithNpc(s, mom.id, 'compliment');
      final after = s.npcs.firstWhere((n) => n.id == mom.id);
      // NPCs podem aceitar ou recusar conforme personalidade/humor: a relação muda nos dois casos
      expect(after.relationshipLevel, isNot(50));
      expect(after.memories, isNotEmpty);
      expect(s.extras.npcMeta[mom.id]?.history, isNotEmpty);
    });
  });

  group('Progressão e gerações', () {
    test('conquistas são desbloqueadas e salvas globalmente', () async {
      var s = await engine.createRandomLife();
      s = await engine.advanceYear(s);
      final unlocked = await dbService.unlockedAchievements();
      expect(unlocked, contains('first_steps'));
      expect(s.notices.any((n) => n.kind == NoticeKind.achievement), isTrue);
    });

    test('missões diárias acompanham contadores e pagam recompensa', () async {
      var s = await engine.createRandomLife();
      s = await engine.refreshDaily(s);
      expect(s.extras.daily!.missionIds, hasLength(3));
      // força uma missão conhecida
      s.extras.daily!.missionIds
        ..clear()
        ..add('d_age');
      s.extras.daily!.baselines['yearsLived'] = s.extras.counter('yearsLived');
      s = await engine.advanceYear(s);
      s = await engine.advanceYear(s);
      final before = s.character.bankBalance;
      s = await engine.claimDailyMission(s, 'd_age');
      expect(s.extras.daily!.claimed, contains('d_age'));
      expect(s.character.bankBalance, before + ProgressionCatalog.daily.first.rewardMoney);
    });

    test('herdeiro continua a dinastia com patrimônio e imóveis', () async {
      var s = withMoney(await ageTo(await engine.createRandomLife(), 18), 2000000);
      s = await engine.buyPropertyListing(s, 'p_house', false);
      final child = NpcModel(
        id: 'heir',
        saveId: s.saveId,
        firstName: 'Arthur',
        lastName: s.character.lastName,
        gender: 'male',
        age: 20,
        relationshipType: RelationshipType.son,
        avatarConfig: AvatarConfig.random(gender: 'male'),
      );
      s = s.copyWith(npcs: [...s.npcs, child], character: s.character.copyWith(isAlive: false, ageOfDeath: 18));
      final next = await engine.continueAsHeir(s, 'heir');
      expect(next.generation, 2);
      expect(next.character.firstName, 'Arthur');
      expect(next.properties, hasLength(1));
      expect(next.character.bankBalance, greaterThan(1000000));
      expect(next.extras.ancestors.single.name, s.character.fullName);
      expect(next.npcs.any((n) => !n.isAlive && n.isParent), isTrue);
    });

    test('reiniciar vida recomeça do nascimento com a mesma identidade', () async {
      var s = await ageTo(await engine.createRandomLife(firstName: 'Bia', lastName: 'Rocha', gender: 'female'), 5);
      final old = s.saveId;
      s = await engine.restartLife(s);
      expect(s.character.currentAge, 0);
      expect(s.character.fullName, 'Bia Rocha');
      expect(await dbService.loadFullLifeData(old), isNull);
    });

    test('modo deus continua funcionando', () async {
      var s = await engine.createRandomLife();
      s = await engine.godModeAddMoney(s, 1000000);
      expect(s.character.bankBalance, greaterThanOrEqualTo(1000000));
      s = await engine.godModeCureAll(s);
      expect(s.character.health, 100);
    });
  });
}
