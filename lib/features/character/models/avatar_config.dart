import 'dart:convert';
import 'dart:math';

enum AvatarExpression { happy, sad, angry, surprised, sick, love, fear, neutral }

enum HairStyle {
  short,
  buzz,
  curly,
  longWavy,
  afro,
  ponytail,
  bald,
  sidePart,
  bun,
  braids,
  mohawk,
  bob,
  pixie,
  dreads,
  longStraight,
  spiky,
}

enum FaceShape { round, oval, square }

enum BodyType { slim, average, athletic, curvy, broad }

enum OutfitStyle { casual, sport, elegant, alternative, executive, urban, luxury, student, celebrity, artistic }

enum BeardStyle { none, stubble, full, goatee, mustache }

/// Acessórios disponíveis (guardados como string para facilitar evolução do save).
class AvatarAccessory {
  static const glasses = 'glasses';
  static const sunglasses = 'sunglasses';
  static const earrings = 'earrings';
  static const cap = 'cap';
  static const beanie = 'beanie';
  static const headphones = 'headphones';
  static const necklace = 'necklace';
  static const goldChain = 'gold_chain';
  static const beret = 'beret';
  static const headband = 'headband';
  static const freckles = 'freckles';
  static const blush = 'blush';

  static const all = [
    glasses, sunglasses, earrings, cap, beanie, headphones,
    necklace, goldChain, beret, headband, freckles, blush,
  ];

  /// Acessórios que ocupam a cabeça — só um por vez.
  static const headwear = [cap, beanie, beret, headband, headphones];
  static const eyewear = [glasses, sunglasses];

