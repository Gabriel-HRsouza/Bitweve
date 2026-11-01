import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/database/database_service.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/careers/models/career_model.dart';
import 'package:bitweve/features/education/models/education_model.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/health/models/health_condition.dart';
import 'package:bitweve/features/health/data/health_catalog.dart';
import 'package:bitweve/features/finances/models/crypto_asset.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/businesses/models/business_model.dart';

class LifeEngineState {
  final String saveId;
  final String slotName;
  final int generation;
  final CharacterModel character;
  final List<NpcModel> npcs;
  final List<PropertyModel> properties;
  final List<InvestmentModel> investments;
  final List<LifeLog> logs;
  final LifeEvent? pendingEvent;
  final bool isLoading;

  const LifeEngineState({
    required this.saveId,
    required this.slotName,
    this.generation = 1,
    required this.character,
    required this.npcs,
    required this.properties,
    required this.investments,
    required this.logs,
    this.pendingEvent,
    this.isLoading = false,
  });

  double get netWorth {
    double total = character.bankBalance;
    for (final p in properties) {
      total += (p.currentValue - p.remainingDebt);
    }
    for (final inv in investments) {
      total += inv.currentValue;
    }
    total -= character.debt;
    return total;
  }

  LifeEngineState copyWith({
    String? saveId,
    String? slotName,
    int? generation,
    CharacterModel? character,
    List<NpcModel>? npcs,
    List<PropertyModel>? properties,
    List<InvestmentModel>? investments,
    List<LifeLog>? logs,
    LifeEvent? pendingEvent,
    bool clearPendingEvent = false,
    bool? isLoading,
  }) {
    return LifeEngineState(
      saveId: saveId ?? this.saveId,
      slotName: slotName ?? this.slotName,
      generation: generation ?? this.generation,
      character: character ?? this.character,
      npcs: npcs ?? this.npcs,
      properties: properties ?? this.properties,
      investments: investments ?? this.investments,
      logs: logs ?? this.logs,
      pendingEvent: clearPendingEvent ? null : (pendingEvent ?? this.pendingEvent),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LifeEngineService {
  final DatabaseService dbService;
  final AudioService audioService;
  final Random _rng = Random();
  final Uuid _uuid = const Uuid();

  List<LifeEvent> _cachedEvents = [];
  List<CareerModel> _cachedCareers = [];
  List<DegreeModel> _cachedDegrees = [];
  List<Map<String, dynamic>> _cachedCountries = [];

  final Map<String, List<HealthCondition>> _activeConditions = {};
  final Map<String, bool> _healthInsurance = {};
  final Map<String, List<CryptoAsset>> _cryptoWallets = {};
  final Map<String, List<VehicleModel>> _ownedVehicles = {};
  final Map<String, List<BusinessModel>> _businesses = {};

  List<CareerModel> get availableCareers => _cachedCareers;
  List<DegreeModel> get availableDegrees => _cachedDegrees;
  List<Map<String, dynamic>> get availableCountries => _cachedCountries;

  List<HealthCondition> getActiveConditions(String saveId) => _activeConditions[saveId] ?? [];
  bool hasHealthInsurance(String saveId) => _healthInsurance[saveId] ?? false;

  List<CryptoAsset> getCryptoWallet(String saveId) {
    return _cryptoWallets.putIfAbsent(saveId, () => [
      const CryptoAsset(
        symbol: 'BTC',
        name: 'Bitcoin',
        currentPrice: 382450.0,
        change24hPercent: 3.4,
        priceHistory: [365000.0, 371000.0, 368000.0, 375000.0, 382450.0],
        ownedUnits: 0.0,
      ),
      const CryptoAsset(
        symbol: 'ETH',
        name: 'Ethereum',
        currentPrice: 19800.0,
        change24hPercent: -1.2,
        priceHistory: [20500.0, 20100.0, 19900.0, 19600.0, 19800.0],
        ownedUnits: 0.0,
      ),
      const CryptoAsset(
        symbol: 'BWV',
        name: 'BitWeve Token',
        currentPrice: 2.45,
        change24hPercent: 12.8,
        priceHistory: [1.80, 1.95, 2.10, 2.25, 2.45],
        ownedUnits: 0.0,
      ),
    ]);
  }

  List<VehicleModel> getOwnedVehicles(String saveId) => _ownedVehicles[saveId] ?? [];
  List<BusinessModel> getBusinesses(String saveId) => _businesses[saveId] ?? [];

  LifeEngineService({
    DatabaseService? databaseService,
    AudioService? audio,
  })  : dbService = databaseService ?? DatabaseService(),
        audioService = audio ?? AudioService();

  Future<void> initDatasets() async {
    try {
      final eventsRaw = await rootBundle.loadString('assets/data/events.json');
      final eventsJson = jsonDecode(eventsRaw) as List;
      _cachedEvents = eventsJson.map((e) => LifeEvent.fromMap(e as Map<String, dynamic>)).toList();

      final careersRaw = await rootBundle.loadString('assets/data/careers.json');
      final careersJson = jsonDecode(careersRaw) as List;
      _cachedCareers = careersJson.map((c) => CareerModel.fromMap(c as Map<String, dynamic>)).toList();

      final degreesRaw = await rootBundle.loadString('assets/data/degrees.json');
      final degreesJson = jsonDecode(degreesRaw) as List;
      _cachedDegrees = degreesJson.map((d) => DegreeModel.fromMap(d as Map<String, dynamic>)).toList();

      final countriesRaw = await rootBundle.loadString('assets/data/countries.json');
      _cachedCountries = (jsonDecode(countriesRaw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      // Fallback in case of mock/unit test running without Flutter asset bundle
    }
  }

  // Criar nova vida aleatória
  Future<LifeEngineState> createRandomLife({
    String? countryId,
    String? city,
    String? gender,
    String? firstName,
    String? lastName,
  }) async {
    final saveId = _uuid.v4();
    final chosenGender = gender ?? (_rng.nextBool() ? 'male' : 'female');

    final country = _cachedCountries.isNotEmpty
        ? (countryId != null
            ? _cachedCountries.firstWhere((c) => c['id'] == countryId, orElse: () => _cachedCountries.first)
            : _cachedCountries.first)
        : {'name': 'Brasil', 'currency': 'BRL', 'currencySymbol': 'R\$', 'cities': ['São Paulo']};

    final countryName = country['name'] as String;
    final cities = (country['cities'] as List).cast<String>();
    final chosenCity = city ?? cities[_rng.nextInt(cities.length)];

    final fName = firstName ?? _randomFirstName(chosenGender);
    final lName = lastName ?? _randomLastName();

    final avatar = AvatarConfig.random(gender: chosenGender, rng: _rng);

    final character = CharacterModel(
      id: _uuid.v4(),
      saveId: saveId,
      firstName: fName,
      lastName: lName,
      gender: chosenGender,
      sexualOrientation: _rng.nextDouble() < 0.85 ? 'heterosexual' : (_rng.nextBool() ? 'homosexual' : 'bisexual'),
      birthYear: DateTime.now().year,
      currentAge: 0,
      country: countryName,
      city: chosenCity,
      avatarConfig: avatar,
      health: 85 + _rng.nextInt(15),
      happiness: 85 + _rng.nextInt(15),
      smarts: 40 + _rng.nextInt(50),
      looks: 40 + _rng.nextInt(50),
      energy: 100,
      stress: 5,
      discipline: 30 + _rng.nextInt(50),
      charisma: 30 + _rng.nextInt(50),
      fitness: 50 + _rng.nextInt(40),
      reputation: 50,
      fame: 0,
      karma: 50,
      bankBalance: 0.0,
      annualExpenses: 0.0,
      debt: 0.0,
      creditScore: 650,
      isAlive: true,
      educationLevel: 'none',
    );

    // Gerar Família Inicial (Pai e Mãe)
    final npcs = <NpcModel>[];
    final fatherAge = 24 + _rng.nextInt(16);
    final motherAge = 22 + _rng.nextInt(14);

    final father = NpcModel(
      id: _uuid.v4(),
      saveId: saveId,
      firstName: _randomFirstName('male'),
      lastName: lName,
      gender: 'male',
      age: fatherAge,
      relationshipType: RelationshipType.father,
      relationshipLevel: 75 + _rng.nextInt(25),
      respectLevel: 70 + _rng.nextInt(25),
      avatarConfig: AvatarConfig.random(gender: 'male', rng: _rng),
      occupation: _randomCommonJob(),
      salary: 35000.0 + _rng.nextInt(50000),
      netWorth: 20000.0 + _rng.nextInt(100000),
      health: 80 + _rng.nextInt(20),
      happiness: 75 + _rng.nextInt(20),
    );

    final mother = NpcModel(
      id: _uuid.v4(),
      saveId: saveId,
      firstName: _randomFirstName('female'),
      lastName: _randomLastName(),
      gender: 'female',
      age: motherAge,
      relationshipType: RelationshipType.mother,
      relationshipLevel: 80 + _rng.nextInt(20),
      respectLevel: 75 + _rng.nextInt(25),
      avatarConfig: AvatarConfig.random(gender: 'female', rng: _rng),
      occupation: _randomCommonJob(),
      salary: 32000.0 + _rng.nextInt(45000),
      netWorth: 18000.0 + _rng.nextInt(80000),
      health: 85 + _rng.nextInt(15),
      happiness: 80 + _rng.nextInt(20),
    );

    npcs.add(father);
    npcs.add(mother);

    // 40% chance de ter irmão ou irmã mais velho(a)
    if (_rng.nextDouble() < 0.4) {
      final sibGender = _rng.nextBool() ? 'male' : 'female';
      npcs.add(
        NpcModel(
          id: _uuid.v4(),
          saveId: saveId,
          firstName: _randomFirstName(sibGender),
          lastName: lName,
          gender: sibGender,
          age: 1 + _rng.nextInt(5),
          relationshipType: sibGender == 'male' ? RelationshipType.brother : RelationshipType.sister,
          relationshipLevel: 70 + _rng.nextInt(30),
          avatarConfig: AvatarConfig.random(gender: sibGender, rng: _rng),
          occupation: 'Criança',
          salary: 0,
          netWorth: 0,
        ),
      );
    }

    // Primeiro log: nascimento
    final firstLog = LifeLog(
      id: _uuid.v4(),
      saveId: saveId,
      age: 0,
      year: character.birthYear,
      category: 'birth',
      textContent: 'Você nasceu em $chosenCity, $countryName. Seus pais são ${father.fullName} e ${mother.fullName}.',
      icon: 'child_friendly',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );

    final state = LifeEngineState(
      saveId: saveId,
      slotName: 'Vida de ${character.fullName}',
      generation: 1,
      character: character,
      npcs: npcs,
      properties: [],
      investments: [],
      logs: [firstLog],
    );

    // Salvar no SQLite local
    await dbService.saveFullLife(
      saveId: state.saveId,
      slotName: state.slotName,
      generation: state.generation,
      character: state.character,
      npcs: state.npcs,
      properties: state.properties,
      investments: state.investments,
      logs: state.logs,
    );

    audioService.playSfx(GameSfx.birth);
    return state;
  }

  // Avançar um ano de vida
  Future<LifeEngineState> advanceYear(LifeEngineState state) async {
    if (!state.character.isAlive) return state;

    final char = state.character;
    final newAge = char.currentAge + 1;
    final newYear = char.birthYear + newAge;
    final newLogs = List<LifeLog>.from(state.logs);

    audioService.playSfx(GameSfx.ageUp);

    double balance = char.bankBalance;
    double debt = char.debt;
    int health = char.health;
    int happiness = char.happiness;
    int smarts = char.smarts;
    int looks = char.looks;
    int stress = char.stress;
    int perf = char.jobPerformance;
    double? currentSalary = char.currentSalary;
    String eduLevel = char.educationLevel;

    // 1. Envelhecer e simular NPCs
    final updatedNpcs = <NpcModel>[];
    for (final npc in state.npcs) {
      if (!npc.isAlive) {
        updatedNpcs.add(npc);
        continue;
      }
      final newNpcAge = npc.age + 1;
      int npcHealth = npc.health;
      bool npcAlive = true;
      String? causeOfDeath;

      if (newNpcAge > 68) {
        npcHealth = (npcHealth - _rng.nextInt(6)).clamp(0, 100);
        final deathProb = (newNpcAge - 65) * 0.025;
        if (_rng.nextDouble() < deathProb || npcHealth <= 0) {
          npcAlive = false;
          causeOfDeath = 'causas naturais aos $newNpcAge anos';
        }
      }

      if (!npcAlive) {
        newLogs.insert(
          0,
          LifeLog(
            id: _uuid.v4(),
            saveId: state.saveId,
            age: newAge,
            year: newYear,
            category: 'family',
            textContent: 'Luto: Seu(Sua) ${npc.relationLabel} ${npc.fullName} faleceu de $causeOfDeath.',
            icon: 'sentiment_very_dissatisfied',
            accentColor: '#EF4444',
            createdAt: DateTime.now(),
          ),
        );
        // Herança se for pai/mãe
        if (npc.relationshipType == RelationshipType.father || npc.relationshipType == RelationshipType.mother) {
          final inheritance = (npc.netWorth * 0.7).clamp(3000.0, 500000.0);
          balance += inheritance;
          newLogs.insert(
            0,
            LifeLog(
              id: _uuid.v4(),
              saveId: state.saveId,
              age: newAge,
              year: newYear,
              category: 'finance',
              textContent: 'Partilha de Bens: Você herdou R\$ ${inheritance.toStringAsFixed(2)} de ${npc.fullName}.',
              icon: 'attach_money',
              accentColor: '#10B981',
              createdAt: DateTime.now(),
            ),
          );
        }
      } else {
        // NPC vivo: leve flutuação de afeto e saúde
        final bondDrift = _rng.nextInt(5) - 2;
        final newRel = (npc.relationshipLevel + bondDrift).clamp(10, 100);
        npcHealth = (npcHealth + _rng.nextInt(5) - 2).clamp(10, 100);
        updatedNpcs.add(npc.copyWith(age: newNpcAge, health: npcHealth, relationshipLevel: newRel));
        continue;
      }

      updatedNpcs.add(npc.copyWith(age: newNpcAge, health: npcHealth, isAlive: npcAlive, causeOfDeath: causeOfDeath));
    }

    // 2. Sistema Escolar e Universitário
    if (newAge == 6 && eduLevel == 'none') {
      eduLevel = 'elementary';
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'education',
          textContent: 'Você começou a frequentar o Ensino Fundamental!',
          icon: 'school',
          accentColor: '#3B82F6',
          createdAt: DateTime.now(),
        ),
      );
    } else if (newAge == 15 && eduLevel == 'elementary') {
      eduLevel = 'high_school';
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'education',
          textContent: 'Você ingressou no Ensino Médio com novas matérias e amizades!',
          icon: 'school',
          accentColor: '#3B82F6',
          createdAt: DateTime.now(),
        ),
      );
    } else if (newAge == 18 && eduLevel == 'high_school') {
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'education',
          textContent: 'Parabéns! Você se formou no Ensino Médio e agora é maior de idade!',
          icon: 'workspace_premium',
          accentColor: '#F59E0B',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 3. Economia, Salário, Impostos e Despesas
    if (currentSalary != null && currentSalary > 0) {
      final grossSalary = currentSalary;
      final tax = grossSalary * 0.15;
      final netSalary = grossSalary - tax;
      balance += netSalary;

      // Avaliação de promoção por desempenho
      if (perf > 72 && _rng.nextDouble() < 0.35) {
        final raise = grossSalary * 0.15;
        currentSalary = grossSalary + raise;
        audioService.playSfx(GameSfx.promotion);
        newLogs.insert(
          0,
          LifeLog(
            id: _uuid.v4(),
            saveId: state.saveId,
            age: newAge,
            year: newYear,
            category: 'career',
            textContent: 'Promoção Reconhecida! Seu excelente desempenho garantiu 15% de aumento (Novo salário: R\$ ${currentSalary.toStringAsFixed(0)}/ano).',
            icon: 'trending_up',
            accentColor: '#10B981',
            createdAt: DateTime.now(),
          ),
        );
      } else {
        newLogs.insert(
          0,
          LifeLog(
            id: _uuid.v4(),
            saveId: state.saveId,
            age: newAge,
            year: newYear,
            category: 'career',
            textContent: 'Você trabalhou como ${char.currentJobTitle} e recebeu R\$ ${netSalary.toStringAsFixed(2)} líquidos este ano.',
            icon: 'payments',
            accentColor: '#10B981',
            createdAt: DateTime.now(),
          ),
        );
      }
    } else if (newAge >= 18 && balance > 0) {
      // Custo de vida básico na fase adulta se desempregado
      final livingCost = 350.0 + _rng.nextInt(250);
      balance = (balance - livingCost).clamp(0.0, double.infinity);
    }

    // Despesas com propriedades e veículos
    final updatedProps = <PropertyModel>[];
    for (final p in state.properties) {
      balance -= p.annualCost;
      double remaining = p.remainingDebt;
      if (p.isFinanced && remaining > 0) {
        final payment = p.monthlyPayment * 12;
        balance -= payment;
        remaining = (remaining - payment).clamp(0.0, double.infinity);
      }
      double newValue = p.currentValue;
      if (p.isRealEstate) {
        newValue *= (1.0 + (_rng.nextDouble() * 0.08 - 0.01)); // Imóveis tendem a valorizar
      } else if (p.isVehicle) {
        newValue *= (1.0 - (_rng.nextDouble() * 0.10 + 0.04)); // Veículos depreciam
      }
      updatedProps.add(p.copyWith(remainingDebt: remaining, currentValue: newValue));
    }

    // Rendimentos de Investimentos
    final updatedInvs = <InvestmentModel>[];
    for (final inv in state.investments) {
      double annualReturnRate = 0.0;
      if (inv.type == 'fixed_income') {
        annualReturnRate = 0.1075; // Renda fixa 10.75% a.a.
      } else if (inv.type == 'stock') {
        annualReturnRate = (_rng.nextDouble() * 0.35) - 0.08;
      } else if (inv.type == 'crypto') {
        annualReturnRate = (_rng.nextDouble() * 0.75) - 0.30;
      }
      final newCurrentVal = (inv.currentValue * (1.0 + annualReturnRate)).clamp(0.0, double.infinity);
      updatedInvs.add(inv.copyWith(currentValue: newCurrentVal));
    }

    // Simulação Anual de Empresas e Negócios Fundados
    final businesses = _businesses[state.saveId] ?? [];
    if (businesses.isNotEmpty) {
      double totalBizProfit = 0.0;
      final updatedBiz = <BusinessModel>[];
      for (final b in businesses) {
        final variance = 1.0 + (_rng.nextDouble() * 0.30 - 0.12);
        final newRev = (b.revenue * variance).clamp(1000.0, 50000000.0);
        final newExp = (b.expenses * (1.0 + (_rng.nextDouble() * 0.10))).clamp(500.0, 40000000.0);
        final profit = newRev - newExp;
        totalBizProfit += profit;
        final newValuation = (newRev * 2.5 + profit * 3).clamp(5000.0, 100000000.0);
        updatedBiz.add(b.copyWith(revenue: newRev, expenses: newExp, valuation: newValuation));
      }
      _businesses[state.saveId] = updatedBiz;
      balance += totalBizProfit;
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'business',
          textContent: 'Relatório Corporativo: Suas empresas geraram um resultado líquido de R\$ ${totalBizProfit.toStringAsFixed(2)} este ano.',
          icon: 'business',
          accentColor: totalBizProfit >= 0 ? '#10B981' : '#EF4444',
          createdAt: DateTime.now(),
        ),
      );
    }

    // Custos Anuais e Depreciação de Veículos
    final vehicles = _ownedVehicles[state.saveId] ?? [];
    if (vehicles.isNotEmpty) {
      final updatedVehicles = <VehicleModel>[];
      for (final v in vehicles) {
        balance -= (v.annualMaintenance + (v.hasInsurance ? v.annualInsurance : 0));
        final newKm = v.mileageKm + (8000 + _rng.nextInt(7000));
        final newCond = (v.conditionPercent - (4 + _rng.nextInt(5))).clamp(10, 100);
        final newVal = (v.currentValue * 0.92).clamp(1000.0, double.infinity);
        updatedVehicles.add(v.copyWith(mileageKm: newKm, conditionPercent: newCond, currentValue: newVal));
      }
      _ownedVehicles[state.saveId] = updatedVehicles;
    }

    // Mercado Cripto: Oscilação Anual de Cotações
    final wallet = _cryptoWallets[state.saveId];
    if (wallet != null) {
      final updatedWallet = <CryptoAsset>[];
      for (final asset in wallet) {
        final pct = (_rng.nextDouble() * 0.50) - 0.22;
        final newPrice = (asset.currentPrice * (1.0 + pct)).clamp(0.01, 2500000.0);
        final newHistory = List<double>.from(asset.priceHistory)..add(newPrice);
        if (newHistory.length > 10) newHistory.removeAt(0);
        updatedWallet.add(asset.copyWith(
          currentPrice: newPrice,
          change24hPercent: pct * 100,
          priceHistory: newHistory,
        ));
      }
      _cryptoWallets[state.saveId] = updatedWallet;
    }

    // Despesas de Plano de Saúde
    if (_healthInsurance[state.saveId] == true) {
      balance = (balance - 320.0).clamp(0.0, double.infinity);
    }

    // 4. Saúde, Envelhecimento e Longevidade
    if (newAge > 60) {
      health = (health - (1 + _rng.nextInt(4))).clamp(0, 100);
      happiness = (happiness - _rng.nextInt(2)).clamp(0, 100);
    }
    if (stress > 70) {
      health = (health - 3).clamp(0, 100);
      happiness = (happiness - 4).clamp(0, 100);
    }

    // 5. Garantir Registro Anual / Mensagem de Vida para Cada Ano
    final yearlyMilestoneLog = _generateYearlyLifeMilestone(newAge, newYear, state.saveId, char);
    newLogs.insert(0, yearlyMilestoneLog);

    // 6. Chance de Acontecimentos Espontâneos da Vida (70% de chance)
    if (_rng.nextDouble() < 0.70) {
      final flavorLog = _generateRandomLifeFlavor(newAge, newYear, state.saveId, updatedNpcs);
      if (flavorLog != null) {
        newLogs.insert(0, flavorLog);
      }
    }

    // 7. Verificar Morte
    bool isAlive = true;
    String? causeOfDeath;
    int? ageOfDeath;

    if (health <= 0 || (newAge >= 82 && _rng.nextDouble() < (newAge - 78) * 0.04) || newAge >= 115) {
      isAlive = false;
      ageOfDeath = newAge;
      causeOfDeath = newAge >= 85 ? 'falência de múltiplos órgãos pela idade avançada' : 'complicações críticas de saúde';
      audioService.playSfx(GameSfx.death);
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'death',
          textContent: 'Fim da jornada: Você faleceu aos $newAge anos devido a $causeOfDeath.',
          icon: 'dangerous',
          accentColor: '#EF4444',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 8. Sortear Evento Interativo de Escolha
    LifeEvent? selectedEvent;
    if (isAlive) {
      final validEvents = _cachedEvents.where((e) => newAge >= e.minAge && newAge <= e.maxAge).toList();
      if (validEvents.isNotEmpty && _rng.nextDouble() < 0.70) {
        selectedEvent = validEvents[_rng.nextInt(validEvents.length)];
      }
    }

    final updatedChar = char.copyWith(
      currentAge: newAge,
      educationLevel: eduLevel,
      currentSalary: currentSalary,
      bankBalance: balance,
      debt: debt,
      health: health,
      happiness: happiness,
      smarts: (smarts + (newAge <= 22 ? 2 : 0)).clamp(0, 100),
      looks: (looks - (newAge > 45 ? 1 : 0)).clamp(10, 100),
      stress: (stress - 3).clamp(0, 100),
      isAlive: isAlive,
      causeOfDeath: causeOfDeath,
      ageOfDeath: ageOfDeath,
      yearsInCurrentJob: currentSalary != null ? char.yearsInCurrentJob + 1 : 0,
    );

    final updatedState = state.copyWith(
      character: updatedChar,
      npcs: updatedNpcs,
      properties: updatedProps,
      investments: updatedInvs,
      logs: newLogs,
      pendingEvent: selectedEvent,
    );

    // Salvar automaticamente no SQLite Drift
    await dbService.saveFullLife(
      saveId: updatedState.saveId,
      slotName: updatedState.slotName,
      generation: updatedState.generation,
      character: updatedState.character,
      npcs: updatedState.npcs,
      properties: updatedState.properties,
      investments: updatedState.investments,
      logs: updatedState.logs,
    );

    return updatedState;
  }

  // Gera marco anual garantido para cada idade
  LifeLog _generateYearlyLifeMilestone(int age, int year, String saveId, CharacterModel char) {
    String text;
    String icon = 'cake';
    String color = '#10B981';

    if (age == 1) {
      text = 'Você completou 1 ano! Começou a dar os primeiros passos firmes e falar "mama" e "papa".';
      icon = 'child_care';
      color = '#3B82F6';
    } else if (age == 2) {
      text = 'Você completou 2 anos! Sua curiosidade não para e seu brinquedo favorito é um carrinho de madeira.';
      icon = 'toys';
    } else if (age == 3) {
      text = 'Você completou 3 anos! Começou a formar frases completas e adora ouvir histórias antes de dormir.';
    } else if (age == 4) {
      text = 'Você completou 4 anos! Aprendeu a desenhar rabiscos coloridos e a reconhecer cores primárias.';
    } else if (age == 5) {
      text = 'Você completou 5 anos! Seus dentes de leite estão firmes e você ama correr no quintal.';
    } else if (age >= 6 && age <= 14) {
      final grades = ['ótimas notas', 'bom rendimento', 'notas excelentes', 'muita dedicação'][_rng.nextInt(4)];
      text = 'Idade $age anos: Mais um ano escolar concluído com $grades e novos amigos na turma.';
      icon = 'school';
      color = '#6366F1';
    } else if (age >= 15 && age <= 17) {
      text = 'Idade $age anos: A fase do Ensino Médio está a todo vapor com projetos, festas e planos pro futuro.';
      icon = 'local_library';
      color = '#8B5CF6';
    } else if (age == 18) {
      text = 'Idade 18 anos: Maioridade conquistada! Você agora tem autonomia total sobre seu destino e escolhas.';
      icon = 'stars';
      color = '#F59E0B';
    } else if (age >= 19 && age <= 29) {
      text = 'Idade $age anos: Juventude vibrante! Você viveu experiências marcantes e buscou seu lugar no mundo.';
      icon = 'bolt';
      color = '#00F2FE';
    } else if (age >= 30 && age <= 59) {
      text = 'Idade $age anos: Ano de maturidade pessoal, estabilidade e planejamento cuidadoso de vida.';
      icon = 'timeline';
      color = '#10B981';
    } else if (age >= 60 && age <= 75) {
      text = 'Idade $age anos: Celebrando a maturidade com tranquilidade, sabedoria acumulada e paz de espírito.';
      icon = 'self_improvement';
      color = '#F59E0B';
    } else {
      text = 'Idade $age anos: Uma bênção de longevidade! Cada amanhecer é um testemunho da sua rica história de vida.';
      icon = 'military_tech';
      color = '#EC4899';
    }

    return LifeLog(
      id: _uuid.v4(),
      saveId: saveId,
      age: age,
      year: year,
      category: 'chronicle',
      textContent: text,
      icon: icon,
      accentColor: color,
      createdAt: DateTime.now(),
    );
  }

  // Gera acontecimento espontâneo da vida
  LifeLog? _generateRandomLifeFlavor(int age, int year, String saveId, List<NpcModel> npcs) {
    final livingNpcs = npcs.where((n) => n.isAlive).toList();

    if (livingNpcs.isNotEmpty && _rng.nextDouble() < 0.45) {
      final npc = livingNpcs[_rng.nextInt(livingNpcs.length)];
      final flavorTemplates = [
        'Seu(Sua) ${npc.relationLabel} ${npc.fullName} preparou seu doce favorito no fim de semana.',
        'Você passou uma tarde divertida rindo e conversando com ${npc.fullName}.',
        '${npc.fullName} te deu um conselho sábio sobre a vida que você guardou no coração.',
        'Você e ${npc.fullName} foram dar um passeio no parque ao pôr do sol.',
      ];
      return LifeLog(
        id: _uuid.v4(),
        saveId: saveId,
        age: age,
        year: year,
        category: 'social',
        textContent: flavorTemplates[_rng.nextInt(flavorTemplates.length)],
        icon: 'favorite_border',
        accentColor: '#EC4899',
        createdAt: DateTime.now(),
      );
    }

    final generalEvents = [
      'Você pegou um resfriado no inverno, mas sarou rápido tomando chá de gengibre com mel.',
      'Você assistiu a um documentário fascinante que abriu sua mente sobre o cosmos.',
      'Você experimentou um prato culinário exótico que surpreendeu positivamente seu paladar.',
      'Você fez uma caminhada matinal sob céu azul e sentiu uma paz revigorante.',
      'Você começou a ouvir uma nova playlist musical que virou a trilha sonora do seu ano.',
      'Você encontrou um livro antigo esquecido na estante e devorou a leitura em três dias.',
    ];

    return LifeLog(
      id: _uuid.v4(),
      saveId: saveId,
      age: age,
      year: year,
      category: 'lifestyle',
      textContent: generalEvents[_rng.nextInt(generalEvents.length)],
      icon: 'auto_awesome',
      accentColor: '#00F2FE',
      createdAt: DateTime.now(),
    );
  }

  // Responder a um evento interativo
  Future<LifeEngineState> makeChoice(LifeEngineState state, EventChoice choice) async {
    final char = state.character;
    final newLogs = List<LifeLog>.from(state.logs);

    audioService.playSfx(choice.moneyDelta >= 0 ? GameSfx.positiveEvent : GameSfx.negativeEvent);

    newLogs.insert(
      0,
      LifeLog(
        id: _uuid.v4(),
        saveId: state.saveId,
        age: char.currentAge,
        year: char.birthYear + char.currentAge,
        category: 'event_result',
        textContent: '${state.pendingEvent?.title ?? "Decisão"}: ${choice.resultText}',
        icon: choice.moneyDelta < 0 ? 'warning' : 'verified',
        accentColor: choice.moneyDelta < 0 ? '#EF4444' : '#10B981',
        createdAt: DateTime.now(),
      ),
    );

    final updatedChar = char.copyWith(
      health: char.health + choice.healthDelta,
      happiness: char.happiness + choice.happinessDelta,
      smarts: char.smarts + choice.smartsDelta,
      looks: char.looks + choice.looksDelta,
      karma: char.karma + choice.karmaDelta,
      stress: char.stress + choice.stressDelta,
      reputation: char.reputation + choice.reputationDelta,
      bankBalance: char.bankBalance + choice.moneyDelta,
    );

    final nextState = state.copyWith(
      character: updatedChar,
      logs: newLogs,
      clearPendingEvent: true,
    );

    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );

    return nextState;
  }

