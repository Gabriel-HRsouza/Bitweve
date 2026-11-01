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

  List<CareerModel> get availableCareers => _cachedCareers;
  List<DegreeModel> get availableDegrees => _cachedDegrees;
  List<Map<String, dynamic>> get availableCountries => _cachedCountries;

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

      if (newNpcAge > 70) {
        npcHealth = (npcHealth - _rng.nextInt(6)).clamp(0, 100);
        // Risco de falecimento por idade
        final deathProb = (newNpcAge - 65) * 0.02;
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
          final inheritance = (npc.netWorth * 0.7).clamp(1000.0, 500000.0);
          char.copyWith(bankBalance: char.bankBalance + inheritance);
          newLogs.insert(
            0,
            LifeLog(
              id: _uuid.v4(),
              saveId: state.saveId,
              age: newAge,
              year: newYear,
              category: 'finance',
              textContent: 'Você herdou R\$ ${inheritance.toStringAsFixed(2)} de ${npc.fullName}.',
              icon: 'attach_money',
              accentColor: '#10B981',
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      updatedNpcs.add(npc.copyWith(age: newNpcAge, health: npcHealth, isAlive: npcAlive, causeOfDeath: causeOfDeath));
    }

    // 2. Sistema Escolar e Universitário
    String eduLevel = char.educationLevel;
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
          textContent: 'Você começou a frequentar a Escola de Ensino Fundamental!',
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
          textContent: 'Você concluiu o fundamental e ingressou no Ensino Médio!',
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
    double balance = char.bankBalance;
    double debt = char.debt;
    int stress = char.stress;
    int perf = char.jobPerformance;

    if (char.currentSalary != null && char.currentSalary! > 0) {
      final grossSalary = char.currentSalary!;
      final tax = grossSalary * 0.18;
      final netSalary = grossSalary - tax;
      balance += netSalary;

      // Avaliação de promoção por desempenho
      if (perf > 75 && _rng.nextDouble() < 0.3) {
        final raise = grossSalary * 0.15;
        char.copyWith(currentSalary: grossSalary + raise);
        audioService.playSfx(GameSfx.promotion);
        newLogs.insert(
          0,
          LifeLog(
            id: _uuid.v4(),
            saveId: state.saveId,
            age: newAge,
            year: newYear,
            category: 'career',
            textContent: 'Excelente desempenho! Você foi promovido e recebeu aumento de 15%!',
            icon: 'trending_up',
            accentColor: '#10B981',
            createdAt: DateTime.now(),
          ),
        );
      }
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
      // Valorização imobiliária ou desvalorização de veículos
      double newValue = p.currentValue;
      if (p.isRealEstate) {
        newValue *= (1.0 + (_rng.nextDouble() * 0.08 - 0.02)); // Imóvel sobe em média
      } else if (p.isVehicle) {
        newValue *= (1.0 - (_rng.nextDouble() * 0.10 + 0.05)); // Veículo deprecia
      }
      updatedProps.add(p.copyWith(remainingDebt: remaining, currentValue: newValue));
    }

    // Rendimentos de Investimentos
    final updatedInvs = <InvestmentModel>[];
    for (final inv in state.investments) {
      double annualReturnRate = 0.0;
      if (inv.type == 'fixed_income') {
        annualReturnRate = 0.105; // 10.5% a.a. seguro
      } else if (inv.type == 'stock') {
        annualReturnRate = (_rng.nextDouble() * 0.35) - 0.10; // -10% a +25%
      } else if (inv.type == 'crypto') {
        annualReturnRate = (_rng.nextDouble() * 0.80) - 0.35; // Alta volatilidade
      }
      final newCurrentVal = inv.currentValue * (1.0 + annualReturnRate);
      updatedInvs.add(inv.copyWith(currentValue: newCurrentVal));
    }

    // 4. Saúde e Longevidade
    int health = char.health;
    int happiness = char.happiness;
    if (newAge > 65) {
      health = (health - (1 + _rng.nextInt(5))).clamp(0, 100);
      happiness = (happiness - _rng.nextInt(3)).clamp(0, 100);
    }
    if (stress > 70) {
      health = (health - 3).clamp(0, 100);
      happiness = (happiness - 5).clamp(0, 100);
    }

    // Verificar Morte
    bool isAlive = true;
    String? causeOfDeath;
    int? ageOfDeath;

    if (health <= 0 || (newAge >= 80 && _rng.nextDouble() < (newAge - 75) * 0.035) || newAge >= 115) {
      isAlive = false;
      ageOfDeath = newAge;
      causeOfDeath = newAge >= 85 ? 'falência de múltiplos órgãos pela velhice' : 'complicações graves de saúde';
      audioService.playSfx(GameSfx.death);
      newLogs.insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: newAge,
          year: newYear,
          category: 'death',
          textContent: 'Você faleceu aos $newAge anos devido a $causeOfDeath.',
          icon: 'dangerous',
          accentColor: '#000000',
          createdAt: DateTime.now(),
        ),
      );
    }

    // 5. Sortear Evento Interativo
    LifeEvent? selectedEvent;
    if (isAlive) {
      final validEvents = _cachedEvents.where((e) => newAge >= e.minAge && newAge <= e.maxAge).toList();
      if (validEvents.isNotEmpty && _rng.nextDouble() < 0.65) {
        selectedEvent = validEvents[_rng.nextInt(validEvents.length)];
      }
    }

    final updatedChar = char.copyWith(
      currentAge: newAge,
      educationLevel: eduLevel,
      bankBalance: balance,
      debt: debt,
      health: health,
      happiness: happiness,
      stress: (stress - 2).clamp(0, 100),
      isAlive: isAlive,
      causeOfDeath: causeOfDeath,
      ageOfDeath: ageOfDeath,
      yearsInCurrentJob: char.currentSalary != null ? char.yearsInCurrentJob + 1 : 0,
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

  // Responder a um evento interativo
  Future<LifeEngineState> makeChoice(LifeEngineState state, EventChoice choice) async {
    final char = state.character;
    final newLogs = List<LifeLog>.from(state.logs);

    newLogs.insert(
      0,
      LifeLog(
        id: _uuid.v4(),
        saveId: state.saveId,
        age: char.currentAge,
        year: char.birthYear + char.currentAge,
        category: 'random',
        textContent: '${state.pendingEvent?.title ?? "Evento"}: ${choice.resultText}',
        icon: 'announcement',
        accentColor: '#8B5CF6',
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

  // Interagir com NPC
  Future<LifeEngineState> interactWithNpc(LifeEngineState state, String npcId, String action) async {
    final npcIndex = state.npcs.indexWhere((n) => n.id == npcId);
    if (npcIndex == -1) return state;

    final npc = state.npcs[npcIndex];
    int relDelta = 0;
    int happyDelta = 0;
    String logText = '';

    switch (action) {
      case 'talk':
        relDelta = 8 + _rng.nextInt(10);
        happyDelta = 5;
        logText = 'Você teve uma conversa agradável com ${npc.fullName}.';
        break;
      case 'compliment':
        relDelta = 10 + _rng.nextInt(12);
        happyDelta = 8;
        logText = 'Você elogiou sinceramente ${npc.fullName}, que abriu um grande sorriso.';
        break;
      case 'gift':
        if (state.character.bankBalance >= 150) {
          relDelta = 20 + _rng.nextInt(15);
          happyDelta = 12;
          logText = 'Você deu um belo presente a ${npc.fullName}, que adorou!';
        } else {
          logText = 'Você não tem dinheiro suficiente para comprar um bom presente.';
          return state;
        }
        break;
      case 'apologize':
        relDelta = 15;
        logText = 'Você pediu desculpas a ${npc.fullName}. A tensão diminuiu.';
        break;
      case 'marry':
        if (npc.relationshipType == RelationshipType.partner && npc.relationshipLevel >= 70) {
          relDelta = 25;
          logText = 'Parabéns! Você se casou com ${npc.fullName} em uma cerimônia emocionante!';
          audioService.playSfx(GameSfx.wedding);
        } else {
          logText = '${npc.fullName} ainda não está pronto(a) para dar esse passo.';
        }
        break;
    }

    final updatedNpc = npc.copyWith(
      relationshipLevel: npc.relationshipLevel + relDelta,
      relationshipType: action == 'marry' && npc.relationshipType == RelationshipType.partner && npc.relationshipLevel >= 70
          ? RelationshipType.spouse
          : npc.relationshipType,
    );

    final updatedNpcs = List<NpcModel>.from(state.npcs)..[npcIndex] = updatedNpc;
    final updatedLogs = List<LifeLog>.from(state.logs)
      ..insert(
        0,
        LifeLog(
          id: _uuid.v4(),
          saveId: state.saveId,
          age: state.character.currentAge,
          year: state.character.birthYear + state.character.currentAge,
          category: 'romance',
          textContent: logText,
          icon: 'favorite',
          accentColor: '#EC4899',
          createdAt: DateTime.now(),
        ),
      );

    final updatedChar = state.character.copyWith(
      happiness: state.character.happiness + happyDelta,
      bankBalance: action == 'gift' ? state.character.bankBalance - 150 : state.character.bankBalance,
      isMarried: action == 'marry' && updatedNpc.relationshipType == RelationshipType.spouse ? true : state.character.isMarried,
      partnerId: action == 'marry' && updatedNpc.relationshipType == RelationshipType.spouse ? updatedNpc.id : state.character.partnerId,
    );

    final nextState = state.copyWith(
      character: updatedChar,
      npcs: updatedNpcs,
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

    final updatedChar = char.copyWith(
      jobPerformance: char.jobPerformance + 15,
      stress: char.stress + 10,
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
          textContent: 'Você fez horas extras e impressionou a liderança no trabalho.',
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

    return nextState;
  }

  // Academia / Saúde
  Future<LifeEngineState> goToGym(LifeEngineState state) async {
    final char = state.character;
    final updatedChar = char.copyWith(
      health: char.health + 8,
      fitness: char.fitness + 10,
      looks: char.looks + 5,
      happiness: char.happiness + 6,
      stress: (char.stress - 8).clamp(0, 100),
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
          textContent: 'Você fez um treino intenso na academia e está se sentindo revigorado!',
          icon: 'fitness_center',
          accentColor: '#10B981',
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
}
