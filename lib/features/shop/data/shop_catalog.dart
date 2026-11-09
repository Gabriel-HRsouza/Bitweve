import 'package:flutter/material.dart';
import 'package:bitweve/features/properties/models/vehicle_model.dart';

class ShopCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const ShopCategory(this.id, this.name, this.icon, this.color);
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final List<Color> colors; // gradiente da arte
  final int minAge;
  final Map<String, int> effects; // atributo -> ganho ao comprar
  final double annualCost;
  final double resale; // fração do preço na revenda
  final int tier; // 1 comum .. 4 lendário
  final int fame; // fama ganha ao comprar

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.colors,
    this.minAge = 12,
    this.effects = const {},
    this.annualCost = 0,
    this.resale = 0.4,
    this.tier = 1,
    this.fame = 0,
  });
}

class VehicleListing {
  final VehicleModel model;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final int tier;
  final bool needsLicense;
  final int happiness;
  final int fame;

  const VehicleListing({
    required this.model,
    required this.description,
    required this.icon,
    required this.colors,
    this.tier = 1,
    this.needsLicense = true,
    this.happiness = 10,
    this.fame = 0,
  });
}

class PropertyListing {
  final String id;
  final String type; // studio | apartment | house | beach_house | penthouse | mansion | farm | castle
  final String name;
  final String description;
  final double price;
  final double annualCost;
  final double rentIncome; // renda anual se alugado
  final IconData icon;
  final List<Color> colors;
  final int tier;
  final int happiness;
  final int bedrooms;

  const PropertyListing({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.annualCost,
    required this.rentIncome,
    required this.icon,
    required this.colors,
    this.tier = 1,
    this.happiness = 15,
    this.bedrooms = 2,
  });
}

class ShopCatalog {
  static const categories = <ShopCategory>[
    ShopCategory('clothes', 'Roupas', Icons.checkroom, Color(0xFFEC4899)),
    ShopCategory('phones', 'Celulares', Icons.smartphone, Color(0xFF3B82F6)),
    ShopCategory('computers', 'Computadores', Icons.laptop_mac, Color(0xFF6366F1)),
    ShopCategory('electronics', 'Eletrônicos', Icons.tv, Color(0xFF06B6D4)),
    ShopCategory('jewelry', 'Joias', Icons.diamond, Color(0xFFA855F7)),
    ShopCategory('watches', 'Relógios', Icons.watch, Color(0xFFF59E0B)),
    ShopCategory('accessories', 'Acessórios', Icons.shopping_bag, Color(0xFF14B8A6)),
    ShopCategory('luxury', 'Luxo', Icons.auto_awesome, Color(0xFFFFC53D)),
  ];