  // Interagir com NPC (Conversar, Elogiar, Discutir, Presentear, Pedir em Namoro, Casar, Ter Filho)
  Future<LifeEngineState> interactWithNpc(LifeEngineState state, String npcId, String action) async {
    final npcIndex = state.npcs.indexWhere((n) => n.id == npcId);
    if (npcIndex == -1) return state;

    final npc = state.npcs[npcIndex];
    int relDelta = 0;
    int happyDelta = 0;
    double moneyCost = 0.0;
    String logText = '';
    String logIcon = 'favorite';
    String accentColor = '#EC4899';
    RelationshipType newRelationType = npc.relationshipType;
    final newNpcs = List<NpcModel>.from(state.npcs);

    switch (action) {
      case 'talk':
        relDelta = 8 + _rng.nextInt(8);
        happyDelta = 6;
        logText = 'Você bateu um papo sincero e caloroso com ${npc.fullName}.';
        logIcon = 'chat_bubble';
        accentColor = '#3B82F6';
        audioService.playSfx(GameSfx.buttonTap);
        break;

      case 'compliment':
        relDelta = 10 + _rng.nextInt(10);
        happyDelta = 8;
        logText = 'Você fez um elogio carinhoso a ${npc.fullName}, que abriu um belo sorriso.';
        logIcon = 'thumb_up';
        accentColor = '#10B981';
        audioService.playSfx(GameSfx.positiveEvent);
        break;

      case 'argue':
        relDelta = -18 - _rng.nextInt(10);
        happyDelta = -12;
        logText = 'Você teve uma discussão exaltada com ${npc.fullName}. O clima ficou tenso!';
        logIcon = 'error';
        accentColor = '#EF4444';
        audioService.playSfx(GameSfx.negativeEvent);
        break;

      case 'gift':
        if (state.character.bankBalance >= 150) {
          moneyCost = 150.0;
          relDelta = 22 + _rng.nextInt(12);
          happyDelta = 14;
          logText = 'Você presenteou ${npc.fullName} com uma linda lembrança. Eles adoraram!';
          logIcon = 'card_giftcard';
          accentColor = '#F59E0B';
          audioService.playSfx(GameSfx.moneyLoss);
        } else {
          return state;
        }
        break;

      case 'strengthenBond':
        if (state.character.bankBalance >= 200) {
          moneyCost = 200.0;
          relDelta = 25;
          happyDelta = 18;
          logText = 'Você fez um passeio especial inesquecível com ${npc.fullName}, fortalecendo o vínculo.';
          logIcon = 'diversity_1';
          accentColor = '#00F2FE';
          audioService.playSfx(GameSfx.positiveEvent);
        } else {
          return state;
        }
        break;

      case 'apologize':
        relDelta = 18;
        happyDelta = 5;
        logText = 'Você teve a humildade de pedir desculpas a ${npc.fullName}. A paz foi restaurada.';
        logIcon = 'handshake';
        accentColor = '#10B981';
        audioService.playSfx(GameSfx.positiveEvent);
        break;

      case 'startDating':
        if (npc.relationshipLevel >= 60 && state.character.currentAge >= 14) {
          relDelta = 25;
          happyDelta = 25;
          newRelationType = RelationshipType.partner;
          logText = 'Parabéns! Você se declarou e agora você e ${npc.fullName} estão namorando! ❤️';
          logIcon = 'favorite';
          accentColor = '#EC4899';
          audioService.playSfx(GameSfx.wedding);
        } else {
          relDelta = -5;
          logText = '${npc.fullName} disse que te admira muito, mas prefere manter só a amizade por enquanto.';
          logIcon = 'heart_broken';
          accentColor = '#EF4444';
          audioService.playSfx(GameSfx.negativeEvent);
        }
        break;

      case 'breakUp':
        relDelta = -40;
        happyDelta = -20;
        newRelationType = RelationshipType.exPartner;
        logText = 'Você terminou seu relacionamento com ${npc.fullName}. Cada um seguiu seu rumo.';
        logIcon = 'heart_broken';
        accentColor = '#64748B';
        audioService.playSfx(GameSfx.negativeEvent);
        break;

      case 'marry':
        if (npc.relationshipType == RelationshipType.partner && npc.relationshipLevel >= 68) {
          relDelta = 30;
          happyDelta = 35;
          newRelationType = RelationshipType.spouse;
          logText = 'Parabéns! Você se casou com ${npc.fullName} em uma cerimônia inesquecível! 💍';
          logIcon = 'favorite';
          accentColor = '#EC4899';
          audioService.playSfx(GameSfx.wedding);
        } else {
          logText = '${npc.fullName} acha que ainda é cedo para esse grande passo matrimonial.';
          logIcon = 'info';
          accentColor = '#F59E0B';
        }
        break;

      case 'haveBaby':
        if ((npc.relationshipType == RelationshipType.spouse || npc.relationshipType == RelationshipType.partner) && state.character.currentAge >= 18) {
          final babyGender = _rng.nextBool() ? 'male' : 'female';
          final babyName = _randomFirstName(babyGender);
          final baby = NpcModel(
            id: _uuid.v4(),
            saveId: state.saveId,
            firstName: babyName,
            lastName: state.character.lastName,
            gender: babyGender,
            age: 0,
            relationshipType: babyGender == 'male' ? RelationshipType.son : RelationshipType.daughter,
            relationshipLevel: 95,
            respectLevel: 80,
            avatarConfig: AvatarConfig.random(gender: babyGender, rng: _rng),
            occupation: 'Bebê',
            salary: 0,
            netWorth: 0,
          );
          newNpcs.add(baby);
          happyDelta = 35;
          logText = 'Nasceu! Uma linda criança chamada $babyName chegou à família, trazendo infinita felicidade! 👶';
          logIcon = 'child_friendly';
          accentColor = '#10B981';
          audioService.playSfx(GameSfx.birth);
        } else {
          logText = 'Vocês conversaram e decidiram que não é o momento certo para ter filhos.';
          logIcon = 'info';
        }
        break;
    }

    final updatedNpc = npc.copyWith(
      relationshipLevel: npc.relationshipLevel + relDelta,
      relationshipType: newRelationType,
    );
    newNpcs[npcIndex] = updatedNpc;

    final updatedLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: state.character.currentAge,
          year: state.character.birthYear + state.character.currentAge,
          category: 'social',
          textContent: logText,
          icon: logIcon,
          accentColor: accentColor,
          createdAt: DateTime.now(),
        ),
      );

    final updatedChar = state.character.copyWith(
      happiness: state.character.happiness + happyDelta,
      bankBalance: state.character.bankBalance - moneyCost,
      isMarried: newRelationType == RelationshipType.spouse ? true : (newRelationType == RelationshipType.exPartner ? false : state.character.isMarried),
      partnerId: newRelationType == RelationshipType.spouse || newRelationType == RelationshipType.partner ? updatedNpc.id : (newRelationType == RelationshipType.exPartner ? null : state.character.partnerId),
    );

    final nextState = state.copyWith(
      character: updatedChar,
      npcs: newNpcs,
      logs: updatedLogs,
    );

    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );

    return nextState;
  }

  // Candidatar-se a Emprego
  Future<LifeEngineState> applyForJob(LifeEngineState state, CareerModel career) async {
    final char = state.character;
    if (char.currentAge < 16) return state;

    bool passed = true;
    String feedback = '';

    if (char.smarts < career.minSmarts) {
      passed = false;
      feedback = 'Você não atendeu aos critérios intelectuais exigidos na entrevista.';
    }

    final newLogs = List<LifeLog>.from(state.logs);

    if (passed) {
      audioService.playSfx(GameSfx.promotion);
      final newJobLog = LifeLog(
        id: _uuid.v4(),
        saveId: state.saveId,
        age: char.currentAge,
        year: char.birthYear + char.currentAge,
        category: 'career',
        textContent: 'Você foi contratado como ${career.title} com salário de R\$ ${career.entrySalary.toStringAsFixed(2)}/ano!',
        icon: 'work',
        accentColor: '#10B981',
        createdAt: DateTime.now(),
      );
      newLogs.insert(0, newJobLog);

      final updatedChar = char.copyWith(
        currentJobId: career.id,
        currentJobTitle: career.title,
        currentSalary: career.entrySalary,
        jobPerformance: 60,
        yearsInCurrentJob: 0,
        happiness: char.happiness + 15,
      );

      final nextState = state.copyWith(character: updatedChar, logs: newLogs);
      await dbService.saveFullLife(
        saveId: nextState.saveId,
        slotName: nextState.slotName,
        generation: nextState.generation,
        character: nextState.character,
        npcs: nextState.npcs,
        properties: nextState.properties,
        investments: nextState.investments,
        logs: nextState.logs,
      );
      return nextState;
    } else {
      audioService.playSfx(GameSfx.negativeEvent);
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'career',
          textContent: 'Candidatura rejeitada para ${career.title}. $feedback',
          icon: 'work_off',
          accentColor: '#EF4444',
          createdAt: DateTime.now(),
        ),
      );
      final nextState = state.copyWith(logs: newLogs);
      return nextState;
    }
  }

  // Trabalhar mais duro
  Future<LifeEngineState> workHard(LifeEngineState state) async {
    final char = state.character;
    if (char.currentJobTitle == null) return state;

    audioService.playSfx(GameSfx.positiveEvent);
    final updatedChar = char.copyWith(
      jobPerformance: (char.jobPerformance + 15).clamp(0, 100),
      stress: (char.stress + 8).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'career',
          textContent: 'Você fez horas extras e impressionou sua liderança no trabalho.',
          icon: 'speed',
          accentColor: '#6366F1',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );
    return nextState;
  }

  // Pedir aumento salarial
  Future<LifeEngineState> askForRaise(LifeEngineState state) async {
    final char = state.character;
    if (char.currentJobTitle == null || char.currentSalary == null) return state;

    final newLogs = List<LifeLog>.from(state.logs);
    final granted = char.jobPerformance >= 70;

    if (granted) {
      final raiseAmount = char.currentSalary! * 0.15;
      final newSalary = char.currentSalary! + raiseAmount;
      audioService.playSfx(GameSfx.promotion);
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'career',
          textContent: 'Sucesso! Seu chefe reconheceu sua dedicação e concedeu 15% de aumento (Novo salário: R\$ ${newSalary.toStringAsFixed(0)}/ano)!',
          icon: 'trending_up',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );
      final updatedChar = char.copyWith(currentSalary: newSalary, happiness: char.happiness + 15);
      final nextState = state.copyWith(character: updatedChar, logs: newLogs);
      await dbService.saveFullLife(
        saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
        character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
        investments: nextState.investments, logs: nextState.logs,
      );
      return nextState;
    } else {
      audioService.playSfx(GameSfx.negativeEvent);
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'career',
          textContent: 'Pedido negado. Sua chefia avisou que você precisa melhorar seu desempenho antes de pedir aumento.',
          icon: 'sentiment_dissatisfied',
          accentColor: '#EF4444',
          createdAt: DateTime.now(),
        ),
      );
      final updatedChar = char.copyWith(happiness: char.happiness - 8, stress: char.stress + 5);
      final nextState = state.copyWith(character: updatedChar, logs: newLogs);
      return nextState;
    }
  }

  // Sair do emprego
  Future<LifeEngineState> quitJob(LifeEngineState state) async {
    final char = state.character;
    if (char.currentJobTitle == null) return state;

    audioService.playSfx(GameSfx.buttonTap);
    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'career',
          textContent: 'Você pediu demissão de ${char.currentJobTitle} e agora está livre no mercado.',
          icon: 'exit_to_app',
          accentColor: '#64748B',
          createdAt: DateTime.now(),
        ),
      );

    final updatedChar = char.copyWith(
      currentJobId: null,
      currentJobTitle: null,
      currentSalary: null,
      jobPerformance: 50,
      yearsInCurrentJob: 0,
      stress: (char.stress - 20).clamp(0, 100),
    );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    return nextState;
  }

  // Comprar Imóvel ou Veículo
  Future<LifeEngineState> buyProperty(LifeEngineState state, PropertyModel property, bool financed) async {
    final char = state.character;
    final cost = financed ? property.purchasePrice * 0.2 : property.purchasePrice;

    if (char.bankBalance < cost) return state;

    final newProperty = property.copyWith(
      saveId: state.saveId,
      isFinanced: financed,
      remainingDebt: financed ? property.purchasePrice * 0.8 : 0.0,
      monthlyPayment: financed ? (property.purchasePrice * 0.8) / (12 * 20) : 0.0,
    );

    final updatedProps = List<PropertyModel>.from(state.properties)..add(newProperty);
    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - cost,
      happiness: char.happiness + 20,
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'finance',
          textContent: 'Você comprou ${property.name} por R\$ ${property.purchasePrice.toStringAsFixed(2)}${financed ? " (financiado)" : " à vista"}!',
          icon: 'home',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(
      character: updatedChar,
      properties: updatedProps,
      logs: newLogs,
    );

    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );

    audioService.playSfx(GameSfx.moneyGain);
    return nextState;
  }

  // Vender Propriedade
  Future<LifeEngineState> sellProperty(LifeEngineState state, String propertyId) async {
    final propIndex = state.properties.indexWhere((p) => p.id == propertyId);
    if (propIndex == -1) return state;

    final prop = state.properties[propIndex];
    final netGain = prop.currentValue - prop.remainingDebt;

    final updatedProps = List<PropertyModel>.from(state.properties)..removeAt(propIndex);
    final updatedChar = state.character.copyWith(bankBalance: state.character.bankBalance + netGain);

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: state.character.currentAge,
          year: state.character.birthYear + state.character.currentAge,
          category: 'finance',
          textContent: 'Você vendeu ${prop.name} por R\$ ${prop.currentValue.toStringAsFixed(2)} e recebeu R\$ ${netGain.toStringAsFixed(2)} líquidos!',
          icon: 'sell',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, properties: updatedProps, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.moneyGain);
    return nextState;
  }

  // Realizar Investimento
  Future<LifeEngineState> investMoney(LifeEngineState state, String type, String name, String ticker, double amount) async {
    final char = state.character;
    if (char.bankBalance < amount) return state;

    final newInv = InvestmentModel(
      id: _uuid.v4(),
      saveId: state.saveId,
      type: type,
      name: name,
      ticker: ticker,
      investedAmount: amount,
      currentValue: amount,
      units: amount / 100.0,
      annualYieldPercent: 10.0,
    );

    final updatedInvs = List<InvestmentModel>.from(state.investments)..add(newInv);
    final updatedChar = char.copyWith(bankBalance: char.bankBalance - amount);

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'finance',
          textContent: 'Você investiu R\$ ${amount.toStringAsFixed(2)} em $name ($ticker).',
          icon: 'savings',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(
      character: updatedChar,
      investments: updatedInvs,
      logs: newLogs,
    );

    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );

    audioService.playSfx(GameSfx.moneyLoss);
    return nextState;
  }

  // Resgatar Investimento
  Future<LifeEngineState> sellInvestment(LifeEngineState state, String investmentId) async {
    final invIndex = state.investments.indexWhere((i) => i.id == investmentId);
    if (invIndex == -1) return state;

    final inv = state.investments[invIndex];
    final returnVal = inv.currentValue;

    final updatedInvs = List<InvestmentModel>.from(state.investments)..removeAt(invIndex);
    final updatedChar = state.character.copyWith(bankBalance: state.character.bankBalance + returnVal);

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: state.character.currentAge,
          year: state.character.birthYear + state.character.currentAge,
          category: 'finance',
          textContent: 'Você resgatou o investimento em ${inv.name} no valor de R\$ ${returnVal.toStringAsFixed(2)}.',
          icon: 'account_balance_wallet',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, investments: updatedInvs, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.moneyGain);
    return nextState;
  }

  // Pagar Dívidas
  Future<LifeEngineState> payDebt(LifeEngineState state, double amount) async {
    final char = state.character;
    if (char.bankBalance < amount || char.debt <= 0) return state;

    final pay = amount.clamp(0.0, char.debt);
    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - pay,
      debt: (char.debt - pay).clamp(0.0, double.infinity),
      creditScore: (char.creditScore + 15).clamp(300, 1000),
      stress: (char.stress - 10).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'finance',
          textContent: 'Você pagou R\$ ${pay.toStringAsFixed(2)} da sua dívida. Seu Score de crédito melhorou!',
          icon: 'check_circle',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.moneyLoss);
    return nextState;
  }

  // --- ATIVIDADES ---

  // Academia / Saúde
  Future<LifeEngineState> goToGym(LifeEngineState state) async {
    final char = state.character;
    final updatedChar = char.copyWith(
      health: (char.health + 8).clamp(0, 100),
      fitness: (char.fitness + 10).clamp(0, 100),
      looks: (char.looks + 4).clamp(0, 100),
      happiness: (char.happiness + 6).clamp(0, 100),
      stress: (char.stress - 10).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'health',
          textContent: 'Treino pago! Você puxou ferro na academia e está com o condicionamento em alta.',
          icon: 'fitness_center',
          accentColor: '#10B981',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.positiveEvent);
    return nextState;
  }

  // Cinema
  Future<LifeEngineState> goToCinema(LifeEngineState state) async {
    final char = state.character;
    if (char.bankBalance < 40) return state;

    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - 40,
      happiness: (char.happiness + 14).clamp(0, 100),
      stress: (char.stress - 12).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'entertainment',
          textContent: 'Você foi ao cinema com um balde de pipoca e assistiu a um filmaço imperdível!',
          icon: 'movie',
          accentColor: '#3B82F6',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.buttonTap);
    return nextState;
  }

  // Consulta Médica
  Future<LifeEngineState> consultDoctor(LifeEngineState state) async {
    final char = state.character;
    if (char.bankBalance < 250) return state;

    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - 250,
      health: (char.health + 20).clamp(0, 100),
      happiness: (char.happiness + 8).clamp(0, 100),
      stress: (char.stress - 15).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'health',
          textContent: 'Consulta de rotina realizada! O médico passou vitaminas e sua saúde deu um salto.',
          icon: 'local_hospital',
          accentColor: '#EF4444',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.positiveEvent);
    return nextState;
  }

  // Fazer Compras
  Future<LifeEngineState> shoppingSpree(LifeEngineState state) async {
    final char = state.character;
    if (char.bankBalance < 350) return state;

    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - 350,
      happiness: (char.happiness + 22).clamp(0, 100),
      looks: (char.looks + 8).clamp(0, 100),
      stress: (char.stress - 10).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'shopping',
          textContent: 'Dia de shopping! Você renovou o guarda-roupa com roupas estilosas e modernas.',
          icon: 'shopping_bag',
          accentColor: '#EC4899',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.moneyLoss);
    return nextState;
  }

  // Adotar Pet
  Future<LifeEngineState> adoptPet(LifeEngineState state, String petType, String petName) async {
    final char = state.character;
    final updatedChar = char.copyWith(
      happiness: (char.happiness + 28).clamp(0, 100),
      stress: (char.stress - 20).clamp(0, 100),
      karma: (char.karma + 15).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'pets',
          textContent: 'Você adotou um(a) $petType chamado(a) "$petName"! Sua casa agora está cheia de carinho e lambidas.',
          icon: 'pets',
          accentColor: '#F59E0B',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.positiveEvent);
    return nextState;
  }

  // Praticar Hobby
  Future<LifeEngineState> practiceHobby(LifeEngineState state, String hobbyName) async {
    final char = state.character;
    final updatedChar = char.copyWith(
      happiness: (char.happiness + 15).clamp(0, 100),
      smarts: (char.smarts + 5).clamp(0, 100),
      stress: (char.stress - 15).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'hobbies',
          textContent: 'Você dedicou a tarde praticando $hobbyName. Foi uma experiência muito prazerosa!',
          icon: 'palette',
          accentColor: '#8B5CF6',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.positiveEvent);
    return nextState;
  }

  // Férias e Descanso
  Future<LifeEngineState> restAndVacation(LifeEngineState state) async {
    final char = state.character;
    if (char.bankBalance < 1200) return state;

    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - 1200,
      happiness: (char.happiness + 35).clamp(0, 100),
      health: (char.health + 10).clamp(0, 100),
      stress: (char.stress - 35).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'lifestyle',
          textContent: 'Férias dos sonhos! Você viajou para um resort paradisíaco e voltou com as energias 100% recarregadas.',
          icon: 'flight_takeoff',
          accentColor: '#00F2FE',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.achievement);
    return nextState;
  }

  // Redes Sociais
  Future<LifeEngineState> postOnSocialMedia(LifeEngineState state) async {
    final char = state.character;
    final viral = _rng.nextDouble() < 0.35;
    final fameGain = viral ? 20 : 4;

    final updatedChar = char.copyWith(
      fame: (char.fame + fameGain).clamp(0, 100),
      happiness: (char.happiness + (viral ? 20 : 8)).clamp(0, 100),
      reputation: (char.reputation + (viral ? 15 : 2)).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'social_media',
          textContent: viral
              ? '🔥 SEU POST VIRALIZOU! O algoritmo te impulsionou e você ganhou mais de 50 mil novos seguidores!'
              : 'Você postou fotos nas redes sociais e recebeu centenas de curtidas e elogios dos amigos.',
          icon: 'share',
          accentColor: '#EC4899',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(viral ? GameSfx.achievement : GameSfx.positiveEvent);
    return nextState;
  }

  // Loteria / Mega-Sena Fictícia
  Future<LifeEngineState> playLotteryDraw(LifeEngineState state, List<int> chosenNumbers) async {
    final char = state.character;
    const ticketCost = 5.0;
    if (char.bankBalance < ticketCost) return state;

    // Sorteio real de 6 dezenas distintas entre 1 e 60
    final drawNumbers = <int>{};
    while (drawNumbers.length < 6) {
      drawNumbers.add(1 + _rng.nextInt(60));
    }

    final hits = chosenNumbers.where((n) => drawNumbers.contains(n)).length;
    double prize = 0.0;
    String resultTitle = '';

    if (hits == 6) {
      prize = 12500000.0; // Jackpot Histórico!
      resultTitle = '🌟 MEGA-SENA BITWEVE! JACKPOT HISTÓRICO! Você acertou todas as 6 dezenas e ganhou R\$ 12.500.000!';
      audioService.playSfx(GameSfx.lotteryWin);
    } else if (hits == 5) {
      prize = 45000.0; // Quina
      resultTitle = '🔥 QUINA NA LOTERIA! Você acertou 5 dezenas e faturou R\$ 45.000,00!';
      audioService.playSfx(GameSfx.achievement);
    } else if (hits == 4) {
      prize = 1800.0; // Quadra
      resultTitle = '🎉 QUADRA! Você acertou 4 dezenas na loteria e ganhou R\$ 1.800,00!';
      audioService.playSfx(GameSfx.positiveEvent);
    } else if (hits == 3) {
      prize = 25.0; // Terno
      resultTitle = 'Quase lá! Você acertou 3 dezenas e recuperou R\$ 25,00.';
      audioService.playSfx(GameSfx.buttonTap);
    } else {
      resultTitle = 'Sorteio realizado: Você acertou $hits dezena(s). Não foi dessa vez, tente novamente!';
      audioService.playSfx(GameSfx.moneyLoss);
    }

    final updatedChar = char.copyWith(
      bankBalance: char.bankBalance - ticketCost + prize,
      happiness: prize > 0 ? (char.happiness + 25).clamp(0, 100) : (char.happiness - 2).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'lottery',
          textContent: resultTitle,
          icon: 'casino',
          accentColor: prize > 0 ? '#F59E0B' : '#64748B',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    return nextState;
  }

  // Praticar Pequeno Delito / Crime
  Future<LifeEngineState> commitPettyCrime(LifeEngineState state) async {
    final char = state.character;
    final caught = _rng.nextDouble() < 0.45;
    final newLogs = List<LifeLog>.from(state.logs);

    if (caught) {
      audioService.playSfx(GameSfx.negativeEvent);
      final updatedChar = char.copyWith(
        happiness: (char.happiness - 25).clamp(0, 100),
        karma: (char.karma - 30).clamp(0, 100),
        stress: (char.stress + 35).clamp(0, 100),
        criminalRecord: true,
        timesArrested: char.timesArrested + 1,
        bankBalance: (char.bankBalance - 500).clamp(0.0, double.infinity),
      );
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'crime',
          textContent: 'A polícia te flagrou em flagrante! Você foi fichado na delegacia e pagou R\$ 500 de fiança.',
          icon: 'policy',
          accentColor: '#EF4444',
          createdAt: DateTime.now(),
        ),
      );
      final nextState = state.copyWith(character: updatedChar, logs: newLogs);
      await dbService.saveFullLife(
        saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
        character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
        investments: nextState.investments, logs: nextState.logs,
      );
      return nextState;
    } else {
      audioService.playSfx(GameSfx.positiveEvent);
      final loot = 300.0 + _rng.nextInt(600);
      final updatedChar = char.copyWith(
        bankBalance: char.bankBalance + loot,
        karma: (char.karma - 15).clamp(0, 100),
        stress: (char.stress + 10).clamp(0, 100),
      );
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'crime',
          textContent: 'Você conseguiu escapar sem ser visto e embolsou R\$ ${loot.toStringAsFixed(2)} ilicitamente.',
          icon: 'security',
          accentColor: '#F59E0B',
          createdAt: DateTime.now(),
        ),
      );
      final nextState = state.copyWith(character: updatedChar, logs: newLogs);
      await dbService.saveFullLife(
        saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
        character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
        investments: nextState.investments, logs: nextState.logs,
      );
      return nextState;
    }
  }

  // Estudar na Biblioteca
  Future<LifeEngineState> studyExtra(LifeEngineState state) async {
    final char = state.character;
    final updatedChar = char.copyWith(
      smarts: (char.smarts + 10).clamp(0, 100),
      discipline: (char.discipline + 8).clamp(0, 100),
      happiness: (char.happiness + 5).clamp(0, 100),
    );

    final newLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: char.currentAge,
          year: char.birthYear + char.currentAge,
          category: 'education',
          textContent: 'Você passou horas na biblioteca devorando livros acadêmicos. Seu intelecto expandiu!',
          icon: 'menu_book',
          accentColor: '#3B82F6',
          createdAt: DateTime.now(),
        ),
      );

    final nextState = state.copyWith(character: updatedChar, logs: newLogs);
    await dbService.saveFullLife(
      saveId: nextState.saveId, slotName: nextState.slotName, generation: nextState.generation,
      character: nextState.character, npcs: nextState.npcs, properties: nextState.properties,
      investments: nextState.investments, logs: nextState.logs,
    );
    audioService.playSfx(GameSfx.positiveEvent);
    return nextState;
  }

  // Continuar com Herdeiro (Próxima Geração)
  Future<LifeEngineState> continueAsHeir(LifeEngineState state, String heirId) async {
    final heirNpc = state.npcs.firstWhere((n) => n.id == heirId);
    final inheritedWealth = state.netWorth.clamp(0.0, double.infinity);

    final newSaveId = _uuid.v4();
    final newChar = CharacterModel(
      id: _uuid.v4(),
      saveId: newSaveId,
      firstName: heirNpc.firstName,
      lastName: heirNpc.lastName,
      gender: heirNpc.gender,
      sexualOrientation: 'heterosexual',
      birthYear: state.character.birthYear + (state.character.currentAge - heirNpc.age),
      currentAge: heirNpc.age,
      country: state.character.country,
      city: state.character.city,
      avatarConfig: heirNpc.avatarConfig,
      bankBalance: inheritedWealth,
      health: heirNpc.health,
      happiness: 85,
      smarts: 60,
      looks: 60,
    );

    final firstLog = LifeLog(
      id: _uuid.v4(),
      saveId: newSaveId,
      age: heirNpc.age,
      year: newChar.birthYear + heirNpc.age,
      category: 'milestone',
      textContent: 'Você assumiu o legado de ${state.character.fullName} com um patrimônio de R\$ ${inheritedWealth.toStringAsFixed(2)}!',
      icon: 'military_tech',
      accentColor: '#F59E0B',
      createdAt: DateTime.now(),
    );

    final nextState = LifeEngineState(
      saveId: newSaveId,
      slotName: 'Dinastia: ${newChar.fullName} (Geração ${state.generation + 1})',
      generation: state.generation + 1,
      character: newChar,
      npcs: [],
      properties: [],
      investments: [],
      logs: [firstLog],
    );

    await dbService.saveFullLife(
      saveId: nextState.saveId,
      slotName: nextState.slotName,
      generation: nextState.generation,
      character: nextState.character,
      npcs: nextState.npcs,
      properties: nextState.properties,
      investments: nextState.investments,
      logs: nextState.logs,
    );

    audioService.playSfx(GameSfx.achievement);
    return nextState;
  }

  // Geradores auxiliares de nomes
  String _randomFirstName(String gender) {
    const maleNames = ['Lucas', 'Gabriel', 'Mateus', 'Felipe', 'Enzo', 'Leonardo', 'Thiago', 'Rafael', 'Bruno', 'Arthur', 'Rodrigo', 'Gustavo'];
    const femaleNames = ['Sophia', 'Isabella', 'Julia', 'Mariana', 'Beatriz', 'Camila', 'Larissa', 'Helena', 'Alice', 'Manuela', 'Carolina', 'Amanda'];
    final list = gender == 'female' ? femaleNames : maleNames;
    return list[_rng.nextInt(list.length)];
  }

  String _randomLastName() {
    const lastNames = ['Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes', 'Costa', 'Ribeiro', 'Martins', 'Carvalho'];
    return lastNames[_rng.nextInt(lastNames.length)];
  }

  String _randomCommonJob() {
    const jobs = ['Contador(a)', 'Professor(a)', 'Comerciante', 'Enfermeiro(a)', 'Vendedor(a)', 'Engenheiro(a)', 'Administrador(a)', 'Advogado(a)', 'Eletricista', 'Gerente'];
    return jobs[_rng.nextInt(jobs.length)];
  }

  Future<void> _persistState(LifeEngineState state) async {
    await dbService.saveFullLife(
      saveId: state.saveId,
      slotName: state.slotName,
      generation: state.generation,
      character: state.character,
      npcs: state.npcs,
      properties: state.properties,
      investments: state.investments,
      logs: state.logs,
    );
  }

  // ==========================================
  // MÓDULO DE SAÚDE AVANÇADA
  // ==========================================
  Future<LifeEngineState> toggleHealthInsurance(LifeEngineState state) async {
    final current = _healthInsurance[state.saveId] ?? false;
    _healthInsurance[state.saveId] = !current;
    audioService.playSfx(GameSfx.buttonTap);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: !current
          ? 'Você contratou um Plano de Saúde Privado (R\$ 320/ano).'
          : 'Você cancelou seu Plano de Saúde Privado.',
      icon: 'health_and_safety',
      accentColor: !current ? '#10B981' : '#F59E0B',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(logs: [log, ...state.logs]);
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> consultPublicHealth(LifeEngineState state) async {
    audioService.playSfx(GameSfx.buttonTap);
    final improvedHealth = (state.character.health + 4).clamp(0, 100);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Você foi atendido na rede pública (SUS). O médico realizou triagem, aferiu seus sinais vitais e orientou cuidados gerais.',
      icon: 'local_hospital',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(health: improvedHealth),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> consultGeneralPractitioner(LifeEngineState state) async {
    final hasIns = _healthInsurance[state.saveId] ?? false;
    final cost = hasIns ? 0.0 : 220.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(cost > 0 ? GameSfx.moneyLoss : GameSfx.buttonTap);
    final improvedHealth = (state.character.health + 8).clamp(0, 100);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Checkup com Clínico Geral Particular: Exames básicos concluídos e prescrições preventivas atualizadas.',
      icon: 'medical_services',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        health: improvedHealth,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> consultPsychologist(LifeEngineState state) async {
    final hasIns = _healthInsurance[state.saveId] ?? false;
    final cost = hasIns ? 0.0 : 160.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(cost > 0 ? GameSfx.moneyLoss : GameSfx.buttonTap);
    final newHappy = (state.character.happiness + 12).clamp(0, 100);
    final newStress = (state.character.stress - 15).clamp(0, 100);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Sessão de Psicoterapia: Você conversou com o psicólogo sobre suas metas e angústias. Reduziu o estresse e se sente mais resiliente.',
      icon: 'psychology',
      accentColor: '#3B82F6',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        happiness: newHappy,
        stress: newStress,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> consultPsychiatrist(LifeEngineState state) async {
    final hasIns = _healthInsurance[state.saveId] ?? false;
    final cost = hasIns ? 0.0 : 380.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(cost > 0 ? GameSfx.moneyLoss : GameSfx.buttonTap);
    final active = _activeConditions.putIfAbsent(state.saveId, () => []);
    String resultMsg = 'Avaliação Neuropsiquiátrica Concluída: Seu perfil comportamental e emocional foi analisado com rigor.';

    if (active.isEmpty && _rng.nextDouble() < 0.60) {
      final catalog = HealthCatalog.conditions;
      final selected = catalog[_rng.nextInt(catalog.length)].copyWith(
        isDiagnosed: true,
        diagnosedAge: state.character.currentAge,
        treatmentState: TreatmentState.medication,
      );
      active.add(selected);
      resultMsg = 'Diagnóstico Clínico Cuidadoso: Você recebeu a identificação de ${selected.name}. Com suporte adequado (${selected.supportNeeds}), sua qualidade de vida evoluirá muito bem!';
    }

    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: resultMsg,
      icon: 'biotech',
      accentColor: '#8B5CF6',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        happiness: (state.character.happiness + 5).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> consultCardiologist(LifeEngineState state) async {
    final hasIns = _healthInsurance[state.saveId] ?? false;
    final cost = hasIns ? 0.0 : 290.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(cost > 0 ? GameSfx.moneyLoss : GameSfx.buttonTap);
    final newHealth = (state.character.health + 6).clamp(0, 100);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Consulta Cardiológica: Eletrocardiograma e teste ergométrico realizados com sucesso.',
      icon: 'monitor_heart',
      accentColor: '#EF4444',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        health: newHealth,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> buyPrescribedMedicine(LifeEngineState state) async {
    final active = _activeConditions[state.saveId] ?? [];
    if (active.isEmpty) return state;

    const cost = 85.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(GameSfx.moneyLoss);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Farmácia: Você comprou seus medicamentos prescritos para o trimestre.',
      icon: 'medication',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        health: (state.character.health + 5).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> treatSpecificCondition(LifeEngineState state, String conditionId) async {
    final active = _activeConditions[state.saveId] ?? [];
    final idx = active.indexWhere((c) => c.id == conditionId);
    if (idx == -1) return state;

    final c = active[idx];
    active[idx] = c.copyWith(treatmentState: TreatmentState.underControl);
    audioService.playSfx(GameSfx.positiveEvent);

    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'health',
      textContent: 'Você tomou a dose terapêutica para ${c.name}. Seus sintomas estão plenamente estabilizados.',
      icon: 'healing',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        health: (state.character.health + 6).clamp(0, 100),
        happiness: (state.character.happiness + 5).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  // ==========================================
  // MÓDULO DE CRIPTOMOEDAS
  // ==========================================
  Future<LifeEngineState> buyCrypto(LifeEngineState state, String symbol, double amountBRL) async {
    if (state.character.bankBalance < amountBRL || amountBRL <= 0) return state;

    final wallet = getCryptoWallet(state.saveId);
    final idx = wallet.indexWhere((a) => a.symbol == symbol);
    if (idx == -1) return state;

    final asset = wallet[idx];
    final unitsPurchased = amountBRL / asset.currentPrice;
    wallet[idx] = asset.copyWith(ownedUnits: asset.ownedUnits + unitsPurchased);

    audioService.playSfx(GameSfx.moneyLoss);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'finances',
      textContent: 'Compra Cripto: Você investiu R\$ ${amountBRL.toStringAsFixed(2)} e recebeu ${unitsPurchased.toStringAsFixed(6)} $symbol.',
      icon: 'currency_bitcoin',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - amountBRL,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> sellCrypto(LifeEngineState state, String symbol, double amountBRL) async {
    final wallet = getCryptoWallet(state.saveId);
    final idx = wallet.indexWhere((a) => a.symbol == symbol);
    if (idx == -1) return state;

    final asset = wallet[idx];
    if (asset.totalValue <= 0) return state;

    final actualBRL = amountBRL.clamp(0.0, asset.totalValue);
    final unitsSold = actualBRL / asset.currentPrice;
    wallet[idx] = asset.copyWith(ownedUnits: (asset.ownedUnits - unitsSold).clamp(0.0, double.infinity));

    audioService.playSfx(GameSfx.moneyGain);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'finances',
      textContent: 'Venda Cripto: Você resgatou ${unitsSold.toStringAsFixed(6)} $symbol e creditou R\$ ${actualBRL.toStringAsFixed(2)} no seu banco.',
      icon: 'currency_bitcoin',
      accentColor: '#F59E0B',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance + actualBRL,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  // ==========================================
  // MÓDULO DE VEÍCULOS & GARAGEM
  // ==========================================
  Future<LifeEngineState> buyVehicle(LifeEngineState state, VehicleModel v) async {
    if (state.character.bankBalance < v.purchasePrice) return state;

    final vehicles = _ownedVehicles.putIfAbsent(state.saveId, () => []);
    final newVehicle = v.copyWith(id: _uuid.v4());
    vehicles.add(newVehicle);

    audioService.playSfx(GameSfx.moneyLoss);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'assets',
      textContent: 'Garagem Nova: Você comprou um ${v.name} por R\$ ${v.purchasePrice.toStringAsFixed(2)}!',
      icon: 'directions_car',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - v.purchasePrice,
        happiness: (state.character.happiness + 15).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> serviceVehicle(LifeEngineState state, String vehicleId) async {
    const cost = 600.0;
    if (state.character.bankBalance < cost) return state;

    final vehicles = _ownedVehicles[state.saveId] ?? [];
    final idx = vehicles.indexWhere((v) => v.id == vehicleId);
    if (idx == -1) return state;

    vehicles[idx] = vehicles[idx].copyWith(conditionPercent: 100);
    audioService.playSfx(GameSfx.moneyLoss);

    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'assets',
      textContent: 'Revisão Mecânica: Você fez a manutenção preventiva do ${vehicles[idx].name}. Condição restaurada em 100%.',
      icon: 'build',
      accentColor: '#3B82F6',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> sellVehicle(LifeEngineState state, String vehicleId) async {
    final vehicles = _ownedVehicles[state.saveId] ?? [];
    final idx = vehicles.indexWhere((v) => v.id == vehicleId);
    if (idx == -1) return state;

    final v = vehicles[idx];
    final saleValue = v.currentValue;
    vehicles.removeAt(idx);

    audioService.playSfx(GameSfx.moneyGain);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'assets',
      textContent: 'Você vendeu seu ${v.name} e recebeu R\$ ${saleValue.toStringAsFixed(2)}.',
      icon: 'monetization_on',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance + saleValue,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  // ==========================================
  // MÓDULO DE EMPREENDEDORISMO & EMPRESAS
  // ==========================================
  Future<LifeEngineState> startBusiness(LifeEngineState state, String name, String industry) async {
    double startupCapital = 25000.0;
    if (industry == 'restaurant') startupCapital = 40000.0;
    if (industry == 'digital_agency') startupCapital = 12000.0;
    if (industry == 'retail_store') startupCapital = 18000.0;

    if (state.character.bankBalance < startupCapital) return state;

    final businesses = _businesses.putIfAbsent(state.saveId, () => []);
    final newBiz = BusinessModel(
      id: _uuid.v4(),
      saveId: state.saveId,
      name: name,
      industry: industry,
      valuation: startupCapital * 1.5,
      revenue: startupCapital * 1.2,
      expenses: startupCapital * 0.8,
      employeeCount: 3,
    );
    businesses.add(newBiz);

    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'business',
      textContent: 'Você fundou sua empresa "$name" com capital de R\$ ${startupCapital.toStringAsFixed(2)}! Você agora é Presidente/CEO.',
      icon: 'business_center',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - startupCapital,
        happiness: (state.character.happiness + 15).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> hireEmployees(LifeEngineState state, String businessId) async {
    final businesses = _businesses[state.saveId] ?? [];
    final idx = businesses.indexWhere((b) => b.id == businessId);
    if (idx == -1) return state;

    final b = businesses[idx];
    businesses[idx] = b.copyWith(
      employeeCount: b.employeeCount + 2,
      revenue: b.revenue + 15000.0,
      expenses: b.expenses + 9000.0,
      valuation: b.valuation + 20000.0,
    );
    audioService.playSfx(GameSfx.buttonTap);

    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'business',
      textContent: 'Você contratou 2 novos talentos para "${b.name}". A capacidade de faturamento da empresa aumentou!',
      icon: 'group_add',
      accentColor: '#3B82F6',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(logs: [log, ...state.logs]);
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> investMarketing(LifeEngineState state, String businessId) async {
    const cost = 2000.0;
    if (state.character.bankBalance < cost) return state;

    final businesses = _businesses[state.saveId] ?? [];
    final idx = businesses.indexWhere((b) => b.id == businessId);
    if (idx == -1) return state;

    final b = businesses[idx];
    businesses[idx] = b.copyWith(
      revenue: b.revenue + 8000.0,
      reputation: (b.reputation + 8).clamp(0, 100),
      valuation: b.valuation + 12000.0,
    );
    audioService.playSfx(GameSfx.moneyLoss);

    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'business',
      textContent: 'Campanha de Marketing: Você investiu R\$ 2.000 em tráfego e mídia para "${b.name}". A atração de clientes aumentou!',
      icon: 'campaign',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> sellBusiness(LifeEngineState state, String businessId) async {
    final businesses = _businesses[state.saveId] ?? [];
    final idx = businesses.indexWhere((b) => b.id == businessId);
    if (idx == -1) return state;

    final b = businesses[idx];
    final saleValue = b.valuation;
    businesses.removeAt(idx);

    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'business',
      textContent: 'Exit de Sucesso! Você vendeu sua participação em "${b.name}" por R\$ ${saleValue.toStringAsFixed(2)}!',
      icon: 'monetization_on',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance + saleValue,
        fame: (state.character.fame + 15).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  // ==========================================
  // MÓDULO DE CRIME & JUSTIÇA
  // ==========================================
  Future<LifeEngineState> attemptCrime(LifeEngineState state, String crimeId) async {
    double reward = 200.0;
    double failureRisk = 0.25;
    String crimeName = 'Furto em loja';

    if (crimeId == 'digital_fraud') {
      reward = 2500.0;
      failureRisk = 0.40;
      crimeName = 'Golpe Digital';
    } else if (crimeId == 'smuggling') {
      reward = 12000.0;
      failureRisk = 0.60;
      crimeName = 'Contrabando de Carga';
    } else if (crimeId == 'white_collar') {
      reward = 65000.0;
      failureRisk = 0.75;
      crimeName = 'Desvio Corporativo';
    }

    final isCaught = _rng.nextDouble() < failureRisk;
    if (isCaught) {
      audioService.playSfx(GameSfx.negativeEvent);
      final log = LifeLog(
        id: _uuid.v4(),
        saveId: state.saveId,
        age: state.character.currentAge,
        year: state.character.birthYear + state.character.currentAge,
        category: 'crime',
        textContent: 'Você foi preso em flagrante pela polícia tentando praticar $crimeName! Ficha criminal autuada e reputação abalada.',
        icon: 'local_police',
        accentColor: '#EF4444',
        createdAt: DateTime.now(),
      );
      final nextState = state.copyWith(
        character: state.character.copyWith(
          criminalRecord: true,
          timesArrested: state.character.timesArrested + 1,
          stress: (state.character.stress + 30).clamp(0, 100),
          happiness: (state.character.happiness - 20).clamp(0, 100),
          reputation: (state.character.reputation - 25).clamp(0, 100),
        ),
        logs: [log, ...state.logs],
      );
      await _persistState(nextState);
      return nextState;
    } else {
      audioService.playSfx(GameSfx.moneyGain);
      final log = LifeLog(
        id: _uuid.v4(),
        saveId: state.saveId,
        age: state.character.currentAge,
        year: state.character.birthYear + state.character.currentAge,
        category: 'crime',
        textContent: 'Você concluiu com sucesso a ação de $crimeName e embolsou R\$ ${reward.toStringAsFixed(2)}.',
        icon: 'vpn_key',
        accentColor: '#F59E0B',
        createdAt: DateTime.now(),
      );
      final nextState = state.copyWith(
        character: state.character.copyWith(
          bankBalance: state.character.bankBalance + reward,
          karma: (state.character.karma - 10).clamp(0, 100),
        ),
        logs: [log, ...state.logs],
      );
      await _persistState(nextState);
      return nextState;
    }
  }

  Future<LifeEngineState> appealCriminalRecord(LifeEngineState state) async {
    const cost = 15000.0;
    if (state.character.bankBalance < cost) return state;

    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'justice',
      textContent: 'Julgamento de Recurso Especial: Sua banca de advogados obteve a anulação da condenação. Ficha criminal limpa!',
      icon: 'gavel',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance - cost,
        criminalRecord: false,
        reputation: (state.character.reputation + 20).clamp(0, 100),
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  // ==========================================
  // MÓDULO DEUS (GOD MODE)
  // ==========================================
  Future<LifeEngineState> godModeAddMoney(LifeEngineState state, double amount) async {
    audioService.playSfx(GameSfx.moneyGain);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'god_mode',
      textContent: '⚡ Modo Deus: R\$ ${amount.toStringAsFixed(2)} materializados no seu saldo bancário!',
      icon: 'bolt',
      accentColor: '#F59E0B',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance + amount,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> godModeSetStats(
    LifeEngineState state, {
    int? health,
    int? happiness,
    int? smarts,
    int? looks,
  }) async {
    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'god_mode',
      textContent: '⚡ Modo Deus: Seus atributos corporais e mentais foram reconfigurados divinamente.',
      icon: 'auto_awesome',
      accentColor: '#F59E0B',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        health: health ?? state.character.health,
        happiness: happiness ?? state.character.happiness,
        smarts: smarts ?? state.character.smarts,
        looks: looks ?? state.character.looks,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> godModeCureAll(LifeEngineState state) async {
    _activeConditions[state.saveId] = [];
    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'god_mode',
      textContent: '⚡ Modo Deus: Milagre da Cura Total! Todas as enfermidades foram erradicadas e sua saúde restaurada em 100%.',
      icon: 'healing',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(health: 100, stress: 0),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> godModeClearRecord(LifeEngineState state) async {
    audioService.playSfx(GameSfx.achievement);
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'god_mode',
      textContent: '⚡ Modo Deus: Ficha criminal expurgada da existência.',
      icon: 'cleaning_services',
      accentColor: '#10B981',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(criminalRecord: false, timesArrested: 0),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }

  Future<LifeEngineState> godModeJackpot(LifeEngineState state) async {
    audioService.playSfx(GameSfx.lotteryWin);
    const jackpot = 12500000.0;
    final log = LifeLog(
      id: _uuid.v4(),
      saveId: state.saveId,
      age: state.character.currentAge,
      year: state.character.birthYear + state.character.currentAge,
      category: 'god_mode',
      textContent: '⚡ Modo Deus: Sorteio Alterado! Você acertou todas as dezenas e faturou R\$ 12.500.000,00 da Mega-Sena!',
      icon: 'casino',
      accentColor: '#F59E0B',
      createdAt: DateTime.now(),
    );
    final nextState = state.copyWith(
      character: state.character.copyWith(
        bankBalance: state.character.bankBalance + jackpot,
        happiness: 100,
      ),
      logs: [log, ...state.logs],
    );
    await _persistState(nextState);
    return nextState;
  }
}


