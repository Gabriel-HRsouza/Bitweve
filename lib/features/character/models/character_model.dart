import 'avatar_config.dart';

class CharacterModel {
  final String id;
  final String saveId;
  final String firstName;
  final String lastName;
  final String gender; // 'male', 'female', 'non_binary'
  final String sexualOrientation;
  final int birthYear;
  final int currentAge;
  final String country;
  final String city;
  final AvatarConfig avatarConfig;

  // Atributos Centrais (0 a 100)
  final int health;
  final int happiness;
  final int smarts;
  final int looks;
  final int energy;
  final int stress;
  final int discipline;
  final int charisma;
  final int fitness;
  final int reputation;
  final int fame;
  final int karma;

  // Finanças
  final double bankBalance;
  final double annualExpenses;
  final double debt;
  final int creditScore;

  // Status de Vida e Carreira
  final bool isAlive;
  final String? causeOfDeath;
  final int? ageOfDeath;
  final String? partnerId;
  final bool isMarried;
  final String educationLevel; // 'none', 'elementary', 'high_school', 'college', 'master', 'phd'
  final String? currentDegree;
  final String? currentJobId;
  final String? currentJobTitle;
  final double? currentSalary;
  final int jobPerformance;
  final int yearsInCurrentJob;
  final bool hasDriversLicense;
  final bool criminalRecord;
  final int timesArrested;

  const CharacterModel({
    required this.id,
    required this.saveId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.sexualOrientation,
    required this.birthYear,
    required this.currentAge,
    required this.country,
    required this.city,
    required this.avatarConfig,
    this.health = 95,
    this.happiness = 90,
    this.smarts = 50,
    this.looks = 50,
    this.energy = 100,
    this.stress = 10,
    this.discipline = 50,
    this.charisma = 50,
    this.fitness = 60,
    this.reputation = 50,
    this.fame = 0,
    this.karma = 50,
    this.bankBalance = 0.0,
    this.annualExpenses = 0.0,
    this.debt = 0.0,
    this.creditScore = 650,
    this.isAlive = true,
    this.causeOfDeath,
    this.ageOfDeath,
    this.partnerId,
    this.isMarried = false,
    this.educationLevel = 'none',
    this.currentDegree,
    this.currentJobId,
    this.currentJobTitle,
    this.currentSalary,
    this.jobPerformance = 50,
    this.yearsInCurrentJob = 0,
    this.hasDriversLicense = false,
    this.criminalRecord = false,
    this.timesArrested = 0,
  });

  String get fullName => '$firstName $lastName';

  CharacterModel copyWith({
    String? id,
    String? saveId,
    String? firstName,
    String? lastName,
    String? gender,
    String? sexualOrientation,
    int? birthYear,
    int? currentAge,
    String? country,
    String? city,
    AvatarConfig? avatarConfig,
    int? health,
    int? happiness,
    int? smarts,
    int? looks,
    int? energy,
    int? stress,
    int? discipline,
    int? charisma,
    int? fitness,
    int? reputation,
    int? fame,
    int? karma,
    double? bankBalance,
    double? annualExpenses,
    double? debt,
    int? creditScore,
    bool? isAlive,
    String? causeOfDeath,
    int? ageOfDeath,
    String? partnerId,
    bool? isMarried,
    String? educationLevel,
    String? currentDegree,
    String? currentJobId,
    String? currentJobTitle,
    double? currentSalary,
    int? jobPerformance,
    int? yearsInCurrentJob,
    bool? hasDriversLicense,
    bool? criminalRecord,
    int? timesArrested,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      birthYear: birthYear ?? this.birthYear,
      currentAge: currentAge ?? this.currentAge,
      country: country ?? this.country,
      city: city ?? this.city,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      health: (health ?? this.health).clamp(0, 100),
      happiness: (happiness ?? this.happiness).clamp(0, 100),
      smarts: (smarts ?? this.smarts).clamp(0, 100),
      looks: (looks ?? this.looks).clamp(0, 100),
      energy: (energy ?? this.energy).clamp(0, 100),
      stress: (stress ?? this.stress).clamp(0, 100),
      discipline: (discipline ?? this.discipline).clamp(0, 100),
      charisma: (charisma ?? this.charisma).clamp(0, 100),
      fitness: (fitness ?? this.fitness).clamp(0, 100),
      reputation: (reputation ?? this.reputation).clamp(0, 100),
      fame: (fame ?? this.fame).clamp(0, 100),
      karma: (karma ?? this.karma).clamp(0, 100),
      bankBalance: bankBalance ?? this.bankBalance,
      annualExpenses: annualExpenses ?? this.annualExpenses,
      debt: (debt ?? this.debt).clamp(0.0, double.infinity),
      creditScore: (creditScore ?? this.creditScore).clamp(300, 850),
      isAlive: isAlive ?? this.isAlive,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      ageOfDeath: ageOfDeath ?? this.ageOfDeath,
      partnerId: partnerId ?? this.partnerId,
      isMarried: isMarried ?? this.isMarried,
      educationLevel: educationLevel ?? this.educationLevel,
      currentDegree: currentDegree ?? this.currentDegree,
      currentJobId: currentJobId ?? this.currentJobId,
      currentJobTitle: currentJobTitle ?? this.currentJobTitle,
      currentSalary: currentSalary ?? this.currentSalary,
      jobPerformance: (jobPerformance ?? this.jobPerformance).clamp(0, 100),
      yearsInCurrentJob: yearsInCurrentJob ?? this.yearsInCurrentJob,
      hasDriversLicense: hasDriversLicense ?? this.hasDriversLicense,
      criminalRecord: criminalRecord ?? this.criminalRecord,
      timesArrested: timesArrested ?? this.timesArrested,
    );
  }
}
