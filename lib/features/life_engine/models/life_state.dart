import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bitweve/features/businesses/models/business_model.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/finances/models/crypto_asset.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/health/models/health_condition.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/dating/models/dating_state.dart';
import 'package:bitweve/features/properties/models/property_meta.dart';
import 'package:bitweve/features/relationships/models/npc_traits.dart';
import 'package:bitweve/features/school/models/school_life.dart';
import 'package:bitweve/features/social_media/models/social_state.dart';
import 'package:bitweve/features/underworld/models/crime_state.dart';

// ---------------------------------------------------------------------------
// Notificações transitórias (toasts) geradas pelo motor
// ---------------------------------------------------------------------------

enum NoticeKind { money, career, social, achievement, mission, purchase, health, fame, event, info, warning, family, education }

class GameNotice {
  final NoticeKind kind;
  final IconData icon;
  final String title;
  final String message;
  final bool celebrate;
  final double? moneyDelta;

  const GameNotice({
    required this.kind,
    required this.icon,
    required this.title,
    this.message = '',
    this.celebrate = false,
    this.moneyDelta,
  });
}

// ---------------------------------------------------------------------------
// Resumo anual (exibido após envelhecer)
// ---------------------------------------------------------------------------

class YearSummary {
  final int age;
  final int year;
  final Map<String, int> statBefore;
  final Map<String, int> statAfter;
  final double moneyBefore;
  final double moneyAfter;
  final double netWorthBefore;
  final double netWorthAfter;
  final List<LifeLog> highlights;
  final List<String> lifeChanges;
  final String? careerLine;
  final int relationshipsDelta;
  final String headline;
  final String subtitle;

  const YearSummary({
    required this.age,
    required this.year,
    required this.statBefore,
    required this.statAfter,
    required this.moneyBefore,
    required this.moneyAfter,
    required this.netWorthBefore,
    required this.netWorthAfter,
    required this.highlights,
    required this.lifeChanges,
    required this.careerLine,
    required this.relationshipsDelta,
    required this.headline,
    required this.subtitle,
  });

  int delta(String stat) => (statAfter[stat] ?? 0) - (statBefore[stat] ?? 0);
}

// ---------------------------------------------------------------------------
// Sub-estruturas persistidas em JSON
// ---------------------------------------------------------------------------

class EducationState {
  /// none | elementary | high_school | hs_graduate | university | postgrad | dropout
  String stage;
  String? degreeId; // curso superior ou pós em andamento
  int yearsDone;
  int yearsTotal;
  double gpa; // 0..10
  double scholarshipPct; // 0..1
  int studyEffort; // ações de estudo no ano corrente
  int failedYears;
  final List<String> completedDegrees; // ids
  final List<String> courses; // ids de cursos livres concluídos

  EducationState({
    this.stage = 'none',
    this.degreeId,
    this.yearsDone = 0,
    this.yearsTotal = 0,
    this.gpa = 7.0,
    this.scholarshipPct = 0,
    this.studyEffort = 0,
    this.failedYears = 0,
    List<String>? completedDegrees,
    List<String>? courses,
  })  : completedDegrees = completedDegrees ?? [],
        courses = courses ?? [];

  bool get inSchool => stage == 'elementary' || stage == 'high_school';
  bool get inHigherEd => stage == 'university' || stage == 'postgrad';
  bool get isStudying => inSchool || inHigherEd;
  bool get hasHighSchool => completedDegrees.contains('high_school');

  Map<String, dynamic> toJson() => {
        'stage': stage,
        'degreeId': degreeId,
        'yearsDone': yearsDone,
        'yearsTotal': yearsTotal,
        'gpa': gpa,
        'scholarshipPct': scholarshipPct,
        'studyEffort': studyEffort,
        'failedYears': failedYears,
        'completedDegrees': completedDegrees,
        'courses': courses,
      };

