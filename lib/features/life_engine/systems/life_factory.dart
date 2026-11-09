import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'life_draft.dart';

class LifeFactory {
  static CharacterSetup randomSetup(
    EngineContext ctx, {
    String? countryId,
    String? city,
    String? gender,
    String? firstName,
    String? lastName,
  }) {
    final g = gender ?? ctx.gender();
    final wealthRoll = ctx.roll();
    final wealth = wealthRoll < 0.25 ? 'poor' : (wealthRoll < 0.85 ? 'middle' : (wealthRoll < 0.97 ? 'rich' : 'elite'));
    final orientationRoll = ctx.roll();
    return CharacterSetup(
      firstName: firstName ?? ctx.firstName(g),
      lastName: lastName ?? ctx.lastName(),
      gender: g,
      sexualOrientation: orientationRoll < 0.86 ? 'heterosexual' : (orientationRoll < 0.93 ? 'homosexual' : 'bisexual'),
      birthDay: ctx.range(1, 28),
      birthMonth: ctx.range(1, 12),
      birthYear: DateTime.now().year,
      countryId: countryId ?? 'br',
      city: city,
      familyWealth: wealth,
      siblings: ctx.chance(0.45) ? ctx.range(1, 2) : 0,
      parentsTogether: ctx.chance(0.8),
      personality: ctx.pick(CharacterOptions.personalities).id,
      traits: [if (ctx.chance(0.7)) ctx.pick(CharacterOptions.traits).id],
      avatar: AvatarConfig.random(gender: g, rng: ctx.rng),
    );
  }

