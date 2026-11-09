import 'package:drift/drift.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
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
  final LifeExtras extras;

  const FullLifeData({
    required this.save,
    required this.character,
    required this.npcs,
    required this.properties,
    required this.investments,
    required this.logs,
    required this.extras,
  });
}

/// Resumo de uma vida salva para a tela de saves e o menu principal.
class SaveSummary {
  final GameSave save;
  final String name;
  final int age;
  final bool alive;
  final String? jobTitle;
  final double balance;
  final AvatarConfig avatar;
  final String city;
  final String country;

  const SaveSummary({
    required this.save,
    required this.name,
    required this.age,
    required this.alive,
    required this.jobTitle,
    required this.balance,
    required this.avatar,
    required this.city,
    required this.country,
  });
}

class DatabaseService {
  final AppDatabase db;
  bool _extrasReady = false;

  DatabaseService({AppDatabase? database}) : db = database ?? AppDatabase();

  /// Tabela auxiliar com o JSON de [LifeExtras]. Criada sob demanda para
  /// funcionar tanto em bancos novos quanto em bancos da versão 1.0.
  Future<void> _ensureExtras() async {
    if (_extrasReady) return;
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS save_extras (save_id TEXT NOT NULL PRIMARY KEY, data TEXT NOT NULL)',
    );
    _extrasReady = true;
  }

  Future<List<GameSave>> getAllSaves() async {
    return (db.select(db.gameSaves)..orderBy([(t) => OrderingTerm.desc(t.lastSavedAt)])).get();
  }

  Future<List<SaveSummary>> getSaveSummaries() async {
    final saves = await getAllSaves();
    final out = <SaveSummary>[];
    for (final s in saves) {
      final c = await (db.select(db.characters)..where((t) => t.saveId.equals(s.id))).getSingleOrNull();
      if (c == null) continue;
      out.add(SaveSummary(
        save: s,
        name: '${c.firstName} ${c.lastName}',
        age: c.currentAge,
        alive: c.isAlive,
        jobTitle: c.currentJobTitle,
        balance: c.bankBalance,
        avatar: AvatarConfig.fromJson(c.avatarConfigJson),
        city: c.city,
        country: c.country,
      ));
    }
    return out;
  }

  Future<GameSave?> getCurrentSave() async {
    final query = db.select(db.gameSaves)
      ..where((t) => t.isCurrentSave.equals(true))
      ..limit(1);
    final results = await query.get();
    if (results.isNotEmpty) return results.first;
    final all = await getAllSaves();
    return all.isNotEmpty ? all.first : null;
  }

  Future<void> setCurrentSave(String saveId) async {
    await db.transaction(() async {
      await (db.update(db.gameSaves)..where((t) => t.id.isNotNull()))
          .write(const GameSavesCompanion(isCurrentSave: Value(false)));
      await (db.update(db.gameSaves)..where((t) => t.id.equals(saveId)))
          .write(const GameSavesCompanion(isCurrentSave: Value(true)));
    });
  }

  Future<void> saveState(LifeEngineState s) => saveFullLife(
        saveId: s.saveId,
        slotName: s.slotName,
        generation: s.generation,
        character: s.character,
        npcs: s.npcs,
        properties: s.properties,
        investments: s.investments,
        logs: s.logs,
        extras: s.extras,
      );

  Future<void> saveFullLife({
    required String saveId,
    required String slotName,
    required int generation,
    required CharacterModel character,
    required List<NpcModel> npcs,
    required List<PropertyModel> properties,
    required List<InvestmentModel> investments,
    required List<LifeLog> logs,
    LifeExtras? extras,
  }) async {
    await _ensureExtras();
    final now = DateTime.now();
    await db.transaction(() async {
      final existing = await (db.select(db.gameSaves)..where((t) => t.id.equals(saveId))).getSingleOrNull();
      if (existing == null) {
        await db.into(db.gameSaves).insert(GameSavesCompanion.insert(
              id: saveId,
              slotName: slotName,
              characterId: character.id,
              createdAt: now,
              lastSavedAt: now,
              isAlive: Value(character.isAlive),
              isCurrentSave: const Value(true),
              generation: Value(generation),
            ));
      } else {
        await (db.update(db.gameSaves)..where((t) => t.id.equals(saveId))).write(GameSavesCompanion(
              slotName: Value(slotName),
              characterId: Value(character.id),
              lastSavedAt: Value(now),
              isAlive: Value(character.isAlive),
              isCurrentSave: const Value(true),
              generation: Value(generation),
            ));
      }
      await (db.update(db.gameSaves)..where((t) => t.id.equals(saveId).not()))
          .write(const GameSavesCompanion(isCurrentSave: Value(false)));

      await db.into(db.characters).insertOnConflictUpdate(_characterRow(saveId, character));

      await (db.delete(db.npcs)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.properties)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.investments)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.lifeLogs)..where((t) => t.saveId.equals(saveId))).go();

      await db.batch((b) {
        b.insertAll(db.npcs, npcs.map((npc) => _npcRow(saveId, npc)).toList());
        b.insertAll(db.properties, properties.map((p) => _propertyRow(saveId, p)).toList());
        b.insertAll(db.investments, investments.map((i) => _investmentRow(saveId, i)).toList());
        b.insertAll(db.lifeLogs, logs.map((l) => _logRow(saveId, l)).toList());
      });

      if (extras != null) {
        await db.customStatement(
          'INSERT OR REPLACE INTO save_extras (save_id, data) VALUES (?, ?)',
          [saveId, extras.encode()],
        );
      }
    });
  }

  CharactersCompanion _characterRow(String saveId, CharacterModel c) => CharactersCompanion(
        id: Value(c.id),
        saveId: Value(saveId),
        firstName: Value(c.firstName),
        lastName: Value(c.lastName),
        gender: Value(c.gender),
        sexualOrientation: Value(c.sexualOrientation),
        birthYear: Value(c.birthYear),
        currentAge: Value(c.currentAge),
        country: Value(c.country),
        city: Value(c.city),
        avatarConfigJson: Value(c.avatarConfig.toJson()),
        health: Value(c.health),
        happiness: Value(c.happiness),
        smarts: Value(c.smarts),
        looks: Value(c.looks),
        energy: Value(c.energy),
        stress: Value(c.stress),
        discipline: Value(c.discipline),
        charisma: Value(c.charisma),
        fitness: Value(c.fitness),
        reputation: Value(c.reputation),
        fame: Value(c.fame),
        karma: Value(c.karma),
        bankBalance: Value(c.bankBalance),
        annualExpenses: Value(c.annualExpenses),
        debt: Value(c.debt),
        creditScore: Value(c.creditScore),
        isAlive: Value(c.isAlive),
        causeOfDeath: Value(c.causeOfDeath),
        ageOfDeath: Value(c.ageOfDeath),
        partnerId: Value(c.partnerId),
        isMarried: Value(c.isMarried),
        educationLevel: Value(c.educationLevel),
        currentDegree: Value(c.currentDegree),
        currentJobId: Value(c.currentJobId),
        currentJobTitle: Value(c.currentJobTitle),
        currentSalary: Value(c.currentSalary),
        jobPerformance: Value(c.jobPerformance),
        yearsInCurrentJob: Value(c.yearsInCurrentJob),
        hasDriversLicense: Value(c.hasDriversLicense),
        criminalRecord: Value(c.criminalRecord),
        timesArrested: Value(c.timesArrested),
      );

  NpcsCompanion _npcRow(String saveId, NpcModel npc) => NpcsCompanion(
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
      );

  PropertiesCompanion _propertyRow(String saveId, PropertyModel p) => PropertiesCompanion(
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
      );

  InvestmentsCompanion _investmentRow(String saveId, InvestmentModel i) => InvestmentsCompanion(
        id: Value(i.id),
        saveId: Value(saveId),
        type: Value(i.type),
        name: Value(i.name),
        ticker: Value(i.ticker),
        investedAmount: Value(i.investedAmount),
        currentValue: Value(i.currentValue),
        units: Value(i.units),
        annualYieldPercent: Value(i.annualYieldPercent),
      );

  LifeLogsCompanion _logRow(String saveId, LifeLog l) => LifeLogsCompanion(
        id: Value(l.id),
        saveId: Value(saveId),
        age: Value(l.age),
        year: Value(l.year),
        category: Value(l.category),
        textContent: Value(l.textContent),
        icon: Value(l.icon),
        accentColor: Value(l.accentColor),
        createdAt: Value(l.createdAt),
      );

  Future<FullLifeData?> loadFullLifeData(String saveId) async {
    await _ensureExtras();
    final save = await (db.select(db.gameSaves)..where((t) => t.id.equals(saveId))).getSingleOrNull();
    if (save == null) return null;

    final c = await (db.select(db.characters)..where((t) => t.saveId.equals(saveId))).getSingleOrNull();
    if (c == null) return null;

    final character = CharacterModel(
      id: c.id,
      saveId: c.saveId,
      firstName: c.firstName,
      lastName: c.lastName,
      gender: c.gender,
      sexualOrientation: c.sexualOrientation,
      birthYear: c.birthYear,
      currentAge: c.currentAge,
      country: c.country,
      city: c.city,
      avatarConfig: AvatarConfig.fromJson(c.avatarConfigJson),
      health: c.health,
      happiness: c.happiness,
      smarts: c.smarts,
      looks: c.looks,
      energy: c.energy,
      stress: c.stress,
      discipline: c.discipline,
      charisma: c.charisma,
      fitness: c.fitness,
      reputation: c.reputation,
      fame: c.fame,
      karma: c.karma,
      bankBalance: c.bankBalance,
      annualExpenses: c.annualExpenses,
      debt: c.debt,
      creditScore: c.creditScore,
      isAlive: c.isAlive,
      causeOfDeath: c.causeOfDeath,
      ageOfDeath: c.ageOfDeath,
      partnerId: c.partnerId,
      isMarried: c.isMarried,
      educationLevel: c.educationLevel,
      currentDegree: c.currentDegree,
      currentJobId: c.currentJobId,
      currentJobTitle: c.currentJobTitle,
      currentSalary: c.currentSalary,
      jobPerformance: c.jobPerformance,
      yearsInCurrentJob: c.yearsInCurrentJob,
      hasDriversLicense: c.hasDriversLicense,
      criminalRecord: c.criminalRecord,
      timesArrested: c.timesArrested,
    );

    final npcs = (await (db.select(db.npcs)..where((t) => t.saveId.equals(saveId))).get())
        .map((r) => NpcModel(
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
              memories: r.memoryJson.isNotEmpty && r.memoryJson != '[]' ? r.memoryJson.split('|') : [],
            ))
        .toList();

    final properties = (await (db.select(db.properties)..where((t) => t.saveId.equals(saveId))).get())
        .map((r) => PropertyModel(
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
            ))
        .toList();

    final investments = (await (db.select(db.investments)..where((t) => t.saveId.equals(saveId))).get())
        .map((r) => InvestmentModel(
              id: r.id,
              saveId: r.saveId,
              type: r.type,
              name: r.name,
              ticker: r.ticker,
              investedAmount: r.investedAmount,
              currentValue: r.currentValue,
              units: r.units,
              annualYieldPercent: r.annualYieldPercent,
            ))
        .toList();

    final logs = (await (db.select(db.lifeLogs)
              ..where((t) => t.saveId.equals(saveId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get())
        .map((r) => LifeLog(
              id: r.id,
              saveId: r.saveId,
              age: r.age,
              year: r.year,
              category: r.category,
              textContent: r.textContent,
              icon: r.icon,
              accentColor: r.accentColor,
              createdAt: r.createdAt,
            ))
        .toList();

    final extrasRow = await db.customSelect(
      'SELECT data FROM save_extras WHERE save_id = ?',
      variables: [Variable.withString(saveId)],
    ).getSingleOrNull();
    final extras = LifeExtras.decode(extrasRow?.read<String>('data'));

    return FullLifeData(
      save: save,
      character: character,
      npcs: npcs,
      properties: properties,
      investments: investments,
      logs: logs,
      extras: extras,
    );
  }

  Future<void> deleteSave(String saveId) async {
    await _ensureExtras();
    await db.transaction(() async {
      await (db.delete(db.lifeLogs)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.investments)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.properties)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.npcs)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.characters)..where((t) => t.saveId.equals(saveId))).go();
      await (db.delete(db.gameSaves)..where((t) => t.id.equals(saveId))).go();
      await db.customStatement('DELETE FROM save_extras WHERE save_id = ?', [saveId]);
    });
  }

  Future<void> deleteAllSaves() async {
    final saves = await getAllSaves();
    for (final s in saves) {
      await deleteSave(s.id);
    }
    await db.delete(db.achievements).go();
  }

  // ------------------------------------------------------------ CONQUISTAS (globais)
  Future<Set<String>> unlockedAchievements() async {
    final rows = await db.select(db.achievements).get();
    return rows.where((r) => r.unlockedAt != null).map((r) => r.code).toSet();
  }

  Future<Map<String, DateTime>> unlockedAchievementDates() async {
    final rows = await db.select(db.achievements).get();
    return {for (final r in rows) if (r.unlockedAt != null) r.code: r.unlockedAt!};
  }

  Future<void> unlockAchievement(String code, String title, String description, String icon) async {
    await db.into(db.achievements).insertOnConflictUpdate(AchievementsCompanion(
          id: Value(code),
          code: Value(code),
          title: Value(title),
          description: Value(description),
          icon: Value(icon),
          unlockedAt: Value(DateTime.now()),
        ));
  }
}
