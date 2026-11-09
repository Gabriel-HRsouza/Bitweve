import 'package:flutter/material.dart';

class PostCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> colors;
  final List<String> captions;
  final List<IconData> photos; // motivos das 4 fotos disponíveis
  final double controversyRisk;
  final String? requirement; // descrição do requisito

  const PostCategory(this.id, this.name, this.icon, this.colors, this.captions, this.photos,
      {this.controversyRisk = 0.02, this.requirement});
}

class SocialCatalog {
  static const appName = 'Pulso';

  static const categories = <PostCategory>[
    PostCategory('photos', 'Fotos', Icons.photo_camera_rounded, [Color(0xFFF472B6), Color(0xFF7C3AED)],
        ['Só mais uma selfie 📸', 'Luz perfeita hoje ✨', 'Sem filtro (mentira)', 'Domingo de boa'],
        [Icons.face_retouching_natural_rounded, Icons.wb_sunny_rounded, Icons.local_florist_rounded, Icons.camera_rounded]),
    PostCategory('travel', 'Viagens', Icons.flight_takeoff_rounded, [Color(0xFF38BDF8), Color(0xFF0369A1)],
        ['Partiu! ✈️', 'Pé na areia 🏝️', 'Esse lugar é surreal', 'Coleciono carimbos no passaporte'],
        [Icons.beach_access_rounded, Icons.landscape_rounded, Icons.location_city_rounded, Icons.sailing_rounded],
        requirement: 'Ter viajado ao menos uma vez'),
    PostCategory('cars', 'Carros', Icons.directions_car_filled_rounded, [Color(0xFFF87171), Color(0xFF7F1D1D)],
        ['Minha nave 🚗', 'Lavado e brilhando', 'Pé na estrada', 'Garagem nova, quem curte?'],
        [Icons.directions_car_rounded, Icons.speed_rounded, Icons.two_wheeler_rounded, Icons.garage_rounded],
        controversyRisk: 0.03, requirement: 'Ter um veículo'),
    PostCategory('fashion', 'Roupas', Icons.checkroom_rounded, [Color(0xFFE879F9), Color(0xFF86198F)],
        ['Look do dia 👗', 'Comprinhas!', 'Estilo é atitude', 'Combinando tudo'],
        [Icons.checkroom_rounded, Icons.shopping_bag_rounded, Icons.watch_rounded, Icons.diamond_rounded]),
    PostCategory('party', 'Festas', Icons.celebration_rounded, [Color(0xFFFBBF24), Color(0xFFB45309)],
        ['Que noite! 🎉', 'Quem estava sabe 😂', 'Pista lotada', 'Melhores amigos, melhor rolê'],
        [Icons.nightlife_rounded, Icons.music_note_rounded, Icons.cake_rounded, Icons.local_bar_rounded],
        controversyRisk: 0.06),
    PostCategory('family', 'Família', Icons.family_restroom_rounded, [Color(0xFF86EFAC), Color(0xFF166534)],
        ['Minha base ❤️', 'Almoço de domingo', 'Família é tudo', 'Saudade dessa época'],
        [Icons.family_restroom_rounded, Icons.child_care_rounded, Icons.elderly_rounded, Icons.home_rounded]),
    PostCategory('love', 'Relacionamentos', Icons.favorite_rounded, [Color(0xFFFB7185), Color(0xFF9F1239)],
        ['Meu amor 💘', 'Aniversário de namoro!', 'Você e eu', 'Date perfeito'],
        [Icons.favorite_rounded, Icons.restaurant_rounded, Icons.local_florist_rounded, Icons.nights_stay_rounded],
        requirement: 'Estar em um relacionamento'),
    PostCategory('work', 'Trabalho', Icons.work_rounded, [Color(0xFF93C5FD), Color(0xFF1E3A8A)],
        ['Segunda-feira produtiva 💼', 'Nova conquista no trabalho', 'Equipe incrível', 'Do escritório com amor'],
        [Icons.laptop_mac_rounded, Icons.groups_rounded, Icons.trending_up_rounded, Icons.business_rounded],
        requirement: 'Ter um emprego'),
    PostCategory('college', 'Faculdade', Icons.school_rounded, [Color(0xFFA5B4FC), Color(0xFF3730A3)],
        ['Semana de provas 😵', 'Campus vibes', 'Rumo ao diploma 🎓', 'Biblioteca é minha casa'],
        [Icons.school_rounded, Icons.menu_book_rounded, Icons.science_rounded, Icons.emoji_events_rounded],
        requirement: 'Estar estudando'),
    PostCategory('humor', 'Humor', Icons.sentiment_very_satisfied_rounded, [Color(0xFFFDE047), Color(0xFFA16207)],
        ['Eu tentando ser adulto(a) 🤡', 'Ninguém: / Eu:', 'Pior que é verdade', 'Me marca que eu rio'],
        [Icons.mood_rounded, Icons.pets_rounded, Icons.emoji_emotions_rounded, Icons.theater_comedy_rounded],
        controversyRisk: 0.1),
    PostCategory('achievement', 'Conquistas', Icons.emoji_events_rounded, [Color(0xFFFCD34D), Color(0xFF92400E)],
        ['Consegui! 🏆', 'Meta batida', 'Trabalho duro compensa', 'Orgulho define'],
        [Icons.emoji_events_rounded, Icons.military_tech_rounded, Icons.workspace_premium_rounded, Icons.star_rounded]),
    PostCategory('luxury', 'Luxo', Icons.diamond_rounded, [Color(0xFFD8B4FE), Color(0xFF581C87)],
        ['Mimos 💎', 'Vida boa', 'Só o melhor', 'Champanhe e vista para o mar'],
        [Icons.diamond_rounded, Icons.villa_rounded, Icons.flight_class_rounded, Icons.watch_rounded],
        controversyRisk: 0.12, requirement: 'Patrimônio acima de R\$ 500 mil'),
    PostCategory('lifestyle', 'Lifestyle', Icons.spa_rounded, [Color(0xFF6EE7B7), Color(0xFF065F46)],
        ['Rotina matinal ☀️', 'Autocuidado', 'Treino pago 💪', 'Café e bons livros'],
        [Icons.spa_rounded, Icons.fitness_center_rounded, Icons.coffee_rounded, Icons.self_improvement_rounded]),
  ];

  static PostCategory category(String id) => categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  static const positiveComments = [
    'Que incrível! 😍', 'Arrasou demais!', 'Inspiração total', 'Muito bom!!', 'Que foto linda', 'Hahaha amei',
    'Orgulho de você!', 'Quero também 😭', 'Top demais', 'Isso aí! 👏', 'Melhor post do dia', 'Perfeição',
  ];
  static const negativeComments = [
    'Que exagero...', 'Ninguém perguntou 🙄', 'Ostentação pura', 'Forçado', 'Já foi melhor', 'Hmm, polêmico',
  ];
  static const fanHandles = [
    'fã_n1', 'luzinha.22', 'mari_vibes', 'joao.dev', 'bia.arte', 'rafa_fit', 'gamer.br', 'carol.viaja',
    'tetê_ofc', 'pedrinho.zz', 'nanda.foto', 'leo.music', 'ju.moda', 'gui.surf', 'camila.loves', 'theo.memes',
  ];

  static const brands = ['Nuvem Tênis', 'Café Aurora', 'Vibra Energia', 'Lume Cosméticos', 'Órbita Games', 'Prisma Moda'];
}
