import 'package:bitweve/features/character/models/avatar_config.dart';

enum RelationshipType {
  father,
  mother,
  stepfather,
  stepmother,
  brother,
  sister,
  grandfather,
  grandmother,
  son,
  daughter,
  friend,
  partner, // namorado(a)
  spouse, // esposo(a)
  exPartner,
  coworker,
  boss,
  rival,
}

class NpcModel {
  final String id;
  final String saveId;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final RelationshipType relationshipType;
  final int relationshipLevel; // 0 a 100
  final int respectLevel; // 0 a 100
  final AvatarConfig avatarConfig;
  final String occupation;
  final double salary;
  final double netWorth;
  final int health;
  final int happiness;
  final bool isAlive;
  final String? causeOfDeath;
  final List<String> memories;

  const NpcModel({
    required this.id,
    required this.saveId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.relationshipType,
    this.relationshipLevel = 80,
    this.respectLevel = 70,
    required this.avatarConfig,
    this.occupation = 'Estudante',
    this.salary = 0.0,
    this.netWorth = 1000.0,
    this.health = 90,
    this.happiness = 85,
    this.isAlive = true,
    this.causeOfDeath,
    this.memories = const [],
  });

  String get fullName => '$firstName $lastName';

  String get relationLabel {
    switch (relationshipType) {
      case RelationshipType.father:
        return 'Pai';
      case RelationshipType.mother:
        return 'Mãe';
      case RelationshipType.stepfather:
        return 'Padrasto';
      case RelationshipType.stepmother:
        return 'Madrasta';
      case RelationshipType.brother:
        return 'Irmão';
      case RelationshipType.sister:
        return 'Irmã';
      case RelationshipType.grandfather:
        return 'Avô';
      case RelationshipType.grandmother:
        return 'Avó';
      case RelationshipType.son:
        return 'Filho';
      case RelationshipType.daughter:
        return 'Filha';
      case RelationshipType.friend:
        return 'Amigo(a)';
      case RelationshipType.partner:
        return gender == 'female' ? 'Namorada' : 'Namorado';
      case RelationshipType.spouse:
        return gender == 'female' ? 'Esposa' : 'Esposo';
      case RelationshipType.exPartner:
        return 'Ex-parceiro(a)';
      case RelationshipType.coworker:
        return 'Colega de Trabalho';
      case RelationshipType.boss:
        return 'Chefe';
      case RelationshipType.rival:
        return 'Rival';
    }
  }

  NpcModel copyWith({
    String? id,
    String? saveId,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    RelationshipType? relationshipType,
    int? relationshipLevel,
    int? respectLevel,
    AvatarConfig? avatarConfig,
    String? occupation,
    double? salary,
    double? netWorth,
    int? health,
    int? happiness,
    bool? isAlive,
    String? causeOfDeath,
    List<String>? memories,
  }) {
    return NpcModel(
      id: id ?? this.id,
      saveId: saveId ?? this.saveId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      relationshipType: relationshipType ?? this.relationshipType,
      relationshipLevel: (relationshipLevel ?? this.relationshipLevel).clamp(0, 100),
      respectLevel: (respectLevel ?? this.respectLevel).clamp(0, 100),
      avatarConfig: avatarConfig ?? this.avatarConfig,
      occupation: occupation ?? this.occupation,
      salary: salary ?? this.salary,
      netWorth: netWorth ?? this.netWorth,
      health: (health ?? this.health).clamp(0, 100),
      happiness: (happiness ?? this.happiness).clamp(0, 100),
      isAlive: isAlive ?? this.isAlive,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      memories: memories ?? this.memories,
    );
  }

  static RelationshipType parseRelationType(String val) {
    return RelationshipType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => RelationshipType.friend,
    );
  }
}
