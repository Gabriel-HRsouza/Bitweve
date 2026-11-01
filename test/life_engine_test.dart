import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:bitweve/core/database/app_database.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/careers/models/career_model.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
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
}
