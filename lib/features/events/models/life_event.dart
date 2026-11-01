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
  });

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

  const LifeEvent({
    required this.id,
    required this.category,
    required this.minAge,
    required this.maxAge,
    required this.title,
    required this.description,
    required this.choices,
  });

  factory LifeEvent.fromMap(Map<String, dynamic> map) {
    return LifeEvent(
      id: map['id'] as String,
      category: map['category'] as String,
      minAge: (map['minAge'] as num?)?.toInt() ?? 0,
      maxAge: (map['maxAge'] as num?)?.toInt() ?? 100,
      title: map['title'] as String,
      description: map['description'] as String,
      choices: (map['choices'] as List)
          .map((c) => EventChoice.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
