import 'package:flutter/material.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/careers/data/career_catalog.dart';
import 'package:bitweve/features/careers/models/career_track.dart';
import 'package:bitweve/features/education/data/education_catalog.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'life_draft.dart';

class InterviewQuestion {
  final String question;
  final List<String> answers;
  final List<double> scores; // bônus de chance por resposta
  const InterviewQuestion(this.question, this.answers, this.scores);
}

class CareerSystem {
  static const interviewPool = [
    InterviewQuestion('Por que você quer trabalhar aqui?', [
      'Admiro a missão da empresa e quero crescer junto.',
      'Preciso pagar meus boletos.',
      'Pesquisei muito e meu perfil combina com a vaga.',
    ], [0.12, -0.08, 0.15]),
    InterviewQuestion('Qual é o seu maior defeito?', [
      'Sou perfeccionista demais.',
      'Às vezes me cobro muito, mas aprendi a priorizar.',
      'Não tenho defeitos.',
    ], [0.02, 0.15, -0.12]),
    InterviewQuestion('Onde você se vê em 5 anos?', [
      'Liderando projetos importantes aqui.',
      'Na sua cadeira!',
      'Não penso muito no futuro.',
    ], [0.14, 0.04, -0.1]),
    InterviewQuestion('Como você lida com pressão?', [
      'Organizo as tarefas e mantenho a calma.',
      'Eu travo um pouco, mas dou conta.',
      'Trabalho melhor sob pressão — é quando brilho.',
    ], [0.15, -0.03, 0.08]),
    InterviewQuestion('Conte sobre um conflito que você resolveu.', [
      'Mediei uma discussão no grupo e chegamos a um acordo.',
      'Eu sempre evito conflitos.',
      'Ganhei a discussão, claro.',
    ], [0.15, 0.0, -0.1]),
    InterviewQuestion('Qual pretensão salarial?', [
      'Dentro da média do mercado para o cargo.',
      'O dobro do anunciado.',
      'Aceito qualquer valor.',
    ], [0.12, -0.12, 0.02]),
  ];

  static InterviewQuestion randomQuestion(EngineContext ctx) => ctx.pick(interviewPool);

  static CareerTrack? current(LifeDraft d) => CareerCatalog.byId(d.c.currentJobId);

  /// Lista do que falta para se candidatar (vazia = elegível).
  static List<String> missing(LifeDraft d, CareerTrack t) {
    final out = <String>[];
    final c = d.c;
    final e = d.x.education;
    if (c.currentAge < t.minAge) out.add('Idade mínima: ${t.minAge} anos');
    final eduOk = (educationRank[c.educationLevel] ?? 0) >= (educationRank[t.minEducation] ?? 0);
    if (!eduOk) {
      // Bootcamp conta como formação para cargos iniciais de tecnologia
      final bootcampOk = t.category == 'tech' && e.courses.contains('coding') && (educationRank[c.educationLevel] ?? 0) >= 2;
      if (!bootcampOk) out.add('Escolaridade: ${educationLabel(t.minEducation)}');
    }
    if (t.degrees.isNotEmpty && (educationRank[t.minEducation] ?? 0) >= 3) {
      final has = t.degrees.any(e.completedDegrees.contains);
      final bootcampOk = t.category == 'tech' && e.courses.contains('coding');
      if (!has && !bootcampOk) {
        out.add('Diploma: ${t.degrees.map((id) => EducationCatalog.degree(id)?.name ?? id).take(3).join(' / ')}');
      }
    }
    for (final course in t.requiredCourses) {
      if (!e.courses.contains(course)) out.add('Curso: ${EducationCatalog.course(course)?.name ?? course}');
    }
    if (t.requiresLicense && !c.hasDriversLicense) out.add('Carteira de motorista');
    if (t.noCriminalRecord && c.criminalRecord) out.add('Ficha criminal limpa');
    if (c.smarts < t.minSmarts) out.add('Inteligência ${t.minSmarts}+');
    if (c.fitness < t.minFitness) out.add('Condicionamento ${t.minFitness}+');
    if (c.looks < t.minLooks) out.add('Aparência ${t.minLooks}+');
    if (c.charisma < t.minCharisma) out.add('Carisma ${t.minCharisma}+');
    if (c.reputation < t.minReputation) out.add('Reputação ${t.minReputation}+');
    if (c.fame < t.minFame) out.add('Fama ${t.minFame}+');
    if (e.inSchool && !t.partTime) out.add('Só meio período durante a escola');
    return out;
  }

