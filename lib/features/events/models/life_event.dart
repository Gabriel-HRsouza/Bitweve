/// Escolha de um evento. Os deltas clássicos (health/happiness/...) continuam
/// suportados para compatibilidade com `assets/data/events.json`; o mapa
/// [effects] permite consequências ricas (dinheiro, NPCs, emprego, fama, etc.).
class EventChoice {
  final String label;
  final int healthDelta;
  final int happinessDelta;
  final int smartsDelta;
  final int looksDelta;
  final int karmaDelta;
  final int stressDelta;
  final int reputationDelta;
  final double moneyDelta;
  final String resultText;

  /// Efeitos extras. Chaves suportadas (ver EventResolver):
  /// money, moneyPct, health, happiness, smarts, looks, karma, stress, reputation,
  /// fame, followers, charisma, energy, fitness, discipline, rel, relAll,
  /// addNpc, removeTarget, loseJob, promote, raisePct, performance, condition,
  /// cure, debt, item, arrest, license, parentsDivorce, parentsReunite,
  /// sibling, inheritance, relocate, marryTarget, breakUp, partnerFromTarget,
  /// baby, pet, course.
  final Map<String, dynamic> effects;

  /// Probabilidade de sucesso (0..1). Se nula, sempre sucesso.
  final double? chance;
  final String? failText;
  final Map<String, dynamic> failEffects;

  const EventChoice({
    required this.label,
    this.healthDelta = 0,
    this.happinessDelta = 0,
    this.smartsDelta = 0,
    this.looksDelta = 0,
    this.karmaDelta = 0,
    this.stressDelta = 0,
    this.reputationDelta = 0,
    this.moneyDelta = 0.0,
    required this.resultText,
    this.effects = const {},
    this.chance,
    this.failText,
    this.failEffects = const {},
  });

  /// Custo monetário imediato da escolha (para desabilitar se não há saldo).
  double get upfrontCost {
    final m = (effects['money'] as num?)?.toDouble() ?? moneyDelta;
    return m < 0 ? -m : 0;
  }

  factory EventChoice.fromMap(Map<String, dynamic> map) {
    return EventChoice(
      label: map['label'] as String,
      healthDelta: (map['healthDelta'] as num?)?.toInt() ?? 0,
      happinessDelta: (map['happinessDelta'] as num?)?.toInt() ?? 0,
      smartsDelta: (map['smartsDelta'] as num?)?.toInt() ?? 0,
      looksDelta: (map['looksDelta'] as num?)?.toInt() ?? 0,
      karmaDelta: (map['karmaDelta'] as num?)?.toInt() ?? 0,
      stressDelta: (map['stressDelta'] as num?)?.toInt() ?? 0,
      reputationDelta: (map['reputationDelta'] as num?)?.toInt() ?? 0,
      moneyDelta: (map['moneyDelta'] as num?)?.toDouble() ?? 0.0,
      resultText: map['resultText'] as String,
      effects: (map['effects'] as Map?)?.cast<String, dynamic>() ?? const {},
      chance: (map['chance'] as num?)?.toDouble(),
      failText: map['failText'] as String?,
      failEffects: (map['failEffects'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
  }
}

class LifeEvent {
  final String id;
  final String category;
  final int minAge;
  final int maxAge;
  final String title;
  final String description;
  final List<EventChoice> choices;

  /// Requisitos: job, noJob, partner, single, married, student, university,
  /// famous, rich, poor, parents, siblings, children, friends, adult, criminal.
  final List<String> requires;

  /// Tipo de NPC alvo para `{npc}` nos textos: parent, sibling, friend,
  /// partner, spouse, child, coworker, boss, crush, any, family.
  final String? target;
  final String rarity; // common | uncommon | rare | legendary
  final double weight;

  const LifeEvent({
    required this.id,
    required this.category,
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.description,
    required this.choices,
    this.requires = const [],
    this.target,
    this.rarity = 'common',
    this.weight = 1.0,
  });

  /// Copia substituindo `{npc}` pelo nome do alvo.
  LifeEvent personalize(String npcName, String relation) {
    String f(String s) => s.replaceAll('{npc}', npcName).replaceAll('{rel}', relation);
    return LifeEvent(
      id: id,
      category: category,
      minAge: minAge,
      maxAge: maxAge,
      title: f(title),
      description: f(description),
      requires: requires,
      target: target,
      rarity: rarity,
      weight: weight,
      choices: choices
          .map((c) => EventChoice(
                label: f(c.label),
                healthDelta: c.healthDelta,
                happinessDelta: c.happinessDelta,
                smartsDelta: c.smartsDelta,
                looksDelta: c.looksDelta,
                karmaDelta: c.karmaDelta,
                stressDelta: c.stressDelta,
                reputationDelta: c.reputationDelta,
                moneyDelta: c.moneyDelta,
                resultText: f(c.resultText),
                effects: c.effects,
                chance: c.chance,
                failText: c.failText == null ? null : f(c.failText!),
                failEffects: c.failEffects,
              ))
          .toList(),
    );
  }

  factory LifeEvent.fromMap(Map<String, dynamic> map) {
    return LifeEvent(
      id: map['id'] as String,
      category: map['category'] as String,
      minAge: (map['minAge'] as num?)?.toInt() ?? 0,
      maxAge: (map['maxAge'] as num?)?.toInt() ?? 100,
      title: map['title'] as String,
      description: map['description'] as String,
      choices: (map['choices'] as List).map((c) => EventChoice.fromMap(c as Map<String, dynamic>)).toList(),
      requires: (map['requires'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      target: map['target'] as String?,
      rarity: map['rarity'] as String? ?? 'common',
      weight: (map['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Evento pendente já personalizado, com o NPC alvo resolvido.
class PendingEvent {
  final LifeEvent event;
  final String? targetNpcId;
  const PendingEvent(this.event, {this.targetNpcId});
}

/// Resultado de uma escolha, exibido ao jogador.
class EventOutcome {
  final String title;
  final String text;
  final bool success;
  final Map<String, num> deltas; // atributo -> variação
  const EventOutcome({required this.title, required this.text, required this.success, required this.deltas});
}
