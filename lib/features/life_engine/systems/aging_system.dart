import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/features/careers/data/career_catalog.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'business_crime_system.dart';
import 'career_system.dart';
import 'education_system.dart';
import 'event_system.dart';
import 'fame_system.dart';
import 'finance_system.dart';
import 'health_system.dart';
import 'life_draft.dart';
import 'relationship_system.dart';
import 'school_system.dart';
import 'dating_system.dart';
import 'social_media_system.dart';
import 'underworld_system.dart';

class AgingSystem {
  /// Frase obrigatória exibida a cada aniversário.
  static (String, String) birthdayMessage(int age) {
    final headline = age == 1 ? 'Você completou 1 ano!' : 'Você completou $age anos!';
    final String sub;
    if (age <= 3) {
      sub = 'Cada dia é uma descoberta. O mundo é enorme e cheio de cores.';
    } else if (age <= 5) {
      sub = 'A imaginação não tem limites. Brincar é a coisa mais séria do mundo.';
    } else if (age == 6) {
      sub = 'Hora de começar a escola! Um novo capítulo da sua vida começa.';
    } else if (age <= 11) {
      sub = 'Novos amigos, novas matérias e muitas aventuras pela frente.';
    } else if (age <= 14) {
      sub = 'A adolescência bate à porta. Quem você quer ser?';
    } else if (age <= 17) {
      sub = 'Primeiros amores, grandes sonhos e decisões importantes.';
    } else if (age == 18) {
      sub = 'Maioridade! Um novo capítulo da sua vida começa — agora as escolhas são suas.';
    } else if (age <= 24) {
      sub = 'Você agora tem $age anos. Muitas possibilidades estão à sua frente.';
    } else if (age == 25) {
      sub = 'Um quarto de século! Muitas possibilidades estão à sua frente.';
    } else if (age <= 29) {
      sub = 'A vida adulta ganha forma. Construa a base do seu futuro.';
    } else if (age == 30) {
      sub = 'Trinta anos! Maturidade, conquistas e novos horizontes.';
    } else if (age <= 39) {
      sub = 'Anos de construção: carreira, família e patrimônio.';
    } else if (age == 40) {
      sub = 'Você completou 40 anos. Suas decisões moldaram sua trajetória.';
    } else if (age <= 49) {
      sub = 'A experiência é sua maior aliada agora.';
    } else if (age == 50) {
      sub = 'Meio século de histórias. O que ainda falta viver?';
    } else if (age <= 64) {
      sub = 'Sabedoria acumulada e um legado em construção.';
    } else if (age <= 79) {
      sub = 'Tempo de colher o que plantou e aproveitar cada momento.';
    } else if (age <= 99) {
      sub = 'Uma vida longa e rica. Cada amanhecer é um presente.';
    } else {
      sub = 'Uma lenda viva! Poucos chegam tão longe.';
    }
    return (headline, sub);
  }

  static String _chronicle(LifeDraft d) {
    final age = d.age;
    final ctx = d.ctx;
    if (age == 1) return 'Você deu os primeiros passos e falou as primeiras palavras.';
    if (age == 2) return 'Sua curiosidade não tem fim: você mexe em tudo pela casa.';
    if (age <= 5) {
      return ctx.pick([
        'Você aprendeu a desenhar e encheu a geladeira de obras de arte.',
        'Você adora ouvir histórias antes de dormir.',
        'Seu brinquedo favorito virou seu melhor amigo inseparável.',
      ]);
    }
    if (age <= 14) {
      return ctx.pick([
        'Mais um ano escolar cheio de descobertas e amizades.',
        'Você passou as férias brincando na rua até o sol se pôr.',
        'Você descobriu um novo desenho favorito e não perde um episódio.',
      ]);
    }
    if (age <= 17) {
      return ctx.pick([
        'A fase do Ensino Médio está a todo vapor: provas, festas e planos.',
        'Você passou horas ouvindo música e pensando no futuro.',
        'Seu grupo de amigos virou sua segunda família.',
      ]);
    }
    if (age <= 29) {
      return ctx.pick([
        'Juventude intensa: experiências marcantes e muita vontade de viver.',
        'Você buscou seu lugar no mundo com coragem.',
        'Um ano de crescimento pessoal e novas responsabilidades.',
      ]);
    }
    if (age <= 59) {
      return ctx.pick([
        'Um ano de estabilidade e planejamento.',
        'Rotina corrida, mas recompensadora.',
        'Você aprendeu a valorizar os pequenos momentos.',
      ]);
    }
    return ctx.pick([
      'Celebrando a maturidade com tranquilidade e sabedoria.',
      'Você contou histórias da juventude para os mais novos.',
      'Cada manhã é um presente para quem viveu tanto.',
    ]);
  }