  factory EducationState.fromJson(Map<String, dynamic> j) => EducationState(
        stage: j['stage'] as String? ?? 'none',
        degreeId: j['degreeId'] as String?,
        yearsDone: j['yearsDone'] as int? ?? 0,
        yearsTotal: j['yearsTotal'] as int? ?? 0,
        gpa: (j['gpa'] as num?)?.toDouble() ?? 7.0,
        scholarshipPct: (j['scholarshipPct'] as num?)?.toDouble() ?? 0,
        studyEffort: j['studyEffort'] as int? ?? 0,
        failedYears: j['failedYears'] as int? ?? 0,
        completedDegrees: (j['completedDegrees'] as List?)?.cast<String>().toList(),
        courses: (j['courses'] as List?)?.cast<String>().toList(),
      );
}

class JobRecord {
  final String title;
  final String company;
  final String trackId;
  final int startAge;
  int? endAge;
  String? reason;
  double salary;

  JobRecord({
    required this.title,
    required this.company,
    required this.trackId,
    required this.startAge,
    this.endAge,
    this.reason,
    required this.salary,
  });

  Map<String, dynamic> toJson() => {
        'title': title, 'company': company, 'trackId': trackId, 'startAge': startAge,
        'endAge': endAge, 'reason': reason, 'salary': salary,
      };

  factory JobRecord.fromJson(Map<String, dynamic> j) => JobRecord(
        title: j['title'] as String? ?? '',
        company: j['company'] as String? ?? '',
        trackId: j['trackId'] as String? ?? '',
        startAge: j['startAge'] as int? ?? 0,
        endAge: j['endAge'] as int?,
        reason: j['reason'] as String?,
        salary: (j['salary'] as num?)?.toDouble() ?? 0,
      );
}

class Loan {
  final String id;
  final String label;
  final double principal;
  double remaining;
  final double rate; // juros a.a.
  final double annualPayment;
  int missedPayments;

  Loan({
    required this.id,
    required this.label,
    required this.principal,
    required this.remaining,
    required this.rate,
    required this.annualPayment,
    this.missedPayments = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'label': label, 'principal': principal, 'remaining': remaining,
        'rate': rate, 'annualPayment': annualPayment, 'missedPayments': missedPayments,
      };

  factory Loan.fromJson(Map<String, dynamic> j) => Loan(
        id: j['id'] as String,
        label: j['label'] as String? ?? 'Empréstimo',
        principal: (j['principal'] as num).toDouble(),
        remaining: (j['remaining'] as num).toDouble(),
        rate: (j['rate'] as num).toDouble(),
        annualPayment: (j['annualPayment'] as num).toDouble(),
        missedPayments: j['missedPayments'] as int? ?? 0,
      );
}

class OwnedItem {
  final String id; // instância
  final String itemId; // catálogo
  final int boughtAtAge;
  final double pricePaid;

  const OwnedItem({required this.id, required this.itemId, required this.boughtAtAge, required this.pricePaid});

  Map<String, dynamic> toJson() => {'id': id, 'itemId': itemId, 'boughtAtAge': boughtAtAge, 'pricePaid': pricePaid};

  factory OwnedItem.fromJson(Map<String, dynamic> j) => OwnedItem(
        id: j['id'] as String,
        itemId: j['itemId'] as String,
        boughtAtAge: j['boughtAtAge'] as int? ?? 0,
        pricePaid: (j['pricePaid'] as num?)?.toDouble() ?? 0,
      );
}

class Pet {
  final String id;
  final String name;
  final String type;
  int age;
  int bond;
  bool alive;

  Pet({required this.id, required this.name, required this.type, this.age = 0, this.bond = 80, this.alive = true});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type, 'age': age, 'bond': bond, 'alive': alive};

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        age: j['age'] as int? ?? 0,
        bond: j['bond'] as int? ?? 80,
        alive: j['alive'] as bool? ?? true,
      );
}

class Sponsorship {
  final String brand;
  final double annualPay;
  int yearsLeft;

  Sponsorship({required this.brand, required this.annualPay, required this.yearsLeft});