  static LifeEngineState create(EngineContext ctx, CharacterSetup s) {
    final saveId = ctx.id();
    final country = ctx.countries.firstWhere((c) => c['id'] == s.countryId, orElse: () => ctx.countryByName('Brasil'));
    final countryName = country['name'] as String? ?? 'Brasil';
    final cities = ((country['cities'] as List?) ?? const ['São Paulo']).cast<String>();
    final city = (s.city != null && s.city!.isNotEmpty) ? s.city! : ctx.pick(cities);
    final avatar = (s.avatar as AvatarConfig?) ?? AvatarConfig.random(gender: s.gender, rng: ctx.rng);

    // Atributos base + personalidade + traços
    final stats = <String, int>{
      'health': 85 + ctx.rng.nextInt(15),
      'happiness': 80 + ctx.rng.nextInt(20),
      'smarts': 35 + ctx.rng.nextInt(45),
      'looks': 35 + ctx.rng.nextInt(45),
      'discipline': 30 + ctx.rng.nextInt(40),
      'charisma': 30 + ctx.rng.nextInt(40),
      'fitness': 45 + ctx.rng.nextInt(35),
      'karma': 50,
      'reputation': 50,
      'stress': 5,
    };
    void add(Map<String, int> m) => m.forEach((k, v) => stats[k] = ((stats[k] ?? 50) + v).clamp(0, 100));
    add(CharacterOptions.personality(s.personality).stats);
    for (final t in s.traits) {
      final opt = CharacterOptions.trait(t);
      if (opt != null) add(opt.stats);
    }

    final character = CharacterModel(
      id: ctx.id(),
      saveId: saveId,
      firstName: s.firstName.trim().isEmpty ? ctx.firstName(s.gender) : s.firstName.trim(),
      lastName: s.lastName.trim().isEmpty ? ctx.lastName() : s.lastName.trim(),
      gender: s.gender,
      sexualOrientation: s.sexualOrientation,
      birthYear: s.birthYear,
      currentAge: 0,
      country: countryName,
      city: city,
      avatarConfig: avatar,
      health: stats['health']!,
      happiness: stats['happiness']!,
      smarts: stats['smarts']!,
      looks: stats['looks']!,
      energy: 100,
      stress: stats['stress']!,
      discipline: stats['discipline']!,
      charisma: stats['charisma']!,
      fitness: stats['fitness']!,
      reputation: stats['reputation']!,
      fame: s.familyWealth == 'elite' ? 8 : 0,
      karma: stats['karma']!,
    );

    final fam = CharacterOptions.family(s.familyWealth);
    double nw() => fam.minNetWorth + ctx.roll() * (fam.maxNetWorth - fam.minNetWorth);
    double sal() => fam.minSalary + ctx.roll() * (fam.maxSalary - fam.minSalary);
    NpcModel parent(String g, RelationshipType t, String last) => NpcModel(
          id: ctx.id(),
          saveId: saveId,
          firstName: ctx.firstName(g),
          lastName: last,
          gender: g,
          age: 22 + ctx.rng.nextInt(16),
          relationshipType: t,
          relationshipLevel: 72 + ctx.rng.nextInt(26),
          respectLevel: 70 + ctx.rng.nextInt(25),
          avatarConfig: AvatarConfig.random(gender: g, rng: ctx.rng),
          occupation: ctx.commonJob(),
          salary: sal().roundToDouble(),
          netWorth: nw().roundToDouble(),
          health: 80 + ctx.rng.nextInt(20),
          happiness: 70 + ctx.rng.nextInt(25),
        );
    final father = parent('male', RelationshipType.father, character.lastName);
    final mother = parent('female', RelationshipType.mother, ctx.lastName());
    final npcs = <NpcModel>[father, mother];
    for (var i = 0; i < s.siblings.clamp(0, 4); i++) {
      final g = ctx.gender();
      npcs.add(NpcModel(
        id: ctx.id(),
        saveId: saveId,
        firstName: ctx.firstName(g),
        lastName: character.lastName,
        gender: g,
        age: 1 + ctx.rng.nextInt(8),
        relationshipType: g == 'male' ? RelationshipType.brother : RelationshipType.sister,
        relationshipLevel: 65 + ctx.rng.nextInt(30),
        avatarConfig: AvatarConfig.random(gender: g, rng: ctx.rng),
        occupation: 'Criança',
        salary: 0,
        netWorth: 0,
      ));
    }
    if (ctx.chance(0.6)) {
      final g = ctx.gender();
      npcs.add(NpcModel(
        id: ctx.id(),
        saveId: saveId,
        firstName: ctx.firstName(g),
        lastName: ctx.chance(0.5) ? father.lastName : mother.lastName,
        gender: g,
        age: 58 + ctx.rng.nextInt(18),
        relationshipType: g == 'male' ? RelationshipType.grandfather : RelationshipType.grandmother,
        relationshipLevel: 70 + ctx.rng.nextInt(28),
        avatarConfig: AvatarConfig.random(gender: g, rng: ctx.rng).copyWith(hairColor: '#9CA3AF'),
        occupation: 'Aposentado(a)',
        salary: 20000,
        netWorth: nw().roundToDouble(),
      ));
    }

    final extras = LifeExtras(
      birthDay: s.birthDay,
      birthMonth: s.birthMonth,
      personality: s.personality,
      traits: List.of(s.traits),
      familyWealth: s.familyWealth,
    );
    if (!s.parentsTogether) extras.counters['parentsDivorced'] = 1;

    final birthText = 'Você nasceu em $city, $countryName, no dia ${s.birthDay} de ${CharacterOptions.months[s.birthMonth - 1]} '
        'de ${s.birthYear} (${CharacterOptions.zodiac(s.birthDay, s.birthMonth)}). '
        'Seus pais são ${father.fullName} e ${mother.fullName} — família ${fam.name.toLowerCase()}.'
        '${s.parentsTogether ? '' : ' Eles não vivem juntos.'}';
    final log = LifeLog(
      id: ctx.id(),
      saveId: saveId,
      age: 0,
      year: s.birthYear,
      category: 'birth',
      textContent: birthText,
      icon: 'child_friendly',
      accentColor: '#22C55E',
      createdAt: DateTime.now(),
    );

    return LifeEngineState(
      saveId: saveId,
      slotName: 'Vida de ${character.fullName}',
      generation: 1,
      character: character,
      npcs: npcs,
      properties: const [],
      investments: const [],
      logs: [log],
      extras: extras,
    );
  }

