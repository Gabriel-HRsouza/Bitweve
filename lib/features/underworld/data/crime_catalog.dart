import 'package:flutter/material.dart';

/// Tipos de minigame (todos abstratos e fictícios — não ensinam técnicas reais).
enum MinigameKind {
  maze, // labirinto de coleta com perseguidores (furto em loja)
  bluff, // ponteiro de lábia (golpes fictícios / negociação)
  safe, // cofre de disco giratório (roubo fictício)
  sequence, // memória de sequência (crimes financeiros simulados)
  runner, // corrida de pistas (contrabando / fuga em missões)
}

extension MinigameKindX on MinigameKind {
  String get label => switch (this) {
        MinigameKind.maze => 'Labirinto',
        MinigameKind.bluff => 'Lábia',
        MinigameKind.safe => 'Cofre',
        MinigameKind.sequence => 'Memória',
        MinigameKind.runner => 'Fuga',
      };

  IconData get icon => switch (this) {
        MinigameKind.maze => Icons.grid_4x4_rounded,
        MinigameKind.bluff => Icons.speed_rounded,
        MinigameKind.safe => Icons.lock_rounded,
        MinigameKind.sequence => Icons.memory_rounded,
        MinigameKind.runner => Icons.directions_car_filled_rounded,
      };

  String get howTo => switch (this) {
        MinigameKind.maze => 'Mova-se pelo labirinto, colete os itens marcados e chegue à saída antes do tempo acabar. Evite os seguranças!',
        MinigameKind.bluff => 'Toque PARAR quando o ponteiro estiver na faixa verde. Acerte as rodadas para convencer o alvo.',
        MinigameKind.safe => 'Gire o disco e toque TRAVAR quando a marca alinhar com o pino brilhante. Abra todas as travas.',
        MinigameKind.sequence => 'Memorize a sequência de células que acendem e repita na mesma ordem.',
        MinigameKind.runner => 'Troque de pista para desviar dos bloqueios e pegue as maletas até a linha de chegada.',
      };
}

class CrimeDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final MinigameKind minigame;
  final int minAge;
  final int difficulty; // 1..5
  final double baseLoot;
  final double risk; // chance-base de ser pego ao falhar
  final int severity; // 1..5 (pena)
  final int minNotoriety;
  final String category; // theft | robbery | scam | smuggling | financial

  const CrimeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.minigame,
    required this.minAge,
    required this.difficulty,
    required this.baseLoot,
    required this.risk,
    required this.severity,
    this.minNotoriety = 0,
    required this.category,
  });
}

class Gang {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int minNotoriety;
  final List<String> ranks;
  const Gang(this.id, this.name, this.description, this.icon, this.color, this.minNotoriety, this.ranks);
}

class GangMission {
  final String id;
  final String gangId;
  final String name;
  final String description;
  final MinigameKind minigame;
  final int difficulty;
  final double reward;
  final int minRank;
  const GangMission(this.id, this.gangId, this.name, this.description, this.minigame, this.difficulty, this.reward, this.minRank);
}

