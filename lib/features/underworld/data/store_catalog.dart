import 'dart:math';

import 'package:flutter/material.dart';

/// Categoria de estabelecimento (fictício).
class StoreCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> colors;
  final int baseDifficulty; // 1..5
  final double baseLoot;
  final List<String> prefixes;
  final List<String> cores;
  final List<String> products;

  const StoreCategory(this.id, this.name, this.icon, this.colors, this.baseDifficulty, this.baseLoot, this.prefixes, this.cores, this.products);
}

/// Loja gerada proceduralmente. Todos os nomes são fictícios.
class StoreInfo {
  final String id;
  final int index;
  final String name;
  final StoreCategory category;
  final String district;
  final int difficulty; // 1..5
  final double lootValue; // valor potencial por tentativa
  final int guards; // perseguidores no minigame
  final int cameras;
  final List<String> products;
  final int awning; // estilo visual
  final int seed;

  const StoreInfo({
    required this.id,
    required this.index,
    required this.name,
    required this.category,
    required this.district,
    required this.difficulty,
    required this.lootValue,
    required this.guards,
    required this.cameras,
    required this.products,
    required this.awning,
    required this.seed,
  });

  String get riskLabel => switch (difficulty) {
        1 => 'Risco baixo',
        2 => 'Risco moderado',
        3 => 'Risco alto',
        4 => 'Risco muito alto',
        _ => 'Risco extremo',
      };
}

class StoreCatalog {
  static const categories = <StoreCategory>[
    StoreCategory('supermarket', 'Supermercado', Icons.local_grocery_store_rounded, [Color(0xFF22C55E), Color(0xFF15803D)], 2, 220,
        ['Super', 'Hiper', 'Mercado', 'Atacadão'], ['Bom Preço', 'Econômico', 'Família', 'Campeão', 'Cesta Cheia', 'Vila Nova', 'Fartura', 'Pão & Cia'],
        ['Chocolates importados', 'Café gourmet', 'Queijos finos', 'Azeite premium', 'Energéticos']),
    StoreCategory('clothing', 'Loja de Roupas', Icons.checkroom_rounded, [Color(0xFFEC4899), Color(0xFF9D174D)], 2, 380,
        ['Boutique', 'Moda', 'Ateliê', 'Closet'], ['Estilo Urbano', 'Vitrine', 'Fio de Ouro', 'Trama', 'Look Certo', 'Bossa', 'Linho & Seda', 'Street Wave'],
        ['Jaquetas de grife', 'Tênis edição limitada', 'Óculos de sol', 'Bolsas', 'Relógios de moda']),
    StoreCategory('electronics', 'Eletrônicos', Icons.devices_rounded, [Color(0xFF3B82F6), Color(0xFF1E3A8A)], 3, 1400,
        ['Tech', 'Mega', 'Digital', 'Planeta'], ['Byte', 'Circuito', 'Pixel', 'Conecta', 'Volt', 'Nexo Eletro', 'Chip & Cia', 'Ultra Som'],
        ['Fones sem fio', 'Smartwatches', 'Consoles portáteis', 'Caixas de som', 'Tablets']),
    StoreCategory('jewelry', 'Joalheria', Icons.diamond_rounded, [Color(0xFFFFC53D), Color(0xFF92400E)], 5, 9000,
        ['Joalheria', 'Maison', 'Ourivesaria', 'Gemas'], ['Brilhante', 'Quilate', 'Esmeralda', 'Aurum', 'Safira Real', 'Diadema', 'Ouro Fino', 'Lumière'],
        ['Anéis de ouro', 'Colares de pérola', 'Brincos de diamante', 'Relógios suíços', 'Pulseiras']),
    StoreCategory('pharmacy', 'Farmácia', Icons.local_pharmacy_rounded, [Color(0xFF14B8A6), Color(0xFF115E59)], 2, 260,
        ['Drogaria', 'Farmácia', 'Botica', 'Farma'], ['Saúde Já', 'Vida Plena', 'Bem Estar', 'Popular', 'Cruz Verde', 'São Lucas', 'Farmavida', 'Pague Pouco'],
        ['Perfumes', 'Cosméticos', 'Protetores solares', 'Kits de beleza', 'Vitaminas']),
    StoreCategory('convenience', 'Conveniência', Icons.storefront_rounded, [Color(0xFFF97316), Color(0xFF9A3412)], 1, 120,
        ['Conveniência', 'Express', 'Loja', 'Mini'], ['24 Horas', 'Esquina', 'Parada Certa', 'Pit Stop', 'Rapidinho', 'Corujão', 'Já Já', 'Ponto Certo'],
        ['Salgadinhos', 'Refrigerantes', 'Doces', 'Cartões-presente', 'Pilhas']),
    StoreCategory('market', 'Mercadinho', Icons.shopping_basket_rounded, [Color(0xFF84CC16), Color(0xFF3F6212)], 1, 90,
        ['Mercadinho', 'Empório', 'Armazém', 'Quitanda'], ['do Seu Zé', 'da Dona Rosa', 'Bairro Feliz', 'Sabor da Terra', 'Recanto', 'Ponto Verde', 'Celeiro', 'Tia Nena'],
        ['Frutas', 'Doces caseiros', 'Biscoitos', 'Temperos', 'Produtos artesanais']),
    StoreCategory('luxury', 'Loja de Luxo', Icons.workspace_premium_rounded, [Color(0xFFA855F7), Color(0xFF3B0764)], 5, 12000,
        ['Maison', 'Atelier', 'Galeria', 'House of'], ['Valentim', 'Montclair', 'Belleville', 'Aurélie', 'Castellani', 'Noir', 'Riviera', 'Saint-Clair'],
        ['Bolsas de couro', 'Lenços de seda', 'Perfumes raros', 'Canetas de luxo', 'Óculos de grife']),
    StoreCategory('mall', 'Shopping Center', Icons.local_mall_rounded, [Color(0xFF06B6D4), Color(0xFF164E63)], 4, 3200,
        ['Shopping', 'Mall', 'Plaza', 'Center'], ['Iguaçu', 'Horizonte', 'Boulevard', 'Paralela', 'Atlântico', 'Cidade Jardim', 'Metrópole', 'Vale Sul'],
        ['Eletrônicos variados', 'Roupas de marca', 'Brinquedos', 'Acessórios', 'Livros raros']),
    StoreCategory('small', 'Pequeno Comércio', Icons.store_mall_directory_rounded, [Color(0xFF64748B), Color(0xFF1E293B)], 1, 160,
        ['Bazar', 'Papelaria', 'Loja', 'Brechó'], ['Arte & Papel', 'Tudo Tem', 'Achados', 'Cantinho', 'Retrô', 'Variedades', 'Mil Coisas', 'Utilidades'],
        ['Cadernos importados', 'Canetas', 'Brinquedos', 'Discos de vinil', 'Decoração']),
  ];