  static void _flavor(LifeDraft d) {
    final ctx = d.ctx;
    final people = d.living((n) => n.relationshipLevel > 50);
    if (people.isNotEmpty && ctx.chance(0.5)) {
      final n = ctx.pick(people);
      d.log('social', ctx.pick([
        '${n.fullName} (${n.relationLabel.toLowerCase()}) preparou seu doce favorito.',
        'Você passou uma tarde divertida conversando com ${n.fullName}.',
        '${n.fullName} te deu um conselho que você guardou no coração.',
        'Você e ${n.fullName} foram passear ao pôr do sol.',
      ]), icon: 'favorite_border', color: '#EC4899');
      return;
    }
    d.log('lifestyle', ctx.pick([
      'Você assistiu a um documentário fascinante sobre o cosmos.',
      'Você provou um prato exótico que surpreendeu seu paladar.',
      'Você encontrou um livro antigo na estante e devorou a leitura.',
      'Uma nova playlist virou a trilha sonora do seu ano.',
      'Uma caminhada matinal sob o céu azul te encheu de paz.',
    ]), icon: 'auto_awesome', color: '#22D3EE');
  }

  static int _baseEnergy(LifeDraft d) {
    var e = 92 + d.c.fitness ~/ 10;
    if (d.age > 50) e -= (d.age - 50) ~/ 2;
    final t = CareerCatalog.byId(d.c.currentJobId);
    if (t != null) e -= t.hoursPerWeek ~/ 4;
    if (d.c.stress > 70) e -= 10;
    return e.clamp(30, 100);
  }