class CrimeCatalog {
  static const crimes = <CrimeDef>[
    CrimeDef(
      id: 'shoplift',
      name: 'Furtar loja',
      description: 'Escolha um dos 1.000 estabelecimentos fictícios e tente sair com mercadorias.',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFF59E0B),
      minigame: MinigameKind.maze,
      minAge: 12,
      difficulty: 1,
      baseLoot: 0,
      risk: 0.45,
      severity: 1,
      category: 'theft',
    ),
    CrimeDef(
      id: 'pickpocket',
      name: 'Bater carteira',
      description: 'Num evento lotado, distraia e furte um turista fictício.',
      icon: Icons.back_hand_rounded,
      color: Color(0xFFFB923C),
      minigame: MinigameKind.bluff,
      minAge: 12,
      difficulty: 2,
      baseLoot: 320,
      risk: 0.4,
      severity: 1,
      category: 'theft',
    ),
    CrimeDef(
      id: 'scam',
      name: 'Golpe do prêmio falso',
      description: 'Convença um alvo fictício de que ele ganhou um prêmio inexistente.',
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFA855F7),
      minigame: MinigameKind.bluff,
      minAge: 16,
      difficulty: 3,
      baseLoot: 2800,
      risk: 0.5,
      severity: 2,
      minNotoriety: 5,
      category: 'scam',
    ),
    CrimeDef(
      id: 'safe_heist',
      name: 'Roubo ao cofre',
      description: 'Invada o escritório fictício de um agiota e abra o cofre.',
      icon: Icons.lock_open_rounded,
      color: Color(0xFFEF4444),
      minigame: MinigameKind.safe,
      minAge: 18,
      difficulty: 4,
      baseLoot: 18000,
      risk: 0.6,
      severity: 4,
      minNotoriety: 20,
      category: 'robbery',
    ),
    CrimeDef(
      id: 'smuggling',
      name: 'Contrabando',
      description: 'Leve uma carga fictícia de eletrônicos sem nota pela fronteira.',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF0EA5E9),
      minigame: MinigameKind.runner,
      minAge: 18,
      difficulty: 3,
      baseLoot: 9000,
      risk: 0.55,
      severity: 3,
      minNotoriety: 12,
      category: 'smuggling',
    ),
    CrimeDef(
      id: 'cooked_books',
      name: 'Maquiagem contábil',
      description: 'Desvie verbas de uma empresa fictícia mexendo nos balanços.',
      icon: Icons.request_quote_rounded,
      color: Color(0xFF10B981),
      minigame: MinigameKind.sequence,
      minAge: 21,
      difficulty: 4,
      baseLoot: 45000,
      risk: 0.55,
      severity: 4,
      minNotoriety: 15,
      category: 'financial',
    ),
    CrimeDef(
      id: 'insider',
      name: 'Esquema na bolsa',
      description: 'Use informação privilegiada fictícia para lucrar com ações.',
      icon: Icons.candlestick_chart_rounded,
      color: Color(0xFF22C55E),
      minigame: MinigameKind.sequence,
      minAge: 21,
      difficulty: 5,
      baseLoot: 120000,
      risk: 0.6,
      severity: 5,
      minNotoriety: 30,
      category: 'financial',
    ),
  ];

  static CrimeDef crime(String id) => crimes.firstWhere((c) => c.id == id, orElse: () => crimes.first);

  static const gangs = <Gang>[
    Gang('serpentes', 'Serpentes do Asfalto', 'Gangue de rua fictícia que domina rachas e furtos.', Icons.two_wheeler_rounded, Color(0xFF22C55E), 10,
        ['Olheiro(a)', 'Soldado', 'Tenente', 'Braço-direito', 'Chefe']),
    Gang('neblina', 'Cartel Neblina', 'Organização fictícia de contrabando no porto.', Icons.directions_boat_rounded, Color(0xFF64748B), 25,
        ['Carregador(a)', 'Motorista', 'Negociador(a)', 'Capitão(ã)', 'Barão/Baronesa']),
    Gang('colarinho', 'Clube do Colarinho', 'Rede fictícia de crimes financeiros de alto padrão.', Icons.business_center_rounded, Color(0xFFFFC53D), 35,
        ['Estagiário(a)', 'Analista', 'Sócio(a)', 'Diretor(a)', 'Mentor(a)']),
  ];

  static Gang? gang(String? id) {
    for (final g in gangs) {
      if (g.id == id) return g;
    }
    return null;
  }

  static const missions = <GangMission>[
    GangMission('s1', 'serpentes', 'Vigiar a esquina', 'Fique de olho na movimentação e avise a gangue.', MinigameKind.sequence, 1, 600, 0),
    GangMission('s2', 'serpentes', 'Entrega rápida', 'Leve um pacote fictício pela cidade sem ser parado.', MinigameKind.runner, 2, 2500, 1),
    GangMission('s3', 'serpentes', 'Limpa no depósito', 'Esvazie um depósito rival (fictício) antes do alarme.', MinigameKind.maze, 3, 9000, 2),
    GangMission('s4', 'serpentes', 'Território', 'Negocie a trégua com a gangue rival.', MinigameKind.bluff, 4, 20000, 3),
    GangMission('n1', 'neblina', 'Carga noturna', 'Descarregue caixas fictícias no porto sem chamar atenção.', MinigameKind.maze, 2, 3500, 0),
    GangMission('n2', 'neblina', 'Rota da serra', 'Dirija o caminhão pela serra desviando das blitzes.', MinigameKind.runner, 3, 12000, 1),
    GangMission('n3', 'neblina', 'Cofre do navio', 'Abra o cofre de um navio fictício atracado.', MinigameKind.safe, 4, 40000, 2),
    GangMission('n4', 'neblina', 'Acordo internacional', 'Feche um acordo com compradores estrangeiros fictícios.', MinigameKind.bluff, 5, 110000, 3),
    GangMission('c1', 'colarinho', 'Planilha paralela', 'Monte uma contabilidade paralela fictícia.', MinigameKind.sequence, 3, 25000, 0),
    GangMission('c2', 'colarinho', 'Reunião de diretoria', 'Convença o conselho fictício a aprovar o contrato.', MinigameKind.bluff, 3, 45000, 1),
    GangMission('c3', 'colarinho', 'Offshore', 'Movimente fundos fictícios por empresas de fachada.', MinigameKind.sequence, 5, 150000, 2),
    GangMission('c4', 'colarinho', 'Cofre do banqueiro', 'Recupere documentos no cofre de um banqueiro fictício.', MinigameKind.safe, 5, 300000, 3),
  ];

  static GangMission? mission(String id) {
    for (final m in missions) {
      if (m.id == id) return m;
    }
    return null;
  }
}
