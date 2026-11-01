import 'package:drift/drift.dart';

class GameSaves extends Table {
  TextColumn get id => text()();
  TextColumn get slotName => text()();
  TextColumn get characterId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastSavedAt => dateTime()();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCurrentSave => boolean().withDefault(const Constant(false))();
  IntColumn get generation => integer().withDefault(const Constant(1))();
  TextColumn get biography => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get gender => text()(); // male, female, non_binary
  TextColumn get sexualOrientation => text()();
  IntColumn get birthYear => integer()();
  IntColumn get currentAge => integer()();
  TextColumn get country => text()();
  TextColumn get city => text()();
  TextColumn get avatarConfigJson => text()();

  // Core Stats (0-100)
  IntColumn get health => integer()();
  IntColumn get happiness => integer()();
  IntColumn get smarts => integer()();
  IntColumn get looks => integer()();
  IntColumn get energy => integer()();
  IntColumn get stress => integer()();
  IntColumn get discipline => integer()();
  IntColumn get charisma => integer()();
  IntColumn get fitness => integer()();
  IntColumn get reputation => integer()();
  IntColumn get fame => integer()();
  IntColumn get karma => integer()();

  // Financials
  RealColumn get bankBalance => real()();
  RealColumn get annualExpenses => real()();
  RealColumn get debt => real()();
  IntColumn get creditScore => integer()();

  // Status
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  TextColumn get causeOfDeath => text().nullable()();
  IntColumn get ageOfDeath => integer().nullable()();
  TextColumn get partnerId => text().nullable()();
  BoolColumn get isMarried => boolean().withDefault(const Constant(false))();
  TextColumn get educationLevel => text()();
  TextColumn get currentDegree => text().nullable()();
  TextColumn get currentJobId => text().nullable()();
  TextColumn get currentJobTitle => text().nullable()();
  RealColumn get currentSalary => real().nullable()();
  IntColumn get jobPerformance => integer().withDefault(const Constant(50))();
  IntColumn get yearsInCurrentJob => integer().withDefault(const Constant(0))();
  BoolColumn get hasDriversLicense => boolean().withDefault(const Constant(false))();
  BoolColumn get criminalRecord => boolean().withDefault(const Constant(false))();
  IntColumn get timesArrested => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Npcs extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get gender => text()();
  IntColumn get age => integer()();
  TextColumn get relationshipType => text()();
  IntColumn get relationshipLevel => integer()();
  IntColumn get respectLevel => integer()();
  TextColumn get avatarConfigJson => text()();
  TextColumn get occupation => text()();
  RealColumn get salary => real()();
  RealColumn get netWorth => real()();
  IntColumn get health => integer()();
  IntColumn get happiness => integer()();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  TextColumn get causeOfDeath => text().nullable()();
  TextColumn get memoryJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class EducationHistories extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get schoolType => text()();
  TextColumn get institutionName => text()();
  TextColumn get majorOrCourse => text().nullable()();
  IntColumn get startAge => integer()();
  IntColumn get graduatedAge => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  RealColumn get gpaOrGrade => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class CareerHistories extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get companyName => text()();
  TextColumn get jobTitle => text()();
  TextColumn get field => text()();
  IntColumn get startAge => integer()();
  IntColumn get endAge => integer().nullable()();
  RealColumn get salary => real()();
  TextColumn get reasonForLeaving => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Properties extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  RealColumn get purchasePrice => real()();
  RealColumn get currentValue => real()();
  RealColumn get annualCost => real()();
  IntColumn get condition => integer()();
  BoolColumn get isFinanced => boolean().withDefault(const Constant(false))();
  RealColumn get monthlyPayment => real().withDefault(const Constant(0.0))();
  RealColumn get remainingDebt => real().withDefault(const Constant(0.0))();
  IntColumn get purchasedAtAge => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get ticker => text()();
  RealColumn get investedAmount => real()();
  RealColumn get currentValue => real()();
  RealColumn get units => real()();
  RealColumn get annualYieldPercent => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  TextColumn get name => text()();
  TextColumn get industry => text()();
  RealColumn get valuation => real()();
  RealColumn get revenue => real()();
  RealColumn get expenses => real()();
  IntColumn get employeeCount => integer()();
  IntColumn get reputation => integer()();
  RealColumn get productPrice => real()();
  RealColumn get marketingBudget => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class LifeLogs extends Table {
  TextColumn get id => text()();
  TextColumn get saveId => text()();
  IntColumn get age => integer()();
  IntColumn get year => integer()();
  TextColumn get category => text()();
  TextColumn get textContent => text()();
  TextColumn get icon => text()();
  TextColumn get accentColor => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