  static String label(String id) {
    switch (id) {
      case glasses: return 'Óculos';
      case sunglasses: return 'Óculos escuros';
      case earrings: return 'Brincos';
      case cap: return 'Boné';
      case beanie: return 'Gorro';
      case headphones: return 'Fones';
      case necklace: return 'Colar';
      case goldChain: return 'Corrente de ouro';
      case beret: return 'Boina';
      case headband: return 'Faixa';
      case freckles: return 'Sardas';
      case blush: return 'Blush';
    }
    return id;
  }
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
  final BodyType bodyType;
  final OutfitStyle outfit;
  final BeardStyle beardStyle;
  final List<String> accessories;

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
    this.bodyType = BodyType.average,
    this.outfit = OutfitStyle.casual,
    this.beardStyle = BeardStyle.none,
    this.accessories = const [],
  });

  bool has(String accessory) =>
      accessories.contains(accessory) || (accessory == AvatarAccessory.glasses && hasGlasses);

  BeardStyle get effectiveBeard =>
      beardStyle != BeardStyle.none ? beardStyle : (hasBeard ? BeardStyle.full : BeardStyle.none);

  static const List<String> availableSkins = [
    '#FFE3CC', '#F6CFAE', '#E8B48A', '#D49A6A', '#B07548', '#8A5530', '#5E3A1F', '#3F2614',
  ];
  static const List<String> skinNames = [
    'Porcelana', 'Clara', 'Bege', 'Dourada', 'Morena', 'Canela', 'Negra', 'Ébano',
  ];

  static const List<String> availableHairColors = [
    '#1C1917', '#3B2314', '#6B3E1F', '#A0652F', '#E0B04B', '#F2D98C',
    '#C2410C', '#E2E8F0', '#9CA3AF', '#3B82F6', '#EC4899', '#8B5CF6', '#10B981',
  ];
  static const List<String> hairColorNames = [
    'Preto', 'Castanho escuro', 'Castanho', 'Caramelo', 'Loiro', 'Loiro claro',
    'Ruivo', 'Platinado', 'Grisalho', 'Azul', 'Rosa', 'Lilás', 'Verde',
  ];

  static const List<String> availableEyeColors = [
    '#4A2A12', '#7A4A1E', '#A16207', '#15803D', '#0284C7', '#6B7280', '#111827',
  ];
  static const List<String> eyeColorNames = [
    'Castanho escuro', 'Castanho', 'Mel', 'Verde', 'Azul', 'Cinza', 'Preto',
  ];

  static const List<String> availableClothesColors = [
    '#7C5CFF', '#22D3EE', '#22C55E', '#FF5470', '#FFC53D', '#FF8A3D',
    '#EC4899', '#1E293B', '#F8FAFC', '#0EA5E9', '#A16207', '#14B8A6',
  ];

  static String hairStyleLabel(HairStyle s) {
    switch (s) {
      case HairStyle.short: return 'Curto';
      case HairStyle.buzz: return 'Raspado';
      case HairStyle.curly: return 'Cacheado';
      case HairStyle.longWavy: return 'Longo ondulado';
      case HairStyle.afro: return 'Black power';
      case HairStyle.ponytail: return 'Rabo de cavalo';
      case HairStyle.bald: return 'Careca';
      case HairStyle.sidePart: return 'Social';
      case HairStyle.bun: return 'Coque';
      case HairStyle.braids: return 'Tranças';
      case HairStyle.mohawk: return 'Moicano';
      case HairStyle.bob: return 'Chanel';
      case HairStyle.pixie: return 'Pixie';
      case HairStyle.dreads: return 'Dreads';
      case HairStyle.longStraight: return 'Longo liso';
      case HairStyle.spiky: return 'Espetado';
    }
  }

  static String bodyLabel(BodyType b) {
    switch (b) {
      case BodyType.slim: return 'Magro';
      case BodyType.average: return 'Médio';
      case BodyType.athletic: return 'Atlético';
      case BodyType.curvy: return 'Curvilíneo';
      case BodyType.broad: return 'Robusto';
    }
  }

  static String outfitLabel(OutfitStyle o) {
    switch (o) {
      case OutfitStyle.casual: return 'Casual';
      case OutfitStyle.sport: return 'Esportivo';
      case OutfitStyle.elegant: return 'Elegante';
      case OutfitStyle.alternative: return 'Alternativo';
      case OutfitStyle.executive: return 'Executivo';
      case OutfitStyle.urban: return 'Urbano';
      case OutfitStyle.luxury: return 'Luxuoso';
      case OutfitStyle.student: return 'Estudante';
      case OutfitStyle.celebrity: return 'Celebridade';
      case OutfitStyle.artistic: return 'Artístico';
    }
  }

  static String beardLabel(BeardStyle b) {
    switch (b) {
      case BeardStyle.none: return 'Sem barba';
      case BeardStyle.stubble: return 'Por fazer';
      case BeardStyle.full: return 'Cheia';
      case BeardStyle.goatee: return 'Cavanhaque';
      case BeardStyle.mustache: return 'Bigode';
    }
  }

  static const _femaleStyles = [
    HairStyle.longWavy, HairStyle.curly, HairStyle.ponytail, HairStyle.sidePart, HairStyle.afro,
    HairStyle.bun, HairStyle.braids, HairStyle.bob, HairStyle.pixie, HairStyle.longStraight,
  ];
  static const _maleStyles = [
    HairStyle.short, HairStyle.buzz, HairStyle.sidePart, HairStyle.afro, HairStyle.curly,
    HairStyle.bald, HairStyle.mohawk, HairStyle.dreads, HairStyle.spiky,
  ];

  factory AvatarConfig.random({String? gender, Random? rng}) {
    final r = rng ?? Random();
    T pick<T>(List<T> l) => l[r.nextInt(l.length)];
    final female = gender == 'female';
    final style = female ? pick(_femaleStyles) : pick(_maleStyles);
    // Cores de cabelo naturais são mais prováveis
    final hair = r.nextDouble() < 0.85
        ? availableHairColors[r.nextInt(7)]
        : pick(availableHairColors);
    final acc = <String>[];
    if (r.nextDouble() < 0.2) acc.add(AvatarAccessory.glasses);
    if (female && r.nextDouble() < 0.45) acc.add(AvatarAccessory.earrings);
    if (r.nextDouble() < 0.12) acc.add(AvatarAccessory.freckles);
    final beard = !female && r.nextDouble() < 0.35
        ? pick([BeardStyle.stubble, BeardStyle.full, BeardStyle.goatee, BeardStyle.mustache])
        : BeardStyle.none;
    return AvatarConfig(
      skinColor: pick(availableSkins),
      hairStyle: style,
      hairColor: hair,
      eyeColor: pick(availableEyeColors),
      faceShape: pick(FaceShape.values),
      clothesColor: pick(availableClothesColors),
      bodyType: pick(BodyType.values),
      outfit: pick(OutfitStyle.values),
      beardStyle: beard,
      accessories: acc,
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
    BodyType? bodyType,
    OutfitStyle? outfit,
    BeardStyle? beardStyle,
    List<String>? accessories,
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
      bodyType: bodyType ?? this.bodyType,
      outfit: outfit ?? this.outfit,
      beardStyle: beardStyle ?? this.beardStyle,
      accessories: accessories ?? this.accessories,
    );
  }

  /// Liga/desliga acessório respeitando exclusividade (um chapéu, um óculos).
  AvatarConfig toggleAccessory(String id) {
    final list = List<String>.from(accessories);
    if (id == AvatarAccessory.glasses && hasGlasses) {
      return copyWith(hasGlasses: false, accessories: list..remove(id));
    }
    if (list.contains(id)) {
      list.remove(id);
    } else {
      if (AvatarAccessory.headwear.contains(id)) list.removeWhere(AvatarAccessory.headwear.contains);
      if (AvatarAccessory.eyewear.contains(id)) list.removeWhere(AvatarAccessory.eyewear.contains);
      if (id == AvatarAccessory.goldChain) list.remove(AvatarAccessory.necklace);
      if (id == AvatarAccessory.necklace) list.remove(AvatarAccessory.goldChain);
      list.add(id);
    }
    return copyWith(accessories: list, hasGlasses: false);
  }

  Map<String, dynamic> toMap() => {
        'skinColor': skinColor,
        'hairStyle': hairStyle.name,
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'faceShape': faceShape.name,
        'clothesColor': clothesColor,
        'expression': expression.name,
        'hasGlasses': hasGlasses,
        'hasBeard': hasBeard,
        'bodyType': bodyType.name,
        'outfit': outfit.name,
        'beardStyle': beardStyle.name,
        'accessories': accessories,
      };

  static T _enum<T extends Enum>(List<T> values, dynamic name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  factory AvatarConfig.fromMap(Map<String, dynamic> map) {
    return AvatarConfig(
      skinColor: map['skinColor'] as String? ?? availableSkins[1],
      hairStyle: _enum(HairStyle.values, map['hairStyle'], HairStyle.short),
      hairColor: map['hairColor'] as String? ?? availableHairColors[0],
      eyeColor: map['eyeColor'] as String? ?? availableEyeColors[0],
      faceShape: _enum(FaceShape.values, map['faceShape'], FaceShape.oval),
      clothesColor: map['clothesColor'] as String? ?? availableClothesColors[0],
      expression: _enum(AvatarExpression.values, map['expression'], AvatarExpression.happy),
      hasGlasses: map['hasGlasses'] as bool? ?? false,
      hasBeard: map['hasBeard'] as bool? ?? false,
      bodyType: _enum(BodyType.values, map['bodyType'], BodyType.average),
      outfit: _enum(OutfitStyle.values, map['outfit'], OutfitStyle.casual),
      beardStyle: _enum(BeardStyle.values, map['beardStyle'], BeardStyle.none),
      accessories: (map['accessories'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AvatarConfig.fromJson(String source) {
    try {
      return AvatarConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);
    } catch (_) {
      return AvatarConfig.random();
    }
  }
}