  Map<String, dynamic> toJson() => {'brand': brand, 'annualPay': annualPay, 'yearsLeft': yearsLeft};

  factory Sponsorship.fromJson(Map<String, dynamic> j) => Sponsorship(
        brand: j['brand'] as String,
        annualPay: (j['annualPay'] as num).toDouble(),
        yearsLeft: j['yearsLeft'] as int? ?? 1,
      );
}

class Ancestor {
  final String name;
  final int generation;
  final int birthYear;
  final int ageOfDeath;
  final String? job;
  final double netWorth;
  final String avatarJson;

  const Ancestor({
    required this.name,
    required this.generation,
    required this.birthYear,
    required this.ageOfDeath,
    this.job,
    required this.netWorth,
    required this.avatarJson,
  });

  Map<String, dynamic> toJson() => {
        'name': name, 'generation': generation, 'birthYear': birthYear, 'ageOfDeath': ageOfDeath,
        'job': job, 'netWorth': netWorth, 'avatarJson': avatarJson,
      };

  factory Ancestor.fromJson(Map<String, dynamic> j) => Ancestor(
        name: j['name'] as String,
        generation: j['generation'] as int? ?? 1,
        birthYear: j['birthYear'] as int? ?? 2000,
        ageOfDeath: j['ageOfDeath'] as int? ?? 80,
        job: j['job'] as String?,
        netWorth: (j['netWorth'] as num?)?.toDouble() ?? 0,
        avatarJson: j['avatarJson'] as String? ?? '{}',
      );
}

class DailyMissionState {
  String dateKey;
  final List<String> missionIds;
  final Map<String, int> baselines;
  final List<String> claimed;

  DailyMissionState({
    required this.dateKey,
    required this.missionIds,
    required this.baselines,
    required this.claimed,
  });

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey, 'missionIds': missionIds, 'baselines': baselines, 'claimed': claimed,
      };

  factory DailyMissionState.fromJson(Map<String, dynamic> j) => DailyMissionState(
        dateKey: j['dateKey'] as String? ?? '',
        missionIds: (j['missionIds'] as List?)?.cast<String>().toList() ?? [],
        baselines: (j['baselines'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toInt())) ?? {},
        claimed: (j['claimed'] as List?)?.cast<String>().toList() ?? [],
      );
}

/// Todo o estado de jogo que não cabe nas tabelas originais do Drift.
/// É serializado como JSON na tabela `save_extras` (uma linha por vida).
class LifeExtras {
  // Identidade
  int birthDay;
  int birthMonth;
  String personality;
  final List<String> traits;
  String familyWealth; // poor | middle | rich | elite

  // Carreira
  int careerLevel;
  int yearsAtLevel;
  String? company;
  final Map<String, int> experience; // categoria -> anos
  final List<JobRecord> jobHistory;
  bool retired;

  // Educação
  EducationState education;

  // Patrimônio
  final List<VehicleModel> vehicles;
  final List<CryptoAsset> crypto;
  final List<BusinessModel> businesses;
  final List<OwnedItem> inventory;
  final List<Loan> loans;
  final List<String> rentedOut; // ids de imóveis alugados para terceiros
  String? homePropertyId; // imóvel onde mora
  bool movedOut;

  // Saúde
  final List<HealthCondition> conditions;
  bool hasInsurance;

  // Fama
  int followers;
  final List<Sponsorship> sponsorships;
  final List<String> headlines;

  // Vida
  final List<Pet> pets;
  final Map<String, int> counters;
  final List<Ancestor> ancestors;
  final List<String> lifeMissionsClaimed;
  DailyMissionState? daily;
  int lastActionAge; // controla limites de ações por ano
  final Map<String, int> actionsThisYear;

  // Sistemas v3
  SchoolLife school;
  CrimeState crime;
  SocialState social;
  DatingState dating;
  final Map<String, NpcMeta> npcMeta;
  final Map<String, PropertyMeta> propertyMeta;