  static double hireChance(LifeDraft d, CareerTrack t) {
    final c = d.c;
    var p = 0.55;
    p += (c.smarts - t.minSmarts) / 200;
    p += (c.charisma - 50) / 250;
    p += (c.looks - 50) / 400;
    p += (c.reputation - 50) / 300;
    p += (d.x.experience[t.category] ?? 0) * 0.03;
    if (d.x.education.courses.contains('english')) p += 0.05;
    if (d.x.education.courses.contains('public_speaking') && (t.category == 'politics' || t.category == 'business')) p += 0.06;
    if (d.x.education.courses.contains('acting') && t.id == 'ent_actor') p += 0.1;
    if (d.x.education.courses.contains('singing') && t.id == 'ent_singer') p += 0.1;
    if (d.x.education.courses.contains('cooking') && t.id == 'srv_chef') p += 0.1;
    if (t.category == 'entertainment' || t.category == 'sports') p += c.fame / 200;
    if (t.id == 'ent_influencer') p += d.x.followers > 1000 ? 0.15 : -0.1;
    if (c.criminalRecord) p -= 0.15;
    if (d.x.education.gpa >= 8.5) p += 0.05;
    return p.clamp(0.05, 0.95);
  }

  static void apply(LifeDraft d, String trackId, double interviewBonus) {
    final t = CareerCatalog.byId(trackId);
    if (t == null) return;
    if (d.x.crime.inPrison) {
      d.warn('Você está preso(a)', 'Candidate-se a empregos depois de cumprir a pena.');
      return;
    }
    final miss = missing(d, t);
    if (miss.isNotEmpty) {
      d.warn('Requisitos não atendidos', miss.join(' · '));
      return;
    }
    if (d.c.currentJobId == t.id) {
      d.warn('Você já trabalha aqui');
      return;
    }
    if (!d.useAction('apply', 5)) return;
    final p = (hireChance(d, t) + interviewBonus).clamp(0.03, 0.97);
    if (!d.ctx.chance(p)) {
      d.log('career', 'A entrevista para ${t.level(0).title} não deu certo. Tente novamente!', icon: 'work_off', color: '#EF4444');
      d.notify(NoticeKind.career, Icons.work_off, 'Candidatura recusada', message: '${t.name} · chance era ${(p * 100).round()}%');
      d.stats({'happiness': -5});
      d.sfx(GameSfx.negativeEvent);
      return;
    }
    if (d.c.currentJobId != null) _closeJob(d, 'Mudou de emprego');
    final company = _companyName(d, t);
    // Experiência na área pode permitir começar acima do nível inicial
    final exp = d.x.experience[t.category] ?? 0;
    final startLevel = (exp ~/ 4).clamp(0, (t.levels.length - 1) ~/ 2);
    final level = t.level(startLevel);
    final salary = (level.salary * d.ctx.salaryMult(d.c.country)).roundToDouble();
    d.c = d.c.copyWith(
      currentJobId: t.id,
      currentJobTitle: level.title,
      currentSalary: salary,
      jobPerformance: 60,
      yearsInCurrentJob: 0,
    );
    d.x.careerLevel = startLevel;
    d.x.yearsAtLevel = 0;
    d.x.company = company;
    d.x.retired = false;
    d.x.jobHistory.add(JobRecord(title: level.title, company: company, trackId: t.id, startAge: d.age, salary: salary));
    d.x.bump('jobsGotten');
    d.x.bump('careerWins');
    d.stats({'happiness': 12});
    _spawnWorkNpcs(d, company);
    d.log('career', 'Contratado(a)! Você agora é ${level.title} na $company, ganhando ${Fmt.money(salary)}/ano.', icon: 'work', color: '#22C55E');
    d.notify(NoticeKind.career, t.icon, 'Você foi contratado(a)!', message: '${level.title} · ${Fmt.money(salary)}/ano', celebrate: true);
    d.sfx(GameSfx.promotion);
  }