  static ShopCategory category(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  static ShopItem? item(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  static const items = <ShopItem>[
    // Roupas
    ShopItem(id: 'cl_basic', name: 'Kit Básico', description: 'Camisetas e jeans confortáveis para o dia a dia.', price: 250, category: 'clothes', icon: Icons.checkroom, colors: [Color(0xFF60A5FA), Color(0xFF2563EB)], minAge: 8, effects: {'looks': 2, 'happiness': 3}, resale: 0.1),
    ShopItem(id: 'cl_sneakers', name: 'Tênis de Corrida', description: 'Amortecimento de ponta para treinos.', price: 650, category: 'clothes', icon: Icons.directions_run, colors: [Color(0xFF34D399), Color(0xFF059669)], minAge: 8, effects: {'fitness': 3, 'happiness': 3}, resale: 0.2),
    ShopItem(id: 'cl_streetwear', name: 'Coleção Streetwear', description: 'Moletons e peças exclusivas de marcas urbanas.', price: 1800, category: 'clothes', icon: Icons.dry_cleaning, colors: [Color(0xFFF472B6), Color(0xFF7C3AED)], minAge: 12, effects: {'looks': 5, 'happiness': 6}, resale: 0.25, tier: 2),
    ShopItem(id: 'cl_suit', name: 'Terno Sob Medida', description: 'Alfaiataria impecável para reuniões e eventos.', price: 4500, category: 'clothes', icon: Icons.business_center, colors: [Color(0xFF475569), Color(0xFF0F172A)], minAge: 16, effects: {'looks': 7, 'charisma': 4}, resale: 0.2, tier: 2),
    ShopItem(id: 'cl_gown', name: 'Traje de Gala', description: 'Para tapetes vermelhos e festas de gala.', price: 12000, category: 'clothes', icon: Icons.nightlife, colors: [Color(0xFFE11D48), Color(0xFF7F1D1D)], minAge: 16, effects: {'looks': 10, 'happiness': 8}, resale: 0.25, tier: 3, fame: 2),
    ShopItem(id: 'cl_designer', name: 'Guarda-roupa de Grife', description: 'Peças das maiores casas de moda de Paris e Milão.', price: 65000, category: 'clothes', icon: Icons.local_mall, colors: [Color(0xFFFDE68A), Color(0xFFB45309)], minAge: 18, effects: {'looks': 15, 'happiness': 12}, resale: 0.3, tier: 4, fame: 4),
    // Celulares
    ShopItem(id: 'ph_basic', name: 'Celular Básico', description: 'Liga, manda mensagem e tira fotos razoáveis.', price: 900, category: 'phones', icon: Icons.phone_android, colors: [Color(0xFF94A3B8), Color(0xFF475569)], minAge: 10, effects: {'happiness': 5}, resale: 0.3),
    ShopItem(id: 'ph_mid', name: 'Smartphone Intermediário', description: 'Ótima câmera e bateria que dura o dia todo.', price: 2400, category: 'phones', icon: Icons.smartphone, colors: [Color(0xFF38BDF8), Color(0xFF1D4ED8)], minAge: 10, effects: {'happiness': 8}, resale: 0.35, tier: 2),
    ShopItem(id: 'ph_pro', name: 'Smartphone Pro Max', description: 'Câmera tripla, tela 120 Hz e acabamento em titânio.', price: 9500, category: 'phones', icon: Icons.phone_iphone, colors: [Color(0xFFA78BFA), Color(0xFF4C1D95)], minAge: 12, effects: {'happiness': 12, 'looks': 1}, resale: 0.45, tier: 3),
    ShopItem(id: 'ph_fold', name: 'Celular Dobrável', description: 'Tela que vira tablet. Tecnologia de ponta.', price: 14000, category: 'phones', icon: Icons.tablet_android, colors: [Color(0xFF2DD4BF), Color(0xFF0F766E)], minAge: 14, effects: {'happiness': 14}, resale: 0.4, tier: 3),
    // Computadores
    ShopItem(id: 'pc_notebook', name: 'Notebook de Estudos', description: 'Perfeito para trabalhos da escola e faculdade.', price: 3200, category: 'computers', icon: Icons.laptop_chromebook, colors: [Color(0xFF818CF8), Color(0xFF3730A3)], minAge: 10, effects: {'smarts': 4, 'happiness': 5}, resale: 0.3),
    ShopItem(id: 'pc_gamer', name: 'PC Gamer RGB', description: 'Placa de vídeo topo de linha e luzes por todo lado.', price: 12000, category: 'computers', icon: Icons.desktop_windows, colors: [Color(0xFFF472B6), Color(0xFF22D3EE)], minAge: 10, effects: {'happiness': 15, 'stress': -6}, resale: 0.4, tier: 3),
    ShopItem(id: 'pc_ultrabook', name: 'Ultrabook Profissional', description: 'Leve, potente e com bateria de 20 horas.', price: 15000, category: 'computers', icon: Icons.laptop_mac, colors: [Color(0xFFE2E8F0), Color(0xFF64748B)], minAge: 14, effects: {'smarts': 6, 'happiness': 8}, resale: 0.45, tier: 3),
    ShopItem(id: 'pc_tablet', name: 'Tablet com Caneta', description: 'Desenhe, leia e anote em qualquer lugar.', price: 5500, category: 'computers', icon: Icons.tablet_mac, colors: [Color(0xFFFCD34D), Color(0xFFD97706)], minAge: 8, effects: {'smarts': 3, 'happiness': 7}, resale: 0.35, tier: 2),
    // Eletrônicos
    ShopItem(id: 'el_console', name: 'Videogame de Nova Geração', description: 'Gráficos realistas e jogos online com amigos.', price: 4500, category: 'electronics', icon: Icons.sports_esports, colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)], minAge: 6, effects: {'happiness': 14, 'stress': -5}, resale: 0.4, tier: 2),
    ShopItem(id: 'el_headphones', name: 'Fone com Cancelamento de Ruído', description: 'Silêncio absoluto e som cristalino.', price: 2200, category: 'electronics', icon: Icons.headphones, colors: [Color(0xFF334155), Color(0xFF020617)], minAge: 10, effects: {'happiness': 7, 'stress': -4}, resale: 0.35),
    ShopItem(id: 'el_tv', name: 'Smart TV 75" OLED', description: 'Cinema em casa com cores perfeitas.', price: 11000, category: 'electronics', icon: Icons.tv, colors: [Color(0xFF22D3EE), Color(0xFF0E7490)], minAge: 16, effects: {'happiness': 12}, resale: 0.35, tier: 3),
    ShopItem(id: 'el_camera', name: 'Câmera Mirrorless', description: 'Fotos profissionais e vídeos em 4K.', price: 8500, category: 'electronics', icon: Icons.photo_camera, colors: [Color(0xFF52525B), Color(0xFF18181B)], minAge: 12, effects: {'happiness': 8, 'smarts': 2}, resale: 0.45, tier: 2),
    ShopItem(id: 'el_vr', name: 'Óculos de Realidade Virtual', description: 'Mergulhe em mundos virtuais.', price: 4200, category: 'electronics', icon: Icons.view_in_ar, colors: [Color(0xFFC084FC), Color(0xFF6D28D9)], minAge: 12, effects: {'happiness': 10}, resale: 0.35, tier: 2),
    ShopItem(id: 'el_drone', name: 'Drone 4K', description: 'Imagens aéreas de tirar o fôlego.', price: 6800, category: 'electronics', icon: Icons.flight, colors: [Color(0xFF94A3B8), Color(0xFF334155)], minAge: 14, effects: {'happiness': 9}, resale: 0.4, tier: 2),
    // Joias
    ShopItem(id: 'jw_silver', name: 'Corrente de Prata', description: 'Prata 925 com acabamento polido.', price: 900, category: 'jewelry', icon: Icons.link, colors: [Color(0xFFE5E7EB), Color(0xFF9CA3AF)], minAge: 14, effects: {'looks': 3, 'happiness': 4}, resale: 0.5),
    ShopItem(id: 'jw_gold', name: 'Cordão de Ouro 18k', description: 'Brilho que não passa despercebido.', price: 8500, category: 'jewelry', icon: Icons.all_inclusive, colors: [Color(0xFFFDE047), Color(0xFFCA8A04)], minAge: 16, effects: {'looks': 6, 'happiness': 7}, resale: 0.7, tier: 2, fame: 1),
    ShopItem(id: 'jw_ring', name: 'Anel de Diamante', description: 'Um quilate de puro brilho. Ideal para pedidos.', price: 28000, category: 'jewelry', icon: Icons.diamond, colors: [Color(0xFFBAE6FD), Color(0xFF6366F1)], minAge: 18, effects: {'looks': 4, 'happiness': 10}, resale: 0.6, tier: 3),
    ShopItem(id: 'jw_tiara', name: 'Conjunto de Esmeraldas', description: 'Colar e brincos de esmeraldas colombianas.', price: 180000, category: 'jewelry', icon: Icons.workspace_premium, colors: [Color(0xFF6EE7B7), Color(0xFF047857)], minAge: 18, effects: {'looks': 10, 'happiness': 15}, resale: 0.7, tier: 4, fame: 5),
    // Relógios
    ShopItem(id: 'wt_sport', name: 'Smartwatch Esportivo', description: 'Monitora batimentos, sono e treinos.', price: 1900, category: 'watches', icon: Icons.watch, colors: [Color(0xFF4ADE80), Color(0xFF15803D)], minAge: 12, effects: {'health': 3, 'fitness': 3, 'happiness': 4}, resale: 0.3),
    ShopItem(id: 'wt_classic', name: 'Relógio Clássico Suíço', description: 'Mecanismo automático e pulseira de couro.', price: 22000, category: 'watches', icon: Icons.schedule, colors: [Color(0xFFD6D3D1), Color(0xFF57534E)], minAge: 18, effects: {'looks': 5, 'charisma': 3, 'happiness': 8}, resale: 0.65, tier: 3),
    ShopItem(id: 'wt_diver', name: 'Relógio de Mergulho em Ouro', description: 'Ícone da relojoaria de luxo, à prova d\'água.', price: 95000, category: 'watches', icon: Icons.av_timer, colors: [Color(0xFFFACC15), Color(0xFF166534)], minAge: 18, effects: {'looks': 7, 'happiness': 12}, resale: 0.85, tier: 4, fame: 3),
    // Acessórios
    ShopItem(id: 'ac_backpack', name: 'Mochila Tech', description: 'Antifurto, USB e espaço para notebook.', price: 450, category: 'accessories', icon: Icons.backpack, colors: [Color(0xFF64748B), Color(0xFF1E293B)], minAge: 6, effects: {'happiness': 3}, resale: 0.2),
    ShopItem(id: 'ac_sunglasses', name: 'Óculos de Sol de Grife', description: 'Proteção UV e muito estilo.', price: 1600, category: 'accessories', icon: Icons.wb_sunny, colors: [Color(0xFFFB923C), Color(0xFFB91C1C)], minAge: 12, effects: {'looks': 4, 'happiness': 4}, resale: 0.3),
    ShopItem(id: 'ac_bag', name: 'Bolsa de Couro Italiano', description: 'Costura artesanal e couro legítimo.', price: 14000, category: 'accessories', icon: Icons.shopping_bag, colors: [Color(0xFFA16207), Color(0xFF422006)], minAge: 16, effects: {'looks': 6, 'happiness': 8}, resale: 0.5, tier: 3, fame: 1),
    ShopItem(id: 'ac_perfume', name: 'Perfume Importado', description: 'Fragrância marcante e duradoura.', price: 850, category: 'accessories', icon: Icons.spa, colors: [Color(0xFFF9A8D4), Color(0xFFBE185D)], minAge: 14, effects: {'looks': 3, 'charisma': 2}, resale: 0.0),
    ShopItem(id: 'ac_bike', name: 'Bicicleta Urbana', description: 'Pedale pela cidade e mantenha a forma.', price: 2800, category: 'accessories', icon: Icons.pedal_bike, colors: [Color(0xFF22D3EE), Color(0xFF0369A1)], minAge: 6, effects: {'fitness': 5, 'health': 3, 'happiness': 6}, resale: 0.4),
    // Luxo
    ShopItem(id: 'lx_art', name: 'Obra de Arte Moderna', description: 'Tela original de artista consagrado. Pode valorizar.', price: 350000, category: 'luxury', icon: Icons.image, colors: [Color(0xFFF472B6), Color(0xFF4338CA)], minAge: 18, effects: {'happiness': 12, 'smarts': 2}, resale: 1.1, tier: 4, fame: 4),
    ShopItem(id: 'lx_piano', name: 'Piano de Cauda', description: 'Som majestoso para a sala de estar.', price: 180000, category: 'luxury', icon: Icons.piano, colors: [Color(0xFF27272A), Color(0xFF09090B)], minAge: 12, effects: {'happiness': 10, 'smarts': 4}, resale: 0.6, tier: 4),
    ShopItem(id: 'lx_horse', name: 'Cavalo Puro-Sangue', description: 'Campeão de hipismo com pedigree.', price: 420000, category: 'luxury', icon: Icons.bedroom_baby, colors: [Color(0xFF92400E), Color(0xFF451A03)], minAge: 16, effects: {'happiness': 15, 'fitness': 4}, annualCost: 36000, resale: 0.5, tier: 4, fame: 3),
    ShopItem(id: 'lx_island_trip', name: 'Férias numa Ilha Particular', description: 'Uma semana exclusiva num paraíso tropical.', price: 250000, category: 'luxury', icon: Icons.beach_access, colors: [Color(0xFF2DD4BF), Color(0xFF0284C7)], minAge: 18, effects: {'happiness': 30, 'stress': -40, 'health': 5}, resale: 0, tier: 4, fame: 3),
    ShopItem(id: 'lx_space', name: 'Viagem Espacial Turística', description: 'Veja a curvatura da Terra numa nave suborbital.', price: 3500000, category: 'luxury', icon: Icons.rocket_launch, colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)], minAge: 18, effects: {'happiness': 40, 'smarts': 5}, resale: 0, tier: 4, fame: 15),
  ];

  static const vehicles = <VehicleListing>[
    VehicleListing(model: VehicleModel(id: 'v_scooter', name: 'Scooter Elétrica', category: VehicleCategory.motorcycle, year: 2026, purchasePrice: 9800, currentValue: 9800, annualMaintenance: 300, annualInsurance: 400), description: 'Silenciosa e econômica para a cidade.', icon: Icons.electric_scooter, colors: [Color(0xFF22D3EE), Color(0xFF0891B2)], needsLicense: false, happiness: 6),
    VehicleListing(model: VehicleModel(id: 'v_moto', name: 'Moto Street 160cc', category: VehicleCategory.motorcycle, year: 2026, purchasePrice: 16500, currentValue: 16500, annualMaintenance: 800, annualInsurance: 600), description: 'Ágil no trânsito e econômica.', icon: Icons.two_wheeler, colors: [Color(0xFFF87171), Color(0xFFB91C1C)], happiness: 8),
    VehicleListing(model: VehicleModel(id: 'v_hatch', name: 'Hatch Compacto 1.0', category: VehicleCategory.popular, year: 2026, purchasePrice: 62000, currentValue: 62000, annualMaintenance: 2200, annualInsurance: 1800), description: 'O primeiro carro perfeito.', icon: Icons.directions_car, colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)], happiness: 10),
    VehicleListing(model: VehicleModel(id: 'v_sedan', name: 'Sedã Executivo Turbo', category: VehicleCategory.sedan, year: 2026, purchasePrice: 135000, currentValue: 135000, annualMaintenance: 4500, annualInsurance: 3400), description: 'Conforto e tecnologia para a família.', icon: Icons.directions_car_filled, colors: [Color(0xFF94A3B8), Color(0xFF334155)], tier: 2, happiness: 12),
    VehicleListing(model: VehicleModel(id: 'v_pickup', name: 'Picape 4x4 Diesel', category: VehicleCategory.suv, year: 2026, purchasePrice: 240000, currentValue: 240000, annualMaintenance: 7000, annualInsurance: 5200), description: 'Força para qualquer terreno.', icon: Icons.local_shipping, colors: [Color(0xFFFBBF24), Color(0xFFB45309)], tier: 2, happiness: 13),
    VehicleListing(model: VehicleModel(id: 'v_ev', name: 'Elétrico Autônomo', category: VehicleCategory.sedan, year: 2026, purchasePrice: 310000, currentValue: 310000, annualMaintenance: 2500, annualInsurance: 7000), description: 'Piloto automático e zero emissões.', icon: Icons.electric_car, colors: [Color(0xFF4ADE80), Color(0xFF15803D)], tier: 3, happiness: 15, fame: 1),
    VehicleListing(model: VehicleModel(id: 'v_suv', name: 'SUV Premium Híbrido', category: VehicleCategory.suv, year: 2026, purchasePrice: 420000, currentValue: 420000, annualMaintenance: 8500, annualInsurance: 9200), description: 'Luxo, espaço e presença.', icon: Icons.airport_shuttle, colors: [Color(0xFF1F2937), Color(0xFF030712)], tier: 3, happiness: 16, fame: 1),
    VehicleListing(model: VehicleModel(id: 'v_superbike', name: 'Superbike 1000cc', category: VehicleCategory.motorcycle, year: 2026, purchasePrice: 140000, currentValue: 140000, annualMaintenance: 5000, annualInsurance: 6000), description: '0 a 100 km/h em menos de 3 segundos.', icon: Icons.sports_motorsports, colors: [Color(0xFFFB923C), Color(0xFF9A3412)], tier: 3, happiness: 16, fame: 1),
    VehicleListing(model: VehicleModel(id: 'v_sports', name: 'Superesportivo V8', category: VehicleCategory.sports, year: 2026, purchasePrice: 1900000, currentValue: 1900000, annualMaintenance: 34000, annualInsurance: 48000), description: 'Motor central, 720 cavalos de pura emoção.', icon: Icons.sports_score, colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)], tier: 4, happiness: 25, fame: 4),
    VehicleListing(model: VehicleModel(id: 'v_limo', name: 'Limusine Blindada', category: VehicleCategory.luxury, year: 2026, purchasePrice: 2600000, currentValue: 2600000, annualMaintenance: 60000, annualInsurance: 70000), description: 'Segurança máxima com bar e motorista.', icon: Icons.local_taxi, colors: [Color(0xFF111827), Color(0xFF6B7280)], tier: 4, happiness: 22, fame: 5),
    VehicleListing(model: VehicleModel(id: 'v_yacht', name: 'Iate de Luxo 42 Pés', category: VehicleCategory.boat, year: 2025, purchasePrice: 4800000, currentValue: 4800000, annualMaintenance: 120000, annualInsurance: 60000), description: 'Fins de semana em alto-mar.', icon: Icons.sailing, colors: [Color(0xFF38BDF8), Color(0xFF0C4A6E)], tier: 4, needsLicense: false, happiness: 28, fame: 6),
    VehicleListing(model: VehicleModel(id: 'v_heli', name: 'Helicóptero Executivo', category: VehicleCategory.aircraft, year: 2025, purchasePrice: 9500000, currentValue: 9500000, annualMaintenance: 280000, annualInsurance: 150000), description: 'Fuja do trânsito pelo céu.', icon: Icons.connecting_airports, colors: [Color(0xFF475569), Color(0xFF0F172A)], tier: 4, needsLicense: false, happiness: 28, fame: 7),
    VehicleListing(model: VehicleModel(id: 'v_jet', name: 'Jato Executivo Continental', category: VehicleCategory.aircraft, year: 2025, purchasePrice: 38000000, currentValue: 38000000, annualMaintenance: 900000, annualInsurance: 450000), description: 'Atravesse oceanos com conforto absoluto.', icon: Icons.flight_takeoff, colors: [Color(0xFFE0E7FF), Color(0xFF4338CA)], tier: 4, needsLicense: false, happiness: 35, fame: 10),
  ];

  static const properties = <PropertyListing>[
    PropertyListing(id: 'p_studio', type: 'studio', name: 'Kitnet no Centro', description: 'Compacta, perto do metrô e de tudo.', price: 160000, annualCost: 3600, rentIncome: 14000, icon: Icons.single_bed, colors: [Color(0xFF93C5FD), Color(0xFF1E40AF)], happiness: 10, bedrooms: 1),
    PropertyListing(id: 'p_apartment', type: 'apartment', name: 'Apartamento 2 Quartos', description: 'Varanda, piscina no condomínio e vaga de garagem.', price: 420000, annualCost: 9000, rentIncome: 28000, icon: Icons.apartment, colors: [Color(0xFF67E8F9), Color(0xFF0E7490)], happiness: 14, bedrooms: 2),
    PropertyListing(id: 'p_house', type: 'house', name: 'Casa com Quintal', description: 'Três quartos, churrasqueira e espaço para pets.', price: 680000, annualCost: 12000, rentIncome: 40000, icon: Icons.house, colors: [Color(0xFF86EFAC), Color(0xFF15803D)], tier: 2, happiness: 18, bedrooms: 3),
    PropertyListing(id: 'p_beach', type: 'beach_house', name: 'Casa de Praia', description: 'Pé na areia, rede na varanda e pôr do sol.', price: 1300000, annualCost: 22000, rentIncome: 85000, icon: Icons.beach_access, colors: [Color(0xFFFDE68A), Color(0xFF0EA5E9)], tier: 3, happiness: 22, bedrooms: 4),
    PropertyListing(id: 'p_penthouse', type: 'penthouse', name: 'Cobertura Duplex', description: 'Vista panorâmica, piscina privativa e automação total.', price: 3800000, annualCost: 60000, rentIncome: 210000, icon: Icons.location_city, colors: [Color(0xFFC4B5FD), Color(0xFF4C1D95)], tier: 3, happiness: 26, bedrooms: 4),
    PropertyListing(id: 'p_farm', type: 'farm', name: 'Fazenda Produtiva', description: '200 hectares, cavalos e produção de café.', price: 5200000, annualCost: 90000, rentIncome: 420000, icon: Icons.agriculture, colors: [Color(0xFFBEF264), Color(0xFF3F6212)], tier: 3, happiness: 20, bedrooms: 6),
    PropertyListing(id: 'p_mansion', type: 'mansion', name: 'Mansão com Heliponto', description: 'Oito suítes, cinema, adega e heliponto.', price: 14000000, annualCost: 260000, rentIncome: 700000, icon: Icons.villa, colors: [Color(0xFFFDE047), Color(0xFFA16207)], tier: 4, happiness: 35, bedrooms: 8),
    PropertyListing(id: 'p_loft', type: 'apartment', name: 'Loft Industrial', description: 'Pé-direito duplo, tijolinho aparente e muita luz.', price: 560000, annualCost: 10000, rentIncome: 34000, icon: Icons.chair_alt, colors: [Color(0xFFFDBA74), Color(0xFF9A3412)], tier: 2, happiness: 16, bedrooms: 1),
    PropertyListing(id: 'p_townhouse', type: 'house', name: 'Sobrado em Condomínio', description: 'Segurança 24h, área gourmet e quintal.', price: 950000, annualCost: 18000, rentIncome: 52000, icon: Icons.holiday_village, colors: [Color(0xFFA7F3D0), Color(0xFF047857)], tier: 2, happiness: 20, bedrooms: 4),
    PropertyListing(id: 'p_office', type: 'commercial', name: 'Sala Comercial', description: 'Conjunto de 45 m² em torre corporativa. Ótima para alugar.', price: 380000, annualCost: 9000, rentIncome: 36000, icon: Icons.business, colors: [Color(0xFFCBD5E1), Color(0xFF334155)], tier: 2, happiness: 4, bedrooms: 0),
    PropertyListing(id: 'p_store', type: 'store', name: 'Loja de Rua', description: 'Ponto comercial movimentado com vitrine ampla.', price: 820000, annualCost: 15000, rentIncome: 78000, icon: Icons.storefront, colors: [Color(0xFFFCA5A5), Color(0xFF991B1B)], tier: 2, happiness: 5, bedrooms: 0),
    PropertyListing(id: 'p_warehouse', type: 'warehouse', name: 'Galpão Logístico', description: '2.000 m² perto da rodovia. Renda de aluguel estável.', price: 2600000, annualCost: 40000, rentIncome: 260000, icon: Icons.warehouse, colors: [Color(0xFFD6D3D1), Color(0xFF57534E)], tier: 3, happiness: 6, bedrooms: 0),
    PropertyListing(id: 'p_castle', type: 'castle', name: 'Castelo Histórico Europeu', description: 'Séculos de história, torres e jardins reais.', price: 48000000, annualCost: 900000, rentIncome: 2200000, icon: Icons.castle, colors: [Color(0xFFCBD5E1), Color(0xFF334155)], tier: 4, happiness: 40, bedrooms: 20),
  ];

  static PropertyListing? propertyListing(String id) {
    for (final p in properties) {
      if (p.id == id) return p;
    }
    return null;
  }

  static VehicleListing? vehicleListing(String id) {
    for (final v in vehicles) {
      if (v.model.id == id) return v;
    }
    return null;
  }

  /// Arte de um veículo já comprado (o id da instância é novo; o nome identifica).
  static VehicleListing? vehicleListingByName(String name) {
    for (final v in vehicles) {
      if (v.model.name == name) return v;
    }
    return null;
  }

  static PropertyListing? propertyListingByName(String name) {
    for (final p in properties) {
      if (p.name == name) return p;
    }
    return null;
  }
}
