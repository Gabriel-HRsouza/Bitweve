/// Vida escolar e universitária jogável (popularidade, professores, faltas,
/// advertências, clubes, estágio...). Persistida em LifeExtras.school.
class SchoolLife {
  // Escola (fundamental/médio)
  String? schoolId;
  String schoolName;
  String schoolType; // public | private | elite
  int popularity; // 0..100
  int teacherRel; // 0..100
  int performance; // 0..100 desempenho no ano corrente
  int absences; // faltas no ano
  int warnings; // advertências acumuladas no ano
  int suspensions; // total na vida escolar
  bool suspended; // suspenso(a) neste ano
  final List<String> clubs; // atividades extracurriculares
  String? clique; // grupo escolar
  int examsThisYear;
  int bestExam;

  // Faculdade
  String? institutionId;
  String? institutionName;
  int collegePopularity;
  int professorRel;
  String? internshipCompany;
  int internshipYears;
  int projectsDone;
  int researchPoints;
  final List<String> collegeClubs;
  bool tccDone;

  final List<String> history;

  SchoolLife({
    this.schoolId,
    this.schoolName = '',
    this.schoolType = 'public',
    this.popularity = 40,
    this.teacherRel = 50,
    this.performance = 50,
    this.absences = 0,
    this.warnings = 0,
    this.suspensions = 0,
    this.suspended = false,
    List<String>? clubs,
    this.clique,
    this.examsThisYear = 0,
    this.bestExam = 0,
    this.institutionId,
    this.institutionName,
    this.collegePopularity = 35,
    this.professorRel = 50,
    this.internshipCompany,
    this.internshipYears = 0,
    this.projectsDone = 0,
    this.researchPoints = 0,
    List<String>? collegeClubs,
    this.tccDone = false,
    List<String>? history,
  })  : clubs = clubs ?? [],
        collegeClubs = collegeClubs ?? [],
        history = history ?? [];

  void addHistory(String s) {
    history.add(s);
    if (history.length > 40) history.removeAt(0);
  }

  /// Zera os contadores anuais (chamado ao envelhecer).
  void newYear() {
    absences = 0;
    warnings = 0;
    suspended = false;
    examsThisYear = 0;
    bestExam = 0;
    performance = (performance * 0.5 + 25).round();
  }

  Map<String, dynamic> toJson() => {
        'schoolId': schoolId,
        'schoolName': schoolName,
        'schoolType': schoolType,
        'popularity': popularity,
        'teacherRel': teacherRel,
        'performance': performance,
        'absences': absences,
        'warnings': warnings,
        'suspensions': suspensions,
        'suspended': suspended,
        'clubs': clubs,
        'clique': clique,
        'examsThisYear': examsThisYear,
        'bestExam': bestExam,
        'institutionId': institutionId,
        'institutionName': institutionName,
        'collegePopularity': collegePopularity,
        'professorRel': professorRel,
        'internshipCompany': internshipCompany,
        'internshipYears': internshipYears,
        'projectsDone': projectsDone,
        'researchPoints': researchPoints,
        'collegeClubs': collegeClubs,
        'tccDone': tccDone,
        'history': history,
      };

  factory SchoolLife.fromJson(Map<String, dynamic> j) => SchoolLife(
        schoolId: j['schoolId'] as String?,
        schoolName: j['schoolName'] as String? ?? '',
        schoolType: j['schoolType'] as String? ?? 'public',
        popularity: j['popularity'] as int? ?? 40,
        teacherRel: j['teacherRel'] as int? ?? 50,
        performance: j['performance'] as int? ?? 50,
        absences: j['absences'] as int? ?? 0,
        warnings: j['warnings'] as int? ?? 0,
        suspensions: j['suspensions'] as int? ?? 0,
        suspended: j['suspended'] as bool? ?? false,
        clubs: (j['clubs'] as List?)?.cast<String>().toList(),
        clique: j['clique'] as String?,
        examsThisYear: j['examsThisYear'] as int? ?? 0,
        bestExam: j['bestExam'] as int? ?? 0,
        institutionId: j['institutionId'] as String?,
        institutionName: j['institutionName'] as String?,
        collegePopularity: j['collegePopularity'] as int? ?? 35,
        professorRel: j['professorRel'] as int? ?? 50,
        internshipCompany: j['internshipCompany'] as String?,
        internshipYears: j['internshipYears'] as int? ?? 0,
        projectsDone: j['projectsDone'] as int? ?? 0,
        researchPoints: j['researchPoints'] as int? ?? 0,
        collegeClubs: (j['collegeClubs'] as List?)?.cast<String>().toList(),
        tccDone: j['tccDone'] as bool? ?? false,
        history: (j['history'] as List?)?.cast<String>().toList(),
      );
}