  static String _companyName(LifeDraft d, CareerTrack t) {
    const prefixes = ['Nova', 'Grupo', 'Alpha', 'Vértice', 'Horizonte', 'Prisma', 'Atlas', 'Aurora', 'Órbita', 'Lumen'];
    const suffix = {
      'tech': ['Tech', 'Labs', 'Digital', 'Systems'],
      'medicine': ['Saúde', 'Hospital', 'Clínica', 'Vida'],
      'law': ['Advogados Associados', 'Jurídico', 'Tribunal'],
      'security': ['Batalhão', 'Segurança', 'Corporação'],
      'education': ['Escola', 'Colégio', 'Universidade'],
      'entertainment': ['Studios', 'Records', 'Entretenimento', 'Produções'],
      'sports': ['Esporte Clube', 'Futebol Clube', 'Atlético'],
      'business': ['Holding', 'Corp', 'Investimentos', 'S.A.'],
      'construction': ['Construtora', 'Engenharia', 'Obras'],
      'admin': ['Serviços', 'Gestão', 'Consultoria'],
      'politics': ['Câmara Municipal', 'Assembleia', 'Partido'],
      'science': ['Instituto', 'Pesquisa', 'Laboratórios'],
      'arts': ['Ateliê', 'Design Studio', 'Galeria'],
      'media': ['Comunicação', 'Mídia', 'Agência'],
      'entrepreneur': ['Empreendimentos', 'Negócios'],
      'services': ['Express', 'Delivery', 'Serviços', 'Bistrô'],
    };
    if (t.id == 'law_judge') return 'Tribunal de Justiça';
    if (t.id == 'sec_police') return 'Polícia Militar';
    if (t.id == 'sec_firefighter') return 'Corpo de Bombeiros';
    if (t.id == 'pol_politician') return 'Partido ${d.ctx.pick(['Renovação', 'Progresso', 'União', 'Futuro'])}';
    if (t.id == 'sci_astronaut') return 'Agência Espacial';
    if (t.id == 'ent_freelancer' || t.id == 'ent_influencer' || t.id == 'arts_painter') return 'Autônomo';
    final s = suffix[t.category] ?? ['Ltda'];
    return '${d.ctx.pick(prefixes)} ${d.ctx.pick(s)}';
  }

  static void _spawnWorkNpcs(LifeDraft d, String company) {
    d.npcs.removeWhere((n) => n.relationshipType == RelationshipType.boss);
    d.npcs.removeWhere((n) => n.relationshipType == RelationshipType.coworker && n.relationshipLevel < 55);
    if (company == 'Autônomo') return;
    final boss = d.makeNpc(
      type: RelationshipType.boss,
      age: (d.age + d.ctx.range(5, 20)).clamp(25, 70),
      level: 45 + d.ctx.rng.nextInt(20),
      occupation: 'Gestor(a) na $company',
      netWorth: 300000,
    );
    d.npcs.add(boss);
    final coworker = d.makeNpc(
      type: RelationshipType.coworker,
      age: (d.age + d.ctx.range(-4, 6)).clamp(16, 70),
      level: 40 + d.ctx.rng.nextInt(25),
      occupation: 'Colega na $company',
    );
    d.npcs.add(coworker);
  }

  static void _closeJob(LifeDraft d, String reason) {
    if (d.x.jobHistory.isNotEmpty && d.x.jobHistory.last.endAge == null) {
      d.x.jobHistory.last
        ..endAge = d.age
        ..reason = reason;
    }
  }

