/// Dados extras de um imóvel (decoração, localização, festas).
class PropertyMeta {
  int decorLevel; // 0..5
  String decorStyle; // basic | modern | rustic | luxury | minimalist | boho
  String district;
  int sizeM2;
  int partiesHosted;

  PropertyMeta({
    this.decorLevel = 0,
    this.decorStyle = 'basic',
    this.district = '',
    this.sizeM2 = 60,
    this.partiesHosted = 0,
  });

  static const styles = {
    'basic': 'Básica',
    'modern': 'Moderna',
    'rustic': 'Rústica',
    'minimalist': 'Minimalista',
    'boho': 'Boho',
    'luxury': 'Luxo',
  };

  String get styleLabel => styles[decorStyle] ?? 'Básica';

  Map<String, dynamic> toJson() => {
        'decorLevel': decorLevel,
        'decorStyle': decorStyle,
        'district': district,
        'sizeM2': sizeM2,
        'partiesHosted': partiesHosted,
      };

  factory PropertyMeta.fromJson(Map<String, dynamic> j) => PropertyMeta(
        decorLevel: j['decorLevel'] as int? ?? 0,
        decorStyle: j['decorStyle'] as String? ?? 'basic',
        district: j['district'] as String? ?? '',
        sizeM2: j['sizeM2'] as int? ?? 60,
        partiesHosted: j['partiesHosted'] as int? ?? 0,
      );
}