  static const _districts = [
    'Centro', 'Vila Mariana', 'Jardins', 'Copacabana', 'Savassi', 'Batel', 'Pituba', 'Moinhos', 'Boa Viagem', 'Meireles',
    'Vila Madalena', 'Botafogo', 'Lourdes', 'Água Verde', 'Barra', 'Pinheiros', 'Tijuca', 'Funcionários', 'Ecoville', 'Itaim',
    'Lapa', 'Leblon', 'Pampulha', 'Mercês', 'Ondina', 'Mooca', 'Flamengo', 'Cidade Nova', 'Bigorrilho', 'Graça',
  ];

  static const total = 1000;
  static List<StoreInfo>? _all;

  /// Catálogo completo (gerado uma vez, determinístico).
  static List<StoreInfo> get all => _all ??= _generate();

  static List<StoreInfo> _generate() {
    final out = <StoreInfo>[];
    final used = <String>{};
    for (var i = 0; i < total; i++) {
      final rng = Random(i * 7919 + 31);
      final cat = categories[i % categories.length];
      var name = '${cat.prefixes[rng.nextInt(cat.prefixes.length)]} ${cat.cores[rng.nextInt(cat.cores.length)]}';
      final district = _districts[rng.nextInt(_districts.length)];
      if (used.contains(name)) name = '$name — $district';
      var n = 2;
      while (used.contains(name)) {
        name = '${name.split(' #').first} #${n++}';
      }
      used.add(name);
      final diff = (cat.baseDifficulty + rng.nextInt(3) - 1).clamp(1, 5);
      final loot = (cat.baseLoot * (0.6 + rng.nextDouble() * 0.9) * (0.8 + diff * 0.15)).roundToDouble();
      final prods = List.of(cat.products)..shuffle(rng);
      out.add(StoreInfo(
        id: 'st_$i',
        index: i,
        name: name,
        category: cat,
        district: district,
        difficulty: diff,
        lootValue: loot,
        guards: (diff + 1) ~/ 2 + (diff >= 4 ? 1 : 0),
        cameras: diff + rng.nextInt(2),
        products: prods.take(3).toList(),
        awning: rng.nextInt(4),
        seed: i * 131 + 7,
      ));
    }
    return out;
  }

  static StoreInfo? byId(String id) {
    final i = int.tryParse(id.replaceFirst('st_', ''));
    if (i == null || i < 0 || i >= total) return null;
    return all[i];
  }

  static List<StoreInfo> search({String query = '', String? category, int? maxDifficulty}) {
    final q = query.trim().toLowerCase();
    return all.where((s) {
      if (category != null && s.category.id != category) return false;
      if (maxDifficulty != null && s.difficulty > maxDifficulty) return false;
      if (q.isNotEmpty && !s.name.toLowerCase().contains(q) && !s.district.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }
}
