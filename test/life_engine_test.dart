import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/careers/models/career_model.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/life_engine/services/life_engine_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService dbService;
  late LifeEngineService engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService(database: db);
    engine = LifeEngineService(databaseService: dbService);
  });

  tearDown(() async {
    await db.close();
  });

  group('BitWeve Life Engine Tests', () {
    test('Criar vida aleatória e verificar inicialização completa', () async {
      final state = await engine.createRandomLife(countryId: 'br');

      expect(state.character.currentAge, 0);
      expect(state.character.country, 'Brasil');
      expect(state.character.isAlive, true);
      expect(state.character.health, greaterThanOrEqualTo(80));
      expect(state.character.happiness, greaterThanOrEqualTo(80));
      expect(state.npcs.length, greaterThanOrEqualTo(2)); // Pai e mãe
      expect(state.logs.length, 1); // Log de nascimento

      // Verificar persistência no banco SQLite
      final currentSave = await dbService.getCurrentSave();
      expect(currentSave, isNotNull);
      expect(currentSave!.id, state.saveId);

      final loaded = await dbService.loadFullLifeData(state.saveId);
      expect(loaded, isNotNull);
      expect(loaded!.character.fullName, state.character.fullName);
    });

    test('Avançar idade por múltiplos anos e envelhecer NPCs', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      final initialFatherAge = state.npcs.firstWhere((n) => n.relationshipType == RelationshipType.father).age;

      // Avançar 10 anos
      for (int i = 0; i < 10; i++) {
        state = await engine.advanceYear(state);
      }

      expect(state.character.currentAge, 10);
      final newFatherAge = state.npcs.firstWhere((n) => n.relationshipType == RelationshipType.father).age;
      expect(newFatherAge, initialFatherAge + 10);
      expect(state.character.educationLevel, 'elementary'); // Aos 6 anos entrou na escola
    });

    test('Conseguir emprego e receber salário anual', () async {
      var state = await engine.createRandomLife(countryId: 'br');

      // Avançar até os 18 anos
      for (int i = 0; i < 18; i++) {
        state = await engine.advanceYear(state);
      }

      const job = CareerModel(
        id: 'job_dev_test',
        title: 'Programador Júnior',
        field: 'Tecnologia',
        minEducation: 'high_school',
        entrySalary: 60000.0,
        maxSalary: 90000.0,
        minSmarts: 20,
        stressLevel: 30,
      );

      state = await engine.applyForJob(state, job);
      expect(state.character.currentJobTitle, 'Programador Júnior');
      expect(state.character.currentSalary, 60000.0);

      final balanceBefore = state.character.bankBalance;
      state = await engine.advanceYear(state);

      // Salário com desconto de impostos deve ter entrado na conta
      expect(state.character.bankBalance, greaterThan(balanceBefore));
    });

    test('Comprar imóvel e calcular patrimônio líquido', () async {
      var state = await engine.createRandomLife(countryId: 'br');

      // Simular saldo financeiro
      final richChar = state.character.copyWith(bankBalance: 500000.0);
      state = state.copyWith(character: richChar);

      final apt = PropertyModel(
        id: 'apt_test',
        saveId: state.saveId,
        type: 'apartment',
        name: 'Apartamento de Luxo',
        purchasePrice: 300000.0,
        currentValue: 300000.0,
        annualCost: 5000.0,
        purchasedAtAge: 25,
      );

      state = await engine.buyProperty(state, apt, false);
      expect(state.properties.length, 1);
      expect(state.character.bankBalance, 200000.0);
      expect(state.netWorth, 500000.0);
    });

    test('Interagir com NPC (conversar, elogiar e presentear)', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      final mother = state.npcs.firstWhere((n) => n.relationshipType == RelationshipType.mother);
      final initialLevel = mother.relationshipLevel;

      state = await engine.interactWithNpc(state, mother.id, 'compliment');
      final updatedMother = state.npcs.firstWhere((n) => n.id == mother.id);

      expect(updatedMother.relationshipLevel, greaterThan(initialLevel));
    });

    test('Investir dinheiro e calcular rentabilidade', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      final fundedChar = state.character.copyWith(bankBalance: 50000.0);
      state = state.copyWith(character: fundedChar);

      state = await engine.investMoney(state, 'fixed_income', 'Tesouro Selic', 'SELIC', 10000.0);
      expect(state.investments.length, 1);
      expect(state.character.bankBalance, 40000.0);
      expect(state.investments.first.investedAmount, 10000.0);

      // Avançar ano e verificar rendimento
      state = await engine.advanceYear(state);
      expect(state.investments.first.currentValue, greaterThan(10000.0));
    });

    test('Continuar como herdeiro na próxima geração', () async {
      var state = await engine.createRandomLife(countryId: 'br');

      // Adicionar filho de 20 anos
      final child = NpcModel(
        id: 'child_heir_1',
        saveId: state.saveId,
        firstName: 'Arthur',
        lastName: state.character.lastName,
        gender: 'male',
        age: 20,
        relationshipType: RelationshipType.son,
        relationshipLevel: 100,
        avatarConfig: AvatarConfig.random(gender: 'male'),
      );

      state = state.copyWith(
        character: state.character.copyWith(bankBalance: 150000.0),
        npcs: [...state.npcs, child],
      );

      final dynastyState = await engine.continueAsHeir(state, child.id);
      expect(dynastyState.generation, 2);
      expect(dynastyState.character.firstName, 'Arthur');
      expect(dynastyState.slotName, contains('Arthur'));
      expect(dynastyState.logs.first.textContent, contains('150000.00'));
    });
  });

  group('BitWeve Ultimate Modules (Health, Crypto, Vehicles, Business, Crime, God Mode)', () {
    test('Sistema de Saúde & Diagnóstico - Consulta clínica, psicoterapia e farmacoterapia', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      state = state.copyWith(character: state.character.copyWith(bankBalance: 5000.0, health: 60, happiness: 50, stress: 50));

      // 1. Consulta Clínico Geral
      state = await engine.consultGeneralPractitioner(state);
      expect(state.character.health, greaterThan(60));

      // 2. Psicoterapia
      state = await engine.consultPsychologist(state);
      expect(state.character.happiness, greaterThan(50));
      expect(state.character.stress, lessThan(50));

      // 3. Convênio Privado
      expect(engine.hasHealthInsurance(state.saveId), false);
      state = await engine.toggleHealthInsurance(state);
      expect(engine.hasHealthInsurance(state.saveId), true);
    });

    test('Sistema de Criptomoedas - Carteira com BTC, compra e venda', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      state = state.copyWith(character: state.character.copyWith(bankBalance: 20000.0));

      final initialWallet = engine.getCryptoWallet(state.saveId);
      expect(initialWallet.length, 3); // BTC, ETH, BWV

      // Compra R$ 5.000 em Bitcoin
      state = await engine.buyCrypto(state, 'BTC', 5000.0);
      expect(state.character.bankBalance, 15000.0);
      final btcAsset = engine.getCryptoWallet(state.saveId).firstWhere((c) => c.symbol == 'BTC');
      expect(btcAsset.ownedUnits, greaterThan(0));

      // Venda R$ 2.000 de Bitcoin
      state = await engine.sellCrypto(state, 'BTC', 2000.0);
      expect(state.character.bankBalance, 17000.0);
    });

    test('Garagem & Veículos - Compra, revisão e revenda', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      state = state.copyWith(character: state.character.copyWith(bankBalance: 100000.0));

      const testCar = VehicleModel(
        id: 'car_test_1',
        name: 'Sedan Esportivo 2.0',
        category: VehicleCategory.sedan,
        year: 2024,
        purchasePrice: 60000.0,
        currentValue: 60000.0,
        conditionPercent: 80,
        mileageKm: 15000,
        annualMaintenance: 2000.0,
        annualInsurance: 3000.0,
      );

      // Compra do veículo
      state = await engine.buyVehicle(state, testCar);
      expect(state.character.bankBalance, 40000.0);
      final myVehicles = engine.getOwnedVehicles(state.saveId);
      expect(myVehicles.length, 1);
      final boughtId = myVehicles.first.id;

      // Manutenção preventiva
      state = await engine.serviceVehicle(state, boughtId);
      final servicedVehicles = engine.getOwnedVehicles(state.saveId);
      expect(servicedVehicles.first.conditionPercent, 100);

      // Revenda do veículo
      state = await engine.sellVehicle(state, boughtId);
      expect(engine.getOwnedVehicles(state.saveId).isEmpty, true);
      expect(state.character.bankBalance, greaterThan(40000.0));
    });

    test('Empreendedorismo & Startups - Fundação, contratação, marketing e exit', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      state = state.copyWith(character: state.character.copyWith(bankBalance: 100000.0));

      // Fundação de Startup
      state = await engine.startBusiness(state, 'BitWeve Tech', 'tech_startup');
      expect(state.character.bankBalance, 75000.0); // Custa 25k
      final myBusinesses = engine.getBusinesses(state.saveId);
      expect(myBusinesses.length, 1);
      final bizId = myBusinesses.first.id;
      final initialValuation = myBusinesses.first.valuation;

      // Contratar novos funcionários
      state = await engine.hireEmployees(state, bizId);
      final bizAfterHiring = engine.getBusinesses(state.saveId).first;
      expect(bizAfterHiring.employeeCount, 5); // 3 iniciais + 2

      // Investir em Marketing
      state = await engine.investMarketing(state, bizId);
      final bizAfterMarketing = engine.getBusinesses(state.saveId).first;
      expect(bizAfterMarketing.valuation, greaterThan(initialValuation));

      // Venda da Empresa (Exit)
      state = await engine.sellBusiness(state, bizId);
      expect(engine.getBusinesses(state.saveId).isEmpty, true);
      expect(state.character.bankBalance, greaterThan(75000.0));
    });

    test('Justiça & Submundo - Tentativa de crime, prisão e recurso judicial', () async {
      var state = await engine.createRandomLife(countryId: 'br');
      state = state.copyWith(character: state.character.copyWith(bankBalance: 30000.0));

      // Forçar tentativa de crime de colarinho branco
      state = await engine.attemptCrime(state, 'white_collar');
      expect(state.logs.first.category, 'crime');

      // Se foi preso, testar recurso judicial; se não, forçar flag e testar recurso
      if (!state.character.criminalRecord) {
        state = state.copyWith(character: state.character.copyWith(criminalRecord: true));
      }
      expect(state.character.criminalRecord, true);

      // Anular condenação via Recurso com advogados
      state = await engine.appealCriminalRecord(state);
      expect(state.character.criminalRecord, false);
      expect(state.character.bankBalance, lessThanOrEqualTo(30000.0));
    });

    test('Modo Deus (God Mode) - Dinheiro, Atributos máximos, Cura e Mega-Sena', () async {
      var state = await engine.createRandomLife(countryId: 'br');

      // 1. Injeção de R$ 10.000.000
      state = await engine.godModeAddMoney(state, 10000000.0);
      expect(state.character.bankBalance, greaterThanOrEqualTo(10000000.0));

      // 2. Setar atributos perfeitos
      state = await engine.godModeSetStats(state, health: 100, happiness: 100, smarts: 100, looks: 100);
      expect(state.character.health, 100);
      expect(state.character.happiness, 100);
      expect(state.character.smarts, 100);
      expect(state.character.looks, 100);

      // 3. Cura milagrosa total
      state = await engine.godModeCureAll(state);
      expect(engine.getActiveConditions(state.saveId).isEmpty, true);

      // 4. Limpar histórico criminal
      final arrestedChar = state.character.copyWith(criminalRecord: true, timesArrested: 5);
      state = state.copyWith(character: arrestedChar);
      state = await engine.godModeClearRecord(state);
      expect(state.character.criminalRecord, false);
      expect(state.character.timesArrested, 0);

      // 5. Prêmio da Mega-Sena instantâneo
      final balBefore = state.character.bankBalance;
      state = await engine.godModeJackpot(state);
      expect(state.character.bankBalance, balBefore + 12500000.0);
    });
  });
}

