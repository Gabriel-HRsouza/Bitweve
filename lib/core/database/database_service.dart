import 'package:drift/drift.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/core/database/app_database.dart' hide LifeLog;

class FullLifeData {
  final GameSave save;
  final CharacterModel character;
  final List<NpcModel> npcs;
  final List<PropertyModel> properties;
  final List<InvestmentModel> investments;
  final List<LifeLog> logs;

  const FullLifeData({
    required this.save,
    required this.character,
    required this.npcs,
    required this.properties,
    required this.investments,
    required this.logs,
  });
}

class DatabaseService {
  final AppDatabase db;

  DatabaseService({AppDatabase? database}) : db = database ?? AppDatabase();

  // Obter todos os slots de vidas salvas
  Future<List<GameSave>> getAllSaves() async {
    return (db.select(db.gameSaves)
          ..orderBy([(t) => OrderingTerm.desc(t.lastSavedAt)]))
        .get();
  }

  // Obter vida ativa atual
  Future<GameSave?> getCurrentSave() async {
    final query = db.select(db.gameSaves)
      ..where((t) => t.isCurrentSave.equals(true))
      ..limit(1);
    final results = await query.get();
    if (results.isNotEmpty) return results.first;

    // Fallback: se não houver marcado como current, pega o mais recente
    final all = await getAllSaves();
    return all.isNotEmpty ? all.first : null;
  }

  // Definir slot como atual
  Future<void> setCurrentSave(String saveId) async {
    await db.transaction(() async {
      await (db.update(db.gameSaves)..where((t) => t.id.isNotNull()))
          .write(const GameSavesCompanion(isCurrentSave: Value(false)));
      await (db.update(db.gameSaves)..where((t) => t.id.equals(saveId)))
          .write(const GameSavesCompanion(isCurrentSave: Value(true)));
    });
  }