  LifeExtras({
    this.birthDay = 1,
    this.birthMonth = 1,
    this.personality = 'balanced',
    List<String>? traits,
    this.familyWealth = 'middle',
    this.careerLevel = 0,
    this.yearsAtLevel = 0,
    this.company,
    Map<String, int>? experience,
    List<JobRecord>? jobHistory,
    this.retired = false,
    EducationState? education,
    List<VehicleModel>? vehicles,
    List<CryptoAsset>? crypto,
    List<BusinessModel>? businesses,
    List<OwnedItem>? inventory,
    List<Loan>? loans,
    List<String>? rentedOut,
    this.homePropertyId,
    this.movedOut = false,
    List<HealthCondition>? conditions,
    this.hasInsurance = false,
    this.followers = 0,
    List<Sponsorship>? sponsorships,
    List<String>? headlines,
    List<Pet>? pets,
    Map<String, int>? counters,
    List<Ancestor>? ancestors,
    List<String>? lifeMissionsClaimed,
    this.daily,
    this.lastActionAge = -1,
    Map<String, int>? actionsThisYear,
    SchoolLife? school,
    CrimeState? crime,
    SocialState? social,
    DatingState? dating,
    Map<String, NpcMeta>? npcMeta,
    Map<String, PropertyMeta>? propertyMeta,
  })  : school = school ?? SchoolLife(),
        crime = crime ?? CrimeState(),
        social = social ?? SocialState(),
        dating = dating ?? DatingState(),
        npcMeta = npcMeta ?? {},
        propertyMeta = propertyMeta ?? {},
        traits = traits ?? [],
        experience = experience ?? {},
        jobHistory = jobHistory ?? [],
        education = education ?? EducationState(),
        vehicles = vehicles ?? [],
        crypto = crypto ?? [],
        businesses = businesses ?? [],
        inventory = inventory ?? [],
        loans = loans ?? [],
        rentedOut = rentedOut ?? [],
        conditions = conditions ?? [],
        sponsorships = sponsorships ?? [],
        headlines = headlines ?? [],
        pets = pets ?? [],
        counters = counters ?? {},
        ancestors = ancestors ?? [],
        lifeMissionsClaimed = lifeMissionsClaimed ?? [],
        actionsThisYear = actionsThisYear ?? {};

  int counter(String key) => counters[key] ?? 0;
  void bump(String key, [int by = 1]) => counters[key] = counter(key) + by;

  double get loansTotal => loans.fold(0.0, (s, l) => s + l.remaining);

  /// Meta-dados dinâmicos de um NPC (cria sob demanda).
  NpcMeta meta(String npcId) => npcMeta.putIfAbsent(npcId, () => NpcMeta());
  PropertyMeta propMeta(String id) => propertyMeta.putIfAbsent(id, () => PropertyMeta());

  Map<String, dynamic> toJson() => {
        'v': 3,
        'birthDay': birthDay,
        'birthMonth': birthMonth,
        'personality': personality,
        'traits': traits,
        'familyWealth': familyWealth,
        'careerLevel': careerLevel,
        'yearsAtLevel': yearsAtLevel,
        'company': company,
        'experience': experience,
        'jobHistory': jobHistory.map((e) => e.toJson()).toList(),
        'retired': retired,
        'education': education.toJson(),
        'vehicles': vehicles.map((e) => e.toJson()).toList(),
        'crypto': crypto.map((e) => e.toJson()).toList(),
        'businesses': businesses.map((e) => e.toJson()).toList(),
        'inventory': inventory.map((e) => e.toJson()).toList(),
        'loans': loans.map((e) => e.toJson()).toList(),
        'rentedOut': rentedOut,
        'homePropertyId': homePropertyId,
        'movedOut': movedOut,
        'conditions': conditions.map((e) => e.toJson()).toList(),
        'hasInsurance': hasInsurance,
        'followers': followers,
        'sponsorships': sponsorships.map((e) => e.toJson()).toList(),
        'headlines': headlines,
        'pets': pets.map((e) => e.toJson()).toList(),
        'counters': counters,
        'ancestors': ancestors.map((e) => e.toJson()).toList(),
        'lifeMissionsClaimed': lifeMissionsClaimed,
        'daily': daily?.toJson(),
        'lastActionAge': lastActionAge,
        'actionsThisYear': actionsThisYear,
        'school': school.toJson(),
        'crime': crime.toJson(),
        'social': social.toJson(),
        'dating': dating.toJson(),
        'npcMeta': npcMeta.map((k, v) => MapEntry(k, v.toJson())),
        'propertyMeta': propertyMeta.map((k, v) => MapEntry(k, v.toJson())),
      };