  static void advance(LifeDraft d) {
    if (!d.c.isAlive) return;
    final statsBefore = d.snapshot();
    final moneyBefore = d.c.bankBalance;
    final netBefore = d.toState().netWorth;
    final relBefore = d.npcs.where((n) => n.isAlive).fold<int>(0, (s, n) => s + n.relationshipLevel);
    final jobBefore = d.c.currentJobTitle;
    final eduBefore = d.c.educationLevel;
    final npcCountBefore = d.npcs.where((n) => n.isAlive).length;

    // Novo ano
    d.c = d.c.copyWith(currentAge: d.c.currentAge + 1);
    d.x.actionsThisYear.clear();
    d.x.lastActionAge = d.age;
    d.x.bump('yearsLived');
    d.pending = [];
    d.c = d.c.copyWith(energy: _baseEnergy(d));

    final (headline, sub) = birthdayMessage(d.age);
    d.log('chronicle', '$headline ${_chronicle(d)}', icon: 'cake', color: '#7C5CFF');

    // Presente dos 18 anos conforme origem familiar
    if (d.age == 18) {
      final parents = d.living((n) => n.isParent);
      if (parents.isNotEmpty) {
        final pool = parents.fold<double>(0, (s, n) => s + n.netWorth);
        final gift = (pool * 0.02).clamp(100.0, 500000.0).roundToDouble();
        d.money(gift);
        d.log('family', 'Presente de 18 anos: seus pais te deram R\$ ${gift.toStringAsFixed(0)} para começar a vida adulta.',
            icon: 'card_giftcard', color: '#22C55E');
      }
    }

    RelationshipSystem.yearly(d);
    final wasInPrison = d.x.crime.inPrison;
    UnderworldSystem.yearly(d);
    EducationSystem.yearly(d);
    SchoolSystem.yearly(d);
    CareerSystem.yearly(d);
    BusinessSystem.yearly(d);
    FinanceSystem.yearly(d);
    HealthSystem.yearly(d);
    FameSystem.yearly(d);
    SocialMediaSystem.yearly(d);
    DatingSystem.yearly(d);

    // Evolução natural dos atributos
    final natural = <String, num>{};
    if (d.age <= 22) natural['smarts'] = 1 + d.ctx.rng.nextInt(2);
    if (d.age > 40) natural['looks'] = -(d.age > 60 ? 2 : 1);
    natural['stress'] = -4;
    // Felicidade tende ao equilíbrio conforme a vida
    final lonely = d.living((n) => n.relationshipLevel > 50).isEmpty;
    if (lonely && d.age > 12) natural['happiness'] = -5;
    if (d.c.debt > 0) natural['happiness'] = (natural['happiness'] ?? 0) - 4;
    if (d.c.happiness > 85) natural['happiness'] = (natural['happiness'] ?? 0) - 2;
    if (d.c.happiness < 30) natural['happiness'] = (natural['happiness'] ?? 0) + 4;
    d.stats(natural);

    if (d.c.bankBalance > moneyBefore && d.age >= 16) d.x.bump('savingYears');

    if (d.ctx.chance(0.6)) _flavor(d);

    // Morte
    final expectancy = d.ctx.lifeExpectancy(d.c.country);
    final oldAgeP = d.age < expectancy - 12 ? 0.0 : (d.age - (expectancy - 12)) * 0.022;
    final illP = d.c.health < 15 ? 0.25 : (d.c.health < 30 ? 0.05 : 0.0);
    final accidentP = d.age >= 16 ? 0.0012 : 0.0004;
    if (d.c.health <= 0 || d.ctx.chance(oldAgeP + illP + accidentP) || d.age >= 118) {
      final cause = d.c.health <= 15
          ? 'complicações de saúde'
          : (oldAgeP > 0 ? 'causas naturais pela idade avançada' : 'um acidente trágico');
      d.c = d.c.copyWith(isAlive: false, ageOfDeath: d.age, causeOfDeath: cause);
      d.log('death', 'Fim da jornada: você faleceu aos ${d.age} anos devido a $cause.', icon: 'dangerous', color: '#EF4444');
      d.sfx(GameSfx.death);
    } else {
      EventSystem.rollYear(d);
      d.sfx(GameSfx.ageUp);
    }

    // Resumo
    final relAfter = d.npcs.where((n) => n.isAlive).fold<int>(0, (s, n) => s + n.relationshipLevel);
    final changes = <String>[];
    if (d.c.currentJobTitle != jobBefore) {
      changes.add(d.c.currentJobTitle == null ? 'Ficou sem emprego' : 'Novo cargo: ${d.c.currentJobTitle}');
    }
    if (d.c.educationLevel != eduBefore) changes.add('Nova escolaridade alcançada');
    final npcAfter = d.npcs.where((n) => n.isAlive).length;
    if (npcAfter > npcCountBefore) changes.add('${npcAfter - npcCountBefore} pessoa(s) nova(s) na sua vida');
    if (npcAfter < npcCountBefore) changes.add('${npcCountBefore - npcAfter} pessoa(s) saíram da sua vida');
    if (!d.c.isAlive) changes.add('Sua jornada chegou ao fim');
    if (wasInPrison && !d.x.crime.inPrison) changes.add('Você saiu da prisão');
    if (!wasInPrison && d.x.crime.inPrison) changes.add('Você foi condenado(a) à prisão');
    if (d.x.crime.inPrison) changes.add('Pena restante: ${d.x.crime.yearsLeft} ano(s)');
    if (d.x.education.inSchool) changes.add('Escola: popularidade ${d.x.school.popularity}/100');
    if (d.x.social.hasAccount) changes.add('${d.x.followers} seguidores no Pulso');

    final highlights = d.newLogs.where((l) => l.category != 'chronicle').toList();
    d.summary = YearSummary(
      age: d.age,
      year: d.year,
      statBefore: statsBefore,
      statAfter: d.snapshot(),
      moneyBefore: moneyBefore,
      moneyAfter: d.c.bankBalance,
      netWorthBefore: netBefore,
      netWorthAfter: d.toState().netWorth,
      highlights: highlights,
      lifeChanges: changes,
      careerLine: d.c.currentJobTitle != null
          ? '${d.c.currentJobTitle}${d.x.company != null ? ' · ${d.x.company}' : ''}'
          : (d.x.education.isStudying ? EducationSystem.stageLabel(d.x.education) : null),
      relationshipsDelta: relAfter - relBefore,
      headline: headline,
      subtitle: sub,
    );
  }
}