  static void _promote(LifeDraft d, CareerTrack t) {
    if (t.isTop(d.x.careerLevel)) {
      final raise = (d.c.currentSalary ?? 0) * 0.08;
      d.c = d.c.copyWith(currentSalary: (d.c.currentSalary ?? 0) + raise);
      d.log('career', 'Você já está no topo! Recebeu um bônus de ${Fmt.money(raise)} no salário anual.', icon: 'emoji_events', color: '#FFC53D');
      d.notify(NoticeKind.career, Icons.emoji_events, 'Aumento no topo da carreira', message: '+${Fmt.money(raise)}/ano', celebrate: true);
      return;
    }
    d.x.careerLevel += 1;
    d.x.yearsAtLevel = 0;
    final lvl = t.level(d.x.careerLevel);
    final salary = (lvl.salary * d.ctx.salaryMult(d.c.country)).roundToDouble();
    d.c = d.c.copyWith(currentJobTitle: lvl.title, currentSalary: salary, jobPerformance: 55);
    d.x.bump('promotions');
    d.x.bump('careerWins');
    d.x.jobHistory.add(JobRecord(title: lvl.title, company: d.x.company ?? '', trackId: t.id, startAge: d.age, salary: salary));
    if (d.x.jobHistory.length >= 2) {
      d.x.jobHistory[d.x.jobHistory.length - 2]
        ..endAge ??= d.age
        ..reason ??= 'Promoção';
    }
    d.stats({'happiness': 14, 'reputation': 5, 'fame': t.fameGain});
    d.log('career', 'PROMOÇÃO! Você agora é ${lvl.title} com salário de ${Fmt.money(salary)}/ano.', icon: 'trending_up', color: '#FFC53D');
    d.notify(NoticeKind.career, Icons.trending_up, 'Você foi promovido(a)!', message: '${lvl.title} · ${Fmt.money(salary)}/ano', celebrate: true);
    d.sfx(GameSfx.promotion);
  }

  static void promoteFromEvent(LifeDraft d) {
    final t = current(d);
    if (t != null) _promote(d, t);
  }

  static void fire(LifeDraft d, String reason) {
    if (d.c.currentJobId == null && d.c.currentJobTitle == null) return;
    final title = d.c.currentJobTitle;
    _closeJob(d, reason);
    d.c = d.c.copyWith(clearJob: true, jobPerformance: 50, yearsInCurrentJob: 0);
    d.x.careerLevel = 0;
    d.x.yearsAtLevel = 0;
    d.x.company = null;
    d.x.bump('timesFired');
    d.stats({'happiness': -15, 'stress': 10});
    d.log('career', 'Você foi demitido(a) do cargo de $title. Motivo: $reason.', icon: 'work_off', color: '#EF4444');
    d.notify(NoticeKind.warning, Icons.work_off, 'Você foi demitido(a)', message: reason);
    d.sfx(GameSfx.negativeEvent);
  }

  // ------------------------------------------------------------------ ações
  static void workHard(LifeDraft d) {
    if (d.c.currentJobTitle == null) return;
    if (!d.useAction('workHard', 3) || !d.useEnergy(15)) return;
    d.c = d.c.copyWith(jobPerformance: d.c.jobPerformance + d.ctx.range(8, 14));
    d.stats({'stress': 7, 'health': -1});
    d.log('career', 'Você fez horas extras e entregou além do esperado.', icon: 'speed', color: '#6366F1');
    d.notify(NoticeKind.career, Icons.speed, 'Desempenho em alta', message: 'Desempenho ${d.c.jobPerformance}%');
    d.sfx(GameSfx.positiveEvent);
  }

  static void slackOff(LifeDraft d) {
    if (d.c.currentJobTitle == null) return;
    if (!d.useAction('slackOff', 3)) return;
    d.c = d.c.copyWith(jobPerformance: d.c.jobPerformance - d.ctx.range(6, 12), energy: d.c.energy + 10);
    d.stats({'stress': -8, 'happiness': 4});
    d.log('career', 'Você fez corpo mole no trabalho e passou o dia nas redes sociais.', icon: 'weekend', color: '#64748B');
    d.notify(NoticeKind.career, Icons.weekend, 'Dia tranquilo...', message: 'Desempenho ${d.c.jobPerformance}%');
  }

