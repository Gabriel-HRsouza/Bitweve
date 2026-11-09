/// Registro de um caso na ficha criminal.
class CrimeRecord {
  final String crime;
  final int age;
  final String outcome; // acquitted | fine | probation | prison
  final int years;
  final double fine;

  const CrimeRecord({required this.crime, required this.age, required this.outcome, this.years = 0, this.fine = 0});

  String get outcomeLabel => switch (outcome) {
        'acquitted' => 'Absolvido(a)',
        'fine' => 'Multa',
        'probation' => 'Liberdade condicional',
        'prison' => 'Prisão ($years ano${years == 1 ? '' : 's'})',
        _ => outcome,
      };

  Map<String, dynamic> toJson() => {'crime': crime, 'age': age, 'outcome': outcome, 'years': years, 'fine': fine};

  factory CrimeRecord.fromJson(Map<String, dynamic> j) => CrimeRecord(
        crime: j['crime'] as String? ?? '',
        age: j['age'] as int? ?? 0,
        outcome: j['outcome'] as String? ?? 'fine',
        years: j['years'] as int? ?? 0,
        fine: (j['fine'] as num?)?.toDouble() ?? 0,
      );
}

/// Processo aguardando julgamento.
class PendingCase {
  final String crimeId;
  final String label;
  final int severity; // 1..5
  final double evidence; // 0..1
  final double bail;
  bool bailPaid;

  PendingCase({
    required this.crimeId,
    required this.label,
    required this.severity,
    required this.evidence,
    required this.bail,
    this.bailPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'crimeId': crimeId, 'label': label, 'severity': severity, 'evidence': evidence, 'bail': bail, 'bailPaid': bailPaid,
      };

  factory PendingCase.fromJson(Map<String, dynamic> j) => PendingCase(
        crimeId: j['crimeId'] as String? ?? '',
        label: j['label'] as String? ?? '',
        severity: j['severity'] as int? ?? 1,
        evidence: (j['evidence'] as num?)?.toDouble() ?? 0.5,
        bail: (j['bail'] as num?)?.toDouble() ?? 1000,
        bailPaid: j['bailPaid'] as bool? ?? false,
      );
}

/// Estado do submundo: reputação criminal, polícia, processos e prisão.
class CrimeState {
  int notoriety; // reputação no submundo 0..100
  int heat; // atenção da polícia 0..100
  int skill; // habilidade 0..100
  int successes;
  int failures;
  double totalLoot;
  final List<CrimeRecord> record;
  PendingCase? pendingCase;

  // Prisão
  bool inPrison;
  int sentence;
  int served;
  int behavior; // 0..100
  String prisonName;
  double prisonSavings;
  int paroleDenials;
  int probationYears;

  // Organização
  String? gangId;
  int gangRank; // 0..4
  int gangLoyalty; // 0..100
  int missionsDone;

  /// Itens "quentes" que precisam passar pelo mercado clandestino.
  double stash;
  final Map<String, int> storeHits; // lojaId -> vezes

  CrimeState({
    this.notoriety = 0,
    this.heat = 0,
    this.skill = 5,
    this.successes = 0,
    this.failures = 0,
    this.totalLoot = 0,
    List<CrimeRecord>? record,
    this.pendingCase,
    this.inPrison = false,
    this.sentence = 0,
    this.served = 0,
    this.behavior = 50,
    this.prisonName = '',
    this.prisonSavings = 0,
    this.paroleDenials = 0,
    this.probationYears = 0,
    this.gangId,
    this.gangRank = 0,
    this.gangLoyalty = 0,
    this.missionsDone = 0,
    this.stash = 0,
    Map<String, int>? storeHits,
  })  : record = record ?? [],
        storeHits = storeHits ?? {};

  int get yearsLeft => (sentence - served).clamp(0, 999);
  bool get onProbation => probationYears > 0;

  Map<String, dynamic> toJson() => {
        'notoriety': notoriety,
        'heat': heat,
        'skill': skill,
        'successes': successes,
        'failures': failures,
        'totalLoot': totalLoot,
        'record': record.map((e) => e.toJson()).toList(),
        'pendingCase': pendingCase?.toJson(),
        'inPrison': inPrison,
        'sentence': sentence,
        'served': served,
        'behavior': behavior,
        'prisonName': prisonName,
        'prisonSavings': prisonSavings,
        'paroleDenials': paroleDenials,
        'probationYears': probationYears,
        'gangId': gangId,
        'gangRank': gangRank,
        'gangLoyalty': gangLoyalty,
        'missionsDone': missionsDone,
        'stash': stash,
        'storeHits': storeHits,
      };

  factory CrimeState.fromJson(Map<String, dynamic> j) => CrimeState(
        notoriety: j['notoriety'] as int? ?? 0,
        heat: j['heat'] as int? ?? 0,
        skill: j['skill'] as int? ?? 5,
        successes: j['successes'] as int? ?? 0,
        failures: j['failures'] as int? ?? 0,
        totalLoot: (j['totalLoot'] as num?)?.toDouble() ?? 0,
        record: (j['record'] as List?)
            ?.map((e) => CrimeRecord.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        pendingCase: j['pendingCase'] is Map ? PendingCase.fromJson((j['pendingCase'] as Map).cast<String, dynamic>()) : null,
        inPrison: j['inPrison'] as bool? ?? false,
        sentence: j['sentence'] as int? ?? 0,
        served: j['served'] as int? ?? 0,
        behavior: j['behavior'] as int? ?? 50,
        prisonName: j['prisonName'] as String? ?? '',
        prisonSavings: (j['prisonSavings'] as num?)?.toDouble() ?? 0,
        paroleDenials: j['paroleDenials'] as int? ?? 0,
        probationYears: j['probationYears'] as int? ?? 0,
        gangId: j['gangId'] as String?,
        gangRank: j['gangRank'] as int? ?? 0,
        gangLoyalty: j['gangLoyalty'] as int? ?? 0,
        missionsDone: j['missionsDone'] as int? ?? 0,
        stash: (j['stash'] as num?)?.toDouble() ?? 0,
        storeHits: (j['storeHits'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      );
}
