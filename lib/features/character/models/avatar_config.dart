import 'dart:convert';
import 'dart:math';

enum AvatarExpression {
  happy,
  sad,
  angry,
  surprised,
  sick,
  love,
  fear,
}

enum HairStyle {
  short,
  buzz,
  curly,
  longWavy,
  afro,
  ponytail,
  bald,
  sidePart,
}

enum FaceShape {
  round,
  oval,
  square,
}

class AvatarConfig {
  final String skinColor;
  final HairStyle hairStyle;
  final String hairColor;
  final String eyeColor;
  final FaceShape faceShape;
  final String clothesColor;
  final AvatarExpression expression;
  final bool hasGlasses;
  final bool hasBeard;

  const AvatarConfig({
    required this.skinColor,
    required this.hairStyle,
    required this.hairColor,
    required this.eyeColor,
    required this.faceShape,
    required this.clothesColor,
    this.expression = AvatarExpression.happy,
    this.hasGlasses = false,
    this.hasBeard = false,
  });

  static const List<String> availableSkins = [
    '#FFDFC4', // Claro
    '#F0D0B0', // Bege claro
    '#E0B084', // Médio
    '#D09260', // Moreno
    '#A06035', // Negro claro
    '#5C381E', // Negro retinto
  ];

  static const List<String> availableHairColors = [
    '#1C1917', // Preto
    '#451A03', // Castanho escuro
    '#78350F', // Castanho claro
    '#EAB308', // Loiro
    '#EA580C', // Ruivo
    '#E2E8F0', // Platinado
    '#3B82F6', // Azul
    '#EC4899', // Rosa
  ];

  static const List<String> availableEyeColors = [
    '#451A03', // Castanho
    '#0284C7', // Azul
    '#15803D', // Verde
    '#A16207', // Mel / Âmbar
    '#1E293B', // Preto
  ];

  static const List<String> availableClothesColors = [
    '#6366F1', // Indigo
    '#10B981', // Verde esmeralda
    '#EF4444', // Vermelho
    '#F59E0B', // Âmbar
    '#8B5CF6', // Roxo
    '#06B6D4', // Ciano
    '#1E293B', // Grafite
    '#F8FAFC', // Branco
  ];

  factory AvatarConfig.random({String? gender, Random? rng}) {
    final r = rng ?? Random();
    final skin = availableSkins[r.nextInt(availableSkins.length)];
    final hairCol = availableHairColors[r.nextInt(availableHairColors.length)];
    final eyeCol = availableEyeColors[r.nextInt(availableEyeColors.length)];
    final clothesCol = availableClothesColors[r.nextInt(availableClothesColors.length)];
    final shape = FaceShape.values[r.nextInt(FaceShape.values.length)];

    HairStyle style;
    bool beard = false;

    if (gender == 'female') {
      const femaleStyles = [
        HairStyle.longWavy,
        HairStyle.curly,
        HairStyle.ponytail,
        HairStyle.sidePart,
        HairStyle.afro,
        HairStyle.short,
      ];
      style = femaleStyles[r.nextInt(femaleStyles.length)];
    } else {
      const maleStyles = [
        HairStyle.short,
        HairStyle.buzz,
        HairStyle.sidePart,
        HairStyle.afro,
        HairStyle.curly,
        HairStyle.bald,
      ];
      style = maleStyles[r.nextInt(maleStyles.length)];
      beard = r.nextDouble() < 0.35;
    }

    final glasses = r.nextDouble() < 0.25;

    return AvatarConfig(
      skinColor: skin,
      hairStyle: style,
      hairColor: hairCol,
      eyeColor: eyeCol,
      faceShape: shape,
      clothesColor: clothesCol,
      expression: AvatarExpression.happy,
      hasGlasses: glasses,
      hasBeard: beard,
    );
  }

  AvatarConfig copyWith({
    String? skinColor,
    HairStyle? hairStyle,
    String? hairColor,
    String? eyeColor,
    FaceShape? faceShape,
    String? clothesColor,
    AvatarExpression? expression,
    bool? hasGlasses,
    bool? hasBeard,
  }) {
    return AvatarConfig(
      skinColor: skinColor ?? this.skinColor,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      eyeColor: eyeColor ?? this.eyeColor,
      faceShape: faceShape ?? this.faceShape,
      clothesColor: clothesColor ?? this.clothesColor,
      expression: expression ?? this.expression,
      hasGlasses: hasGlasses ?? this.hasGlasses,
      hasBeard: hasBeard ?? this.hasBeard,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skinColor': skinColor,
      'hairStyle': hairStyle.name,
      'hairColor': hairColor,
      'eyeColor': eyeColor,
      'faceShape': faceShape.name,
      'clothesColor': clothesColor,
      'expression': expression.name,
      'hasGlasses': hasGlasses,
      'hasBeard': hasBeard,
    };
  }

  factory AvatarConfig.fromMap(Map<String, dynamic> map) {
    return AvatarConfig(
      skinColor: map['skinColor'] ?? availableSkins[0],
      hairStyle: HairStyle.values.firstWhere(
        (e) => e.name == map['hairStyle'],
        orElse: () => HairStyle.short,
      ),
      hairColor: map['hairColor'] ?? availableHairColors[0],
      eyeColor: map['eyeColor'] ?? availableEyeColors[0],
      faceShape: FaceShape.values.firstWhere(
        (e) => e.name == map['faceShape'],
        orElse: () => FaceShape.oval,
      ),
      clothesColor: map['clothesColor'] ?? availableClothesColors[0],
      expression: AvatarExpression.values.firstWhere(
        (e) => e.name == map['expression'],
        orElse: () => AvatarExpression.happy,
      ),
      hasGlasses: map['hasGlasses'] ?? false,
      hasBeard: map['hasBeard'] ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AvatarConfig.fromJson(String source) =>
      AvatarConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