  static void askRaise(LifeDraft d) {
    if (d.c.currentSalary == null) return;
    if (!d.useAction('askRaise', 1)) return;
    final p = (d.c.jobPerformance - 40) / 60 + d.c.charisma / 300;
    if (d.ctx.chance(p.clamp(0.05, 0.9))) {
      final pct = 0.05 + d.ctx.roll() * 0.1;
      final raise = d.c.currentSalary! * pct;
      d.c = d.c.copyWith(currentSalary: d.c.currentSalary! + raise);
      d.stats({'happiness': 10});
      d.log('career', 'Aumento aprovado! +${(pct * 100).round()}% (novo salário ${Fmt.money(d.c.currentSalary!)}/ano).', icon: 'trending_up', color: '#22C55E');
      d.notify(NoticeKind.career, Icons.trending_up, 'Aumento aprovado!', message: '+${Fmt.money(raise)}/ano', celebrate: true);
      d.sfx(GameSfx.promotion);
    } else {
      d.c = d.c.copyWith(jobPerformance: d.c.jobPerformance - 4);
      d.stats({'happiness': -6, 'stress': 4});
      d.log('career', 'Pedido de aumento negado. Seu chefe pediu mais resultados primeiro.', icon: 'sentiment_dissatisfied', color: '#EF4444');
      d.notify(NoticeKind.career, Icons.sentiment_dissatisfied, 'Aumento negado');
      d.sfx(GameSfx.negativeEvent);
    }
  }

  static void askPromotion(LifeDraft d) {
    final t = current(d);
    if (t == null) return;
    if (!d.useAction('askPromotion', 1)) return;
    final next = t.isTop(d.x.careerLevel) ? null : t.level(d.x.careerLevel + 1);
    if (next == null) {
      d.warn('Você já está no topo', 'Não há cargo acima do seu nesta carreira.');
      return;
    }
    final ready = d.x.yearsAtLevel >= next.years;
    final p = (ready ? 0.35 : 0.08) + (d.c.jobPerformance - 50) / 100 + d.c.charisma / 400;
    if (d.ctx.chance(p.clamp(0.03, 0.92))) {
      _promote(d, t);
    } else {
      d.stats({'happiness': -6});
      d.log('career', ready
          ? 'Você pediu promoção, mas a diretoria quer ver mais desempenho.'
          : 'Você pediu promoção cedo demais. Precisa de ${next.years} ano(s) no cargo atual.', icon: 'sentiment_dissatisfied', color: '#EF4444');
      d.notify(NoticeKind.career, Icons.sentiment_dissatisfied, 'Promoção negada', message: ready ? 'Melhore o desempenho' : 'Pouco tempo de casa');
      d.sfx(GameSfx.negativeEvent);
    }
  }

  static void quit(LifeDraft d) {
    if (d.c.currentJobTitle == null) return;
    final title = d.c.currentJobTitle;
    _closeJob(d, 'Pediu demissão');
    d.c = d.c.copyWith(clearJob: true, jobPerformance: 50, yearsInCurrentJob: 0);
    d.x.careerLevel = 0;
    d.x.yearsAtLevel = 0;
    d.x.company = null;
    d.npcs.removeWhere((n) => n.relationshipType == RelationshipType.boss);
    d.stats({'stress': -15, 'happiness': 3});
    d.log('career', 'Você pediu demissão do cargo de $title.', icon: 'exit_to_app', color: '#64748B');
    d.notify(NoticeKind.career, Icons.exit_to_app, 'Você pediu demissão', message: title ?? '');
    d.sfx(GameSfx.buttonTap);
  }