  static T _obj<T>(dynamic raw, T Function(Map<String, dynamic>) f, T Function() empty) {
    if (raw is! Map) return empty();
    try {
      return f(raw.cast<String, dynamic>());
    } catch (_) {
      return empty();
    }
  }

  static Map<String, T> _objMap<T>(dynamic raw, T Function(Map<String, dynamic>) f) {
    if (raw is! Map) return {};
    final out = <String, T>{};
    raw.forEach((k, v) {
      if (v is Map) {
        try {
          out[k.toString()] = f(v.cast<String, dynamic>());
        } catch (_) {}
      }
    });
    return out;
  }

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) {
    if (raw is! List) return [];
    final out = <T>[];
    for (final e in raw) {
      try {
        out.add(f((e as Map).cast<String, dynamic>()));
      } catch (_) {}
    }
    return out;
  }

  static Map<String, int> _intMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }

  factory LifeExtras.fromJson(Map<String, dynamic> j) => LifeExtras(
        birthDay: j['birthDay'] as int? ?? 1,
        birthMonth: j['birthMonth'] as int? ?? 1,
        personality: j['personality'] as String? ?? 'balanced',
        traits: (j['traits'] as List?)?.cast<String>().toList(),
        familyWealth: j['familyWealth'] as String? ?? 'middle',
        careerLevel: j['careerLevel'] as int? ?? 0,
        yearsAtLevel: j['yearsAtLevel'] as int? ?? 0,
        company: j['company'] as String?,
        experience: _intMap(j['experience']),
        jobHistory: _list(j['jobHistory'], JobRecord.fromJson),
        retired: j['retired'] as bool? ?? false,
        education: j['education'] is Map
            ? EducationState.fromJson((j['education'] as Map).cast<String, dynamic>())
            : EducationState(),
        vehicles: _list(j['vehicles'], VehicleModel.fromJson),
        crypto: _list(j['crypto'], CryptoAsset.fromJson),
        businesses: _list(j['businesses'], BusinessModel.fromJson),
        inventory: _list(j['inventory'], OwnedItem.fromJson),
        loans: _list(j['loans'], Loan.fromJson),
        rentedOut: (j['rentedOut'] as List?)?.cast<String>().toList(),
        homePropertyId: j['homePropertyId'] as String?,
        movedOut: j['movedOut'] as bool? ?? false,
        conditions: _list(j['conditions'], HealthCondition.fromJson),
        hasInsurance: j['hasInsurance'] as bool? ?? false,
        followers: j['followers'] as int? ?? 0,
        sponsorships: _list(j['sponsorships'], Sponsorship.fromJson),
        headlines: (j['headlines'] as List?)?.cast<String>().toList(),
        pets: _list(j['pets'], Pet.fromJson),
        counters: _intMap(j['counters']),
        ancestors: _list(j['ancestors'], Ancestor.fromJson),
        lifeMissionsClaimed: (j['lifeMissionsClaimed'] as List?)?.cast<String>().toList(),
        daily: j['daily'] is Map
            ? DailyMissionState.fromJson((j['daily'] as Map).cast<String, dynamic>())
            : null,
        lastActionAge: j['lastActionAge'] as int? ?? -1,
        actionsThisYear: _intMap(j['actionsThisYear']),
        school: _obj(j['school'], SchoolLife.fromJson, SchoolLife.new),
        crime: _obj(j['crime'], CrimeState.fromJson, CrimeState.new),
        social: _obj(j['social'], SocialState.fromJson, SocialState.new),
        dating: _obj(j['dating'], DatingState.fromJson, DatingState.new),
        npcMeta: _objMap(j['npcMeta'], NpcMeta.fromJson),
        propertyMeta: _objMap(j['propertyMeta'], PropertyMeta.fromJson),
      );

  String encode() => jsonEncode(toJson());

  static LifeExtras decode(String? raw) {
    if (raw == null || raw.isEmpty) return LifeExtras();
    try {
      return LifeExtras.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return LifeExtras();
    }
  }

  LifeExtras clone() => LifeExtras.fromJson(jsonDecode(encode()) as Map<String, dynamic>);
}

