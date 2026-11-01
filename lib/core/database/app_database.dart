import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  GameSaves,
  Characters,
  Npcs,
  EducationHistories,
  CareerHistories,
  Properties,
  Investments,
  Businesses,
  LifeLogs,
  Achievements,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bitweve_db'));

  @override
  int get schemaVersion => 1;
}