  static void retire(LifeDraft d) {
    if (d.age < 60) {
      d.warn('Ainda não', 'A aposentadoria é a partir dos 60 anos.');
      return;
    }
    final last = d.c.currentSalary ?? 0;
    if (d.c.currentJobTitle != null) _closeJob(d, 'Aposentadoria');
    d.c = d.c.copyWith(clearJob: true);
    d.x.retired = true;
    d.x.careerLevel = 0;
    final bonus = (last * 0.5).roundToDouble();
    if (bonus > 0) d.money(bonus);
    d.stats({'stress': -25, 'happiness': 12});
    d.log('career', 'Você se aposentou! ${bonus > 0 ? 'Recebeu ${Fmt.money(bonus)} de rescisão e ' : ''}vai receber pensão anual.', icon: 'beach_access', color: '#14B8A6');
    d.notify(NoticeKind.career, Icons.beach_access, 'Aposentadoria!', message: 'Hora de aproveitar a vida.', celebrate: true);
    d.sfx(GameSfx.achievement);
  }

  // ------------------------------------------------------------------ anual
  static void yearly(LifeDraft d) {
    // Pensão
    if (d.x.retired) {
      final pension = (18000 * d.ctx.salaryMult(d.c.country)) + d.x.counter('salariesReceived') * 400;
      d.money(pension);
      d.log('finance', 'Você recebeu ${Fmt.money(pension)} de aposentadoria.', icon: 'payments', color: '#14B8A6');
    }
    final t = current(d);
    if (d.c.currentSalary == null || d.c.currentJobTitle == null) return;

    // Salário
    final gross = d.c.currentSalary!;
    var income = gross;
    if (t?.category == 'entrepreneur' || t?.id == 'ent_influencer') {
      income = gross * (0.5 + d.ctx.roll() * 1.0 + d.c.jobPerformance / 200);
    }
    if (t?.id == 'ent_influencer') income += d.x.followers * 0.4;
    final tax = income * d.ctx.taxRate(d.c.country);
    final net = income - tax;
    d.money(net);
    d.x.bump('salariesReceived');
    d.log('career', 'Você trabalhou como ${d.c.currentJobTitle} e recebeu ${Fmt.money(net)} líquidos (impostos: ${Fmt.money(tax)}).',
        icon: 'payments', color: '#22C55E');
    d.notify(NoticeKind.money, Icons.payments, 'Salário do ano recebido', message: d.c.currentJobTitle!, money: net);

    // Desgaste e experiência
    final stress = t?.stress ?? 40;
    d.stats({'stress': (stress / 10).round() - 2, 'energy': -((t?.hoursPerWeek ?? 40) ~/ 8)});
    if (t != null) {
      d.x.experience[t.category] = (d.x.experience[t.category] ?? 0) + 1;
      if (t.fameGain > 0) {
        d.stats({'fame': (t.fameGain * (1 + d.x.careerLevel * 0.3)).round()});
        d.x.followers += (t.fameGain * 400 * (d.x.careerLevel + 1));
      }
    }
    d.x.yearsAtLevel += 1;
    d.c = d.c.copyWith(yearsInCurrentJob: d.c.yearsInCurrentJob + 1);

    // Desempenho oscila com disciplina, estresse e saúde
    final drift = d.ctx.range(-6, 6) + (d.c.discipline - 50) ~/ 15 - (d.c.stress > 75 ? 6 : 0) - (d.c.health < 30 ? 6 : 0);
    d.c = d.c.copyWith(jobPerformance: d.c.jobPerformance + drift);

    if (t == null) return; // emprego legado sem trilha: só salário

    // Demissão
    final perf = d.c.jobPerformance;
    final fireP = t.risk * 0.4 + (perf < 30 ? (30 - perf) / 60 : 0);
    if (d.ctx.chance(fireP)) {
      fire(d, perf < 30 ? 'baixo desempenho' : 'corte de custos');
      return;
    }

    // Promoção automática
    if (!t.isTop(d.x.careerLevel)) {
      final next = t.level(d.x.careerLevel + 1);
      if (d.x.yearsAtLevel >= next.years) {
        final p = 0.15 + (perf - 55) / 80 + d.c.smarts / 500;
        if (perf >= 55 && d.ctx.chance(p.clamp(0.05, 0.8))) _promote(d, t);
      }
    }
  }
}