  // Salvar estado completo da vida
  Future<void> saveFullLife({
    required String saveId,
    required String slotName,
    required int generation,
    required CharacterModel character,
    required List<NpcModel> npcs,
    required List<PropertyModel> properties,
    required List<InvestmentModel> investments,
    required List<LifeLog> logs,
  }) async {
    await db.transaction(() async {
      // 1. Upsert GameSave
      await db.into(db.gameSaves).insertOnConflictUpdate(
            GameSavesCompanion(
              id: Value(saveId),
              slotName: Value(slotName),
              characterId: Value(character.id),
              createdAt: Value(DateTime.now()),
              lastSavedAt: Value(DateTime.now()),
              isAlive: Value(character.isAlive),
              isCurrentSave: const Value(true),
              generation: Value(generation),
            ),
          );

      // Marcar outros saves como não atuais
      await (db.update(db.gameSaves)..where((t) => t.id.equals(saveId).not()))
          .write(const GameSavesCompanion(isCurrentSave: Value(false)));

      // 2. Upsert Protagonista
      await db.into(db.characters).insertOnConflictUpdate(
            CharactersCompanion(
              id: Value(character.id),
              saveId: Value(saveId),
              firstName: Value(character.firstName),
              lastName: Value(character.lastName),
              gender: Value(character.gender),
              sexualOrientation: Value(character.sexualOrientation),
              birthYear: Value(character.birthYear),
              currentAge: Value(character.currentAge),
              country: Value(character.country),
              city: Value(character.city),
              avatarConfigJson: Value(character.avatarConfig.toJson()),
              health: Value(character.health),
              happiness: Value(character.happiness),
              smarts: Value(character.smarts),
              looks: Value(character.looks),
              energy: Value(character.energy),
              stress: Value(character.stress),
              discipline: Value(character.discipline),
              charisma: Value(character.charisma),
              fitness: Value(character.fitness),
              reputation: Value(character.reputation),
              fame: Value(character.fame),
              karma: Value(character.karma),
              bankBalance: Value(character.bankBalance),
              annualExpenses: Value(character.annualExpenses),
              debt: Value(character.debt),
              creditScore: Value(character.creditScore),
              isAlive: Value(character.isAlive),
              causeOfDeath: Value(character.causeOfDeath),
              ageOfDeath: Value(character.ageOfDeath),
              partnerId: Value(character.partnerId),
              isMarried: Value(character.isMarried),
              educationLevel: Value(character.educationLevel),
              currentDegree: Value(character.currentDegree),
              currentJobId: Value(character.currentJobId),
              currentJobTitle: Value(character.currentJobTitle),
              currentSalary: Value(character.currentSalary),
              jobPerformance: Value(character.jobPerformance),
              yearsInCurrentJob: Value(character.yearsInCurrentJob),
              hasDriversLicense: Value(character.hasDriversLicense),
              criminalRecord: Value(character.criminalRecord),
              timesArrested: Value(character.timesArrested),
            ),
          );

      // 3. Atualizar NPCs
      await (db.delete(db.npcs)..where((t) => t.saveId.equals(saveId))).go();
      for (final npc in npcs) {
        await db.into(db.npcs).insert(
              NpcsCompanion(
                id: Value(npc.id),
                saveId: Value(saveId),
                firstName: Value(npc.firstName),
                lastName: Value(npc.lastName),
                gender: Value(npc.gender),
                age: Value(npc.age),
                relationshipType: Value(npc.relationshipType.name),
                relationshipLevel: Value(npc.relationshipLevel),
                respectLevel: Value(npc.respectLevel),
                avatarConfigJson: Value(npc.avatarConfig.toJson()),
                occupation: Value(npc.occupation),
                salary: Value(npc.salary),
                netWorth: Value(npc.netWorth),
                health: Value(npc.health),
                happiness: Value(npc.happiness),
                isAlive: Value(npc.isAlive),
                causeOfDeath: Value(npc.causeOfDeath),
                memoryJson: Value(npc.memories.join('|')),
              ),
            );
      }

      // 4. Atualizar Propriedades
      await (db.delete(db.properties)..where((t) => t.saveId.equals(saveId))).go();
      for (final p in properties) {
        await db.into(db.properties).insert(
              PropertiesCompanion(
                id: Value(p.id),
                saveId: Value(saveId),
                type: Value(p.type),
                name: Value(p.name),
                purchasePrice: Value(p.purchasePrice),
                currentValue: Value(p.currentValue),
                annualCost: Value(p.annualCost),
                condition: Value(p.condition),
                isFinanced: Value(p.isFinanced),
                monthlyPayment: Value(p.monthlyPayment),
                remainingDebt: Value(p.remainingDebt),
                purchasedAtAge: Value(p.purchasedAtAge),
              ),
            );
      }

      // 5. Atualizar Investimentos
      await (db.delete(db.investments)..where((t) => t.saveId.equals(saveId))).go();
      for (final inv in investments) {
        await db.into(db.investments).insert(
              InvestmentsCompanion(
                id: Value(inv.id),
                saveId: Value(saveId),
                type: Value(inv.type),
                name: Value(inv.name),
                ticker: Value(inv.ticker),
                investedAmount: Value(inv.investedAmount),
                currentValue: Value(inv.currentValue),
                units: Value(inv.units),
                annualYieldPercent: Value(inv.annualYieldPercent),
              ),
            );
      }

      // 6. Atualizar LifeLogs
      await (db.delete(db.lifeLogs)..where((t) => t.saveId.equals(saveId))).go();
      for (final log in logs) {
        await db.into(db.lifeLogs).insert(
              LifeLogsCompanion(
                id: Value(log.id),
                saveId: Value(saveId),
                age: Value(log.age),
                year: Value(log.year),
                category: Value(log.category),
                textContent: Value(log.textContent),
                icon: Value(log.icon),
                accentColor: Value(log.accentColor),
                createdAt: Value(log.createdAt),
              ),
            );
      }
    });
  }