// ---------------------------------------------------------------------------
// Estado completo de uma vida
// ---------------------------------------------------------------------------

class LifeEngineState {
  final String saveId;
  final String slotName;
  final int generation;
  final CharacterModel character;
  final List<NpcModel> npcs;
  final List<PropertyModel> properties;
  final List<InvestmentModel> investments;
  final List<LifeLog> logs;
  final LifeExtras extras;

  // Transitórios (não persistidos)
  final List<PendingEvent> pendingEvents;
  final List<GameNotice> notices;
  final YearSummary? lastYearSummary;
  final EventOutcome? lastOutcome;
  final bool isLoading;

  LifeEngineState({
    required this.saveId,
    required this.slotName,
    this.generation = 1,
    required this.character,
    required this.npcs,
    required this.properties,
    required this.investments,
    required this.logs,
    LifeExtras? extras,
    this.pendingEvents = const [],
    this.notices = const [],
    this.lastYearSummary,
    this.lastOutcome,
    this.isLoading = false,
  }) : extras = extras ?? LifeExtras();

  /// Compatibilidade: primeiro evento pendente.
  LifeEvent? get pendingEvent => pendingEvents.isEmpty ? null : pendingEvents.first.event;

  double get vehiclesValue => extras.vehicles.fold(0.0, (s, v) => s + v.currentValue);
  double get cryptoValue => extras.crypto.fold(0.0, (s, c) => s + c.totalValue);
  double get businessValue => extras.businesses.fold(0.0, (s, b) => s + b.valuation);
  double get propertiesEquity => properties.fold(0.0, (s, p) => s + (p.currentValue - p.remainingDebt));
  double get investmentsValue => investments.fold(0.0, (s, i) => s + i.currentValue);

  double get netWorth {
    return character.bankBalance +
        propertiesEquity +
        investmentsValue +
        vehiclesValue +
        cryptoValue +
        businessValue -
        character.debt -
        extras.loansTotal;
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
    LifeExtras? extras,
    LifeEvent? pendingEvent,
    List<PendingEvent>? pendingEvents,
    bool clearPendingEvent = false,
    List<GameNotice>? notices,
    YearSummary? lastYearSummary,
    bool clearSummary = false,
    EventOutcome? lastOutcome,
    bool clearOutcome = false,
    bool? isLoading,
  }) {
    List<PendingEvent> pe = pendingEvents ?? this.pendingEvents;
    if (pendingEvent != null) pe = [PendingEvent(pendingEvent), ...pe];
    if (clearPendingEvent) pe = const [];
    return LifeEngineState(
      saveId: saveId ?? this.saveId,
      slotName: slotName ?? this.slotName,
      generation: generation ?? this.generation,
      character: character ?? this.character,
      npcs: npcs ?? this.npcs,
      properties: properties ?? this.properties,
      investments: investments ?? this.investments,
      logs: logs ?? this.logs,
      extras: extras ?? this.extras,
      pendingEvents: pe,
      notices: notices ?? this.notices,
      lastYearSummary: clearSummary ? null : (lastYearSummary ?? this.lastYearSummary),
      lastOutcome: clearOutcome ? null : (lastOutcome ?? this.lastOutcome),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