  /// Continua a história como um filho(a). Patrimônio é herdado (menos impostos).
  static LifeEngineState heir(EngineContext ctx, LifeEngineState s, String heirId) {
    final heir = s.npcs.firstWhere((n) => n.id == heirId);
    final dead = s.character;
    final newSave = ctx.id();
    final gross = s.character.bankBalance + s.investmentsValue + s.cryptoValue + s.businessValue - s.character.debt - s.extras.loansTotal;
    final tax = gross > 0 ? gross * 0.08 : 0.0;
    final cash = (gross - tax).clamp(0.0, double.infinity).toDouble();

    final c = CharacterModel(
      id: ctx.id(),
      saveId: newSave,
      firstName: heir.firstName,
      lastName: heir.lastName,
      gender: heir.gender,
      sexualOrientation: ctx.roll() < 0.86 ? 'heterosexual' : 'bisexual',
      birthYear: dead.birthYear + dead.currentAge - heir.age,
      currentAge: heir.age,
      country: dead.country,
      city: dead.city,
      avatarConfig: heir.avatarConfig,
      bankBalance: cash,
      health: heir.health,
      happiness: 70,
      smarts: 40 + ctx.rng.nextInt(45),
      looks: 40 + ctx.rng.nextInt(45),
      charisma: 35 + ctx.rng.nextInt(40),
      discipline: 35 + ctx.rng.nextInt(40),
      fitness: 45 + ctx.rng.nextInt(35),
      fame: (dead.fame * 0.4).round(),
      educationLevel: heir.age >= 18 ? 'high_school' : (heir.age >= 15 ? 'elementary' : 'none'),
    );

    // NPCs: o falecido vira pai/mãe falecido(a); cônjuge vira pai/mãe; irmãos herdados
    final npcs = <NpcModel>[];
    final deadParentType = dead.gender == 'female' ? RelationshipType.mother : RelationshipType.father;
    npcs.add(NpcModel(
      id: ctx.id(),
      saveId: newSave,
      firstName: dead.firstName,
      lastName: dead.lastName,
      gender: dead.gender,
      age: dead.currentAge,
      relationshipType: deadParentType,
      relationshipLevel: heir.relationshipLevel,
      avatarConfig: dead.avatarConfig,
      occupation: dead.currentJobTitle ?? 'Aposentado(a)',
      isAlive: false,
      causeOfDeath: dead.causeOfDeath,
      memories: ['Deixou um legado de ${Fmt.money(s.netWorth)}.'],
    ));
    for (final n in s.npcs.where((n) => n.isAlive && n.id != heirId)) {
      RelationshipType? t;
      if (n.relationshipType == RelationshipType.spouse || n.relationshipType == RelationshipType.partner) {
        t = n.gender == 'female' ? RelationshipType.mother : RelationshipType.father;
      } else if (n.isChild) {
        t = n.gender == 'female' ? RelationshipType.sister : RelationshipType.brother;
      } else if (n.isParent) {
        t = n.gender == 'female' ? RelationshipType.grandmother : RelationshipType.grandfather;
      }
      if (t == null) continue;
      npcs.add(n.copyWith(id: ctx.id(), saveId: newSave, relationshipType: t, relationshipLevel: (n.relationshipLevel * 0.8).round()));
    }

    final x = LifeExtras(
      familyWealth: s.netWorth > 10000000 ? 'elite' : (s.netWorth > 800000 ? 'rich' : (s.netWorth > 50000 ? 'middle' : 'poor')),
      ancestors: [
        ...s.extras.ancestors,
        Ancestor(
          name: dead.fullName,
          generation: s.generation,
          birthYear: dead.birthYear,
          ageOfDeath: dead.ageOfDeath ?? dead.currentAge,
          job: dead.currentJobTitle ?? (s.extras.jobHistory.isNotEmpty ? s.extras.jobHistory.last.title : null),
          netWorth: s.netWorth,
          avatarJson: dead.avatarConfig.toJson(),
        ),
      ],
      vehicles: s.extras.vehicles.map((v) => v).toList(),
      inventory: s.extras.inventory.map((i) => i).toList(),
      crypto: const [],
      pets: s.extras.pets.where((p) => p.alive).toList(),
    );
    if (heir.age >= 18) {
      x.education.stage = 'hs_graduate';
      x.education.completedDegrees.add('high_school');
    }
    final props = s.properties.map((p) => p.copyWith(id: ctx.id(), saveId: newSave)).toList();
    final log = LifeLog(
      id: ctx.id(),
      saveId: newSave,
      age: heir.age,
      year: c.birthYear + heir.age,
      category: 'milestone',
      textContent: 'Você assumiu o legado de ${dead.fullName}: ${Fmt.money(cash)} em dinheiro (após ${Fmt.money(tax)} de impostos), '
          '${props.length} imóvel(is) e ${x.vehicles.length} veículo(s). Geração ${s.generation + 1} começa agora.',
      icon: 'military_tech',
      accentColor: '#FFC53D',
      createdAt: DateTime.now(),
    );
    return LifeEngineState(
      saveId: newSave,
      slotName: 'Dinastia ${c.lastName}: ${c.fullName} (Geração ${s.generation + 1})',
      generation: s.generation + 1,
      character: c,
      npcs: npcs,
      properties: props,
      investments: const [],
      logs: [log],
      extras: x,
    );
  }

  /// Recomeça do nascimento com a mesma identidade e aparência.
  static LifeEngineState restart(EngineContext ctx, LifeEngineState s) {
    final c = s.character;
    final countryId = ctx.countries.firstWhere((e) => e['name'] == c.country, orElse: () => {'id': 'br'})['id'] as String;
    return create(
      ctx,
      CharacterSetup(
        firstName: c.firstName,
        lastName: c.lastName,
        gender: c.gender,
        sexualOrientation: c.sexualOrientation,
        birthDay: s.extras.birthDay,
        birthMonth: s.extras.birthMonth,
        birthYear: DateTime.now().year,
        countryId: countryId,
        city: c.city,
        familyWealth: s.extras.familyWealth,
        personality: s.extras.personality,
        traits: s.extras.traits,
        avatar: c.avatarConfig.copyWith(expression: AvatarExpression.happy),
      ),
    );
  }
}