  // Carregar todos os dados de uma vida salva
  Future<FullLifeData?> loadFullLifeData(String saveId) async {
    final save = await (db.select(db.gameSaves)..where((t) => t.id.equals(saveId)))
        .getSingleOrNull();
    if (save == null) return null;

    final charRow = await (db.select(db.characters)
          ..where((t) => t.saveId.equals(saveId)))
        .getSingleOrNull();
    if (charRow == null) return null;

    final character = CharacterModel(
      id: charRow.id,
      saveId: charRow.saveId,
      firstName: charRow.firstName,
      lastName: charRow.lastName,
      gender: charRow.gender,
      sexualOrientation: charRow.sexualOrientation,
      birthYear: charRow.birthYear,
      currentAge: charRow.currentAge,
      country: charRow.country,
      city: charRow.city,
      avatarConfig: AvatarConfig.fromJson(charRow.avatarConfigJson),
      health: charRow.health,
      happiness: charRow.happiness,
      smarts: charRow.smarts,
      looks: charRow.looks,
      energy: charRow.energy,
      stress: charRow.stress,
      discipline: charRow.discipline,
      charisma: charRow.charisma,
      fitness: charRow.fitness,
      reputation: charRow.reputation,
      fame: charRow.fame,
      karma: charRow.karma,
      bankBalance: charRow.bankBalance,
      annualExpenses: charRow.annualExpenses,
      debt: charRow.debt,
      creditScore: charRow.creditScore,
      isAlive: charRow.isAlive,
      causeOfDeath: charRow.causeOfDeath,
      ageOfDeath: charRow.ageOfDeath,
      partnerId: charRow.partnerId,
      isMarried: charRow.isMarried,
      educationLevel: charRow.educationLevel,
      currentDegree: charRow.currentDegree,
      currentJobId: charRow.currentJobId,
      currentJobTitle: charRow.currentJobTitle,
      currentSalary: charRow.currentSalary,
      jobPerformance: charRow.jobPerformance,
      yearsInCurrentJob: charRow.yearsInCurrentJob,
      hasDriversLicense: charRow.hasDriversLicense,
      criminalRecord: charRow.criminalRecord,
      timesArrested: charRow.timesArrested,
    );

    final npcRows = await (db.select(db.npcs)
          ..where((t) => t.saveId.equals(saveId)))
        .get();
    final npcs = npcRows.map((r) {
      return NpcModel(
        id: r.id,
        saveId: r.saveId,
        firstName: r.firstName,
        lastName: r.lastName,
        gender: r.gender,
        age: r.age,
        relationshipType: NpcModel.parseRelationType(r.relationshipType),
        relationshipLevel: r.relationshipLevel,
        respectLevel: r.respectLevel,
        avatarConfig: AvatarConfig.fromJson(r.avatarConfigJson),
        occupation: r.occupation,
        salary: r.salary,
        netWorth: r.netWorth,
        health: r.health,
        happiness: r.happiness,
        isAlive: r.isAlive,
        causeOfDeath: r.causeOfDeath,
        memories: r.memoryJson.isNotEmpty ? r.memoryJson.split('|') : [],
      );
    }).toList();

    final propRows = await (db.select(db.properties)
          ..where((t) => t.saveId.equals(saveId)))
        .get();
    final properties = propRows.map((r) {
      return PropertyModel(
        id: r.id,
        saveId: r.saveId,
        type: r.type,
        name: r.name,
        purchasePrice: r.purchasePrice,
        currentValue: r.currentValue,
        annualCost: r.annualCost,
        condition: r.condition,
        isFinanced: r.isFinanced,
        monthlyPayment: r.monthlyPayment,
        remainingDebt: r.remainingDebt,
        purchasedAtAge: r.purchasedAtAge,
      );
    }).toList();

    final invRows = await (db.select(db.investments)
          ..where((t) => t.saveId.equals(saveId)))
        .get();
    final investments = invRows.map((r) {
      return InvestmentModel(
        id: r.id,
        saveId: r.saveId,
        type: r.type,
        name: r.name,
        ticker: r.ticker,
        investedAmount: r.investedAmount,
        currentValue: r.currentValue,
        units: r.units,
        annualYieldPercent: r.annualYieldPercent,
      );
    }).toList();

    final logRows = await (db.select(db.lifeLogs)
          ..where((t) => t.saveId.equals(saveId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    final logs = logRows.map((r) {
      return LifeLog(
        id: r.id,
        saveId: r.saveId,
        age: r.age,
        year: r.year,
        category: r.category,
        textContent: r.textContent,
        icon: r.icon,
        accentColor: r.accentColor,
        createdAt: r.createdAt,
      );
    }).toList();

    return FullLifeData(
      save: save,
      character: character,
      npcs: npcs,
      properties: properties,
      investments: investments,
      logs: logs,
    );
  }

  // Deletar um slot de vida
  Future<void> deleteSave(String saveId) async {
    await db.transaction(() async {
      await (db.delete(db.lifeLogs)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.investments)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.properties)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.npcs)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.characters)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.gameSaves)..where((t) => t.id.equals(saveId))).go();
    });
  }
}
