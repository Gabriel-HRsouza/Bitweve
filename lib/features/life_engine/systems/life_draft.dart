import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/models/character_model.dart';
import 'package:bitweve/features/events/models/life_event.dart';
import 'package:bitweve/features/finances/models/investment_model.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/life_engine/models/life_state.dart';
import 'package:bitweve/features/properties/models/property_model.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';

/// Contexto compartilhado pelos sistemas: aleatoriedade, ids, áudio e dados.
class EngineContext {
  final Random rng;
  final Uuid uuid = const Uuid();
  final AudioService audio;
  List<Map<String, dynamic>> countries = [];
  List<LifeEvent> jsonEvents = [];

  EngineContext({Random? rng, AudioService? audio})
      : rng = rng ?? Random(),
        audio = audio ?? AudioService();

  String id() => uuid.v4();
  double roll() => rng.nextDouble();
  bool chance(double p) => rng.nextDouble() < p;
  int range(int min, int max) => min + rng.nextInt(max - min + 1);
  T pick<T>(List<T> list) => list[rng.nextInt(list.length)];

  Map<String, dynamic> countryByName(String name) {
    for (final c in countries) {
      if (c['name'] == name) return c;
    }
    return const {
      'id': 'br', 'name': 'Brasil', 'taxRate': 0.18, 'costOfLivingMultiplier': 1.0,
      'avgSalaryMultiplier': 1.0, 'lifeExpectancy': 80,
      'cities': ['São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Salvador'],
    };
  }

  double taxRate(String country) => ((countryByName(country)['taxRate'] as num?) ?? 0.18).toDouble();
  double costMult(String country) => ((countryByName(country)['costOfLivingMultiplier'] as num?) ?? 1.0).toDouble();
  double salaryMult(String country) => ((countryByName(country)['avgSalaryMultiplier'] as num?) ?? 1.0).toDouble();
  int lifeExpectancy(String country) => ((countryByName(country)['lifeExpectancy'] as num?) ?? 78).toInt();

  // ------------------------------------------------------------------ nomes
  static const _male = [
    'Lucas', 'Gabriel', 'Mateus', 'Felipe', 'Enzo', 'Leonardo', 'Thiago', 'Rafael', 'Bruno', 'Arthur',
    'Rodrigo', 'Gustavo', 'Davi', 'Heitor', 'Miguel', 'Samuel', 'Bernardo', 'Pedro', 'Caio', 'Vinícius',
    'Otávio', 'Ícaro', 'Renan', 'Diego', 'Henrique', 'Joaquim', 'Murilo', 'Benício', 'Théo', 'Nicolas',
    'André', 'Augusto', 'Breno', 'Cauã', 'Daniel', 'Eduardo', 'Fábio', 'Fernando', 'Guilherme', 'Hugo',
    'Igor', 'João', 'Kaique', 'Leandro', 'Marcelo', 'Matheus', 'Nathan', 'Paulo', 'Raul', 'Ricardo',
    'Rogério', 'Sérgio', 'Tiago', 'Vítor', 'Wesley', 'Yuri', 'Anderson', 'Alexandre', 'Emanuel', 'Lorenzo',
    'Antônio', 'Benjamin', 'Caetano', 'Danilo', 'Elias', 'Francisco', 'Gael', 'Ian', 'Jonas', 'Luan',
  ];
  static const _female = [
    'Sophia', 'Isabella', 'Júlia', 'Mariana', 'Beatriz', 'Camila', 'Larissa', 'Helena', 'Alice', 'Manuela',
    'Carolina', 'Amanda', 'Valentina', 'Laura', 'Luiza', 'Cecília', 'Lorena', 'Lívia', 'Giovanna', 'Yasmin',
    'Clara', 'Bianca', 'Rafaela', 'Elisa', 'Aurora', 'Maitê', 'Heloísa', 'Antonella', 'Vitória', 'Nina',
    'Ana', 'Bruna', 'Carla', 'Débora', 'Eduarda', 'Fernanda', 'Gabriela', 'Isadora', 'Jéssica', 'Kamila',
    'Letícia', 'Melissa', 'Natália', 'Olívia', 'Paula', 'Raquel', 'Sara', 'Tainá', 'Vanessa', 'Yara',
    'Agatha', 'Brenda', 'Catarina', 'Daniela', 'Emanuelly', 'Flávia', 'Gisele', 'Ingrid', 'Joana', 'Lara',
    'Marina', 'Nicole', 'Pietra', 'Renata', 'Stella', 'Tatiana', 'Thaís', 'Ester', 'Lavínia', 'Mirela',
  ];
  static const _last = [
    'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes',
    'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Almeida', 'Lopes', 'Barbosa', 'Rocha', 'Moreira', 'Nunes',
    'Mendes', 'Cardoso', 'Teixeira', 'Freitas', 'Moura', 'Castro', 'Vieira', 'Azevedo', 'Duarte', 'Pinheiro',
    'Araújo', 'Batista', 'Campos', 'Correia', 'Dias', 'Fernandes', 'Garcia', 'Guimarães', 'Jesus', 'Leite',
    'Macedo', 'Machado', 'Marques', 'Medeiros', 'Monteiro', 'Nascimento', 'Neves', 'Pacheco', 'Paiva', 'Queiroz',
    'Ramos', 'Reis', 'Sales', 'Siqueira', 'Tavares', 'Valente', 'Xavier', 'Bezerra', 'Cavalcanti', 'Fonseca',
  ];
  static const _jobs = [
    'Contador(a)', 'Professor(a)', 'Comerciante', 'Enfermeiro(a)', 'Vendedor(a)', 'Engenheiro(a)',
    'Administrador(a)', 'Advogado(a)', 'Eletricista', 'Gerente', 'Motorista', 'Cozinheiro(a)', 'Designer',
    'Programador(a)', 'Médico(a)', 'Policial', 'Arquiteto(a)', 'Dentista', 'Jornalista', 'Autônomo(a)',
  ];

  String firstName(String gender) => pick(gender == 'female' ? _female : _male);
  String lastName() => pick(_last);
  String commonJob() => pick(_jobs);
  String gender() => rng.nextBool() ? 'male' : 'female';
}

/// Rascunho mutável de uma vida durante uma ação. Os sistemas alteram o
/// rascunho; no fim, [build] produz o novo [LifeEngineState] imutável.
class LifeDraft {
  final LifeEngineState base;
  final EngineContext ctx;
  CharacterModel c;
  List<NpcModel> npcs;
  List<PropertyModel> props;
  List<InvestmentModel> invs;
  final LifeExtras x;
  final List<LifeLog> newLogs = [];
  final List<GameNotice> notices = [];
  List<PendingEvent> pending;
  YearSummary? summary;
  EventOutcome? outcome;
  final List<GameSfx> _sfx = [];
  int _seq = 0;
  final DateTime _t0 = DateTime.now();

  LifeDraft(this.base, this.ctx)
      : c = base.character,
        npcs = List.of(base.npcs),
        props = List.of(base.properties),
        invs = List.of(base.investments),
        x = base.extras.clone(),
        pending = List.of(base.pendingEvents);

  int get age => c.currentAge;
  int get year => c.birthYear + c.currentAge;
  String get saveId => base.saveId;
  double get balance => c.bankBalance;
  bool canAfford(double v) => c.bankBalance >= v;

  // ------------------------------------------------------------------ registro
  void log(String category, String text, {String icon = 'star', String color = '#7C5CFF'}) {
    newLogs.add(LifeLog(
      id: ctx.id(),
      saveId: saveId,
      age: age,
      year: year,
      category: category,
      textContent: text,
      icon: icon,
      accentColor: color,
      createdAt: _t0.add(Duration(microseconds: _seq++)),
    ));
  }

  void notify(
    NoticeKind kind,
    IconData icon,
    String title, {
    String message = '',
    bool celebrate = false,
    double? money,
  }) {
    notices.add(GameNotice(kind: kind, icon: icon, title: title, message: message, celebrate: celebrate, moneyDelta: money));
  }

  void warn(String title, [String message = '']) {
    notify(NoticeKind.warning, Icons.info_outline, title, message: message);
    sfx(GameSfx.error);
  }

  void sfx(GameSfx s) => _sfx.add(s);

  // ------------------------------------------------------------------ atributos
  void money(double delta) => c = c.copyWith(bankBalance: c.bankBalance + delta);

  /// Debita valor; retorna falso (e avisa) se não houver saldo.
  bool pay(double amount, {String? what}) {
    if (amount <= 0) return true;
    if (c.bankBalance < amount) {
      warn('Saldo insuficiente', what == null ? 'Você precisa de mais dinheiro.' : 'Você precisa de ${_fmt(amount)} para $what.');
      return false;
    }
    money(-amount);
    return true;
  }

  static String _fmt(double v) => 'R\$ ${v.toStringAsFixed(0)}';

  static const statKeys = [
    'health', 'happiness', 'smarts', 'looks', 'energy', 'stress', 'discipline',
    'charisma', 'fitness', 'reputation', 'fame', 'karma',
  ];

  void stats(Map<String, num> fx) {
    int v(String k, int cur) => cur + ((fx[k] ?? 0).round());
    c = c.copyWith(
      health: v('health', c.health),
      happiness: v('happiness', c.happiness),
      smarts: v('smarts', c.smarts),
      looks: v('looks', c.looks),
      energy: v('energy', c.energy),
      stress: v('stress', c.stress),
      discipline: v('discipline', c.discipline),
      charisma: v('charisma', c.charisma),
      fitness: v('fitness', c.fitness),
      reputation: v('reputation', c.reputation),
      fame: v('fame', c.fame),
      karma: v('karma', c.karma),
    );
  }

  Map<String, int> snapshot() => {
        'health': c.health, 'happiness': c.happiness, 'smarts': c.smarts, 'looks': c.looks,
        'energy': c.energy, 'stress': c.stress, 'reputation': c.reputation, 'charisma': c.charisma,
        'fame': c.fame, 'fitness': c.fitness, 'karma': c.karma,
      };

  /// Gasta energia; retorna falso se não houver energia suficiente.
  bool useEnergy(int amount) {
    if (c.energy < amount) {
      warn('Sem energia', 'Descanse ou envelheça um ano para recuperar a energia.');
      return false;
    }
    c = c.copyWith(energy: c.energy - amount);
    return true;
  }

  /// Limite de usos por ano de uma ação.
  bool useAction(String key, int maxPerYear) {
    final used = x.actionsThisYear[key] ?? 0;
    if (used >= maxPerYear) {
      warn('Limite anual atingido', 'Você já fez isso $maxPerYear vez(es) este ano. Envelheça para fazer de novo.');
      return false;
    }
    x.actionsThisYear[key] = used + 1;
    return true;
  }

  // ------------------------------------------------------------------ NPCs
  NpcModel? npc(String id) {
    for (final n in npcs) {
      if (n.id == id) return n;
    }
    return null;
  }

  void updateNpc(NpcModel n) {
    final i = npcs.indexWhere((e) => e.id == n.id);
    if (i >= 0) npcs[i] = n;
  }

  void addMemory(String npcId, String memory) {
    final n = npc(npcId);
    if (n == null) return;
    final mem = [...n.memories, 'Aos $age anos: $memory'];
    updateNpc(n.copyWith(memories: mem.length > 20 ? mem.sublist(mem.length - 20) : mem));
  }

  List<NpcModel> living(bool Function(NpcModel n) test) => npcs.where((n) => n.isAlive && test(n)).toList();

  NpcModel? get partner {
    for (final n in npcs) {
      if (n.isAlive && (n.relationshipType == RelationshipType.partner || n.relationshipType == RelationshipType.spouse)) {
        return n;
      }
    }
    return null;
  }

  NpcModel makeNpc({
    required RelationshipType type,
    String? gender,
    int? age,
    String? lastName,
    int level = 60,
    String? occupation,
    double salary = 0,
    double netWorth = 1000,
  }) {
    final g = gender ?? ctx.gender();
    final a = age ?? (this.age + ctx.range(-2, 2)).clamp(0, 99);
    return NpcModel(
      id: ctx.id(),
      saveId: saveId,
      firstName: ctx.firstName(g),
      lastName: lastName ?? ctx.lastName(),
      gender: g,
      age: a,
      relationshipType: type,
      relationshipLevel: level,
      respectLevel: 50 + ctx.rng.nextInt(40),
      avatarConfig: AvatarConfig.random(gender: g, rng: ctx.rng),
      occupation: occupation ?? (a < 6 ? 'Criança' : a < 18 ? 'Estudante' : ctx.commonJob()),
      salary: salary,
      netWorth: netWorth,
      health: 75 + ctx.rng.nextInt(25),
      happiness: 60 + ctx.rng.nextInt(35),
    );
  }

  /// Gênero de interesse romântico conforme orientação.
  String romanticGender() {
    final own = c.gender;
    switch (c.sexualOrientation) {
      case 'homosexual':
        return own == 'female' ? 'female' : 'male';
      case 'bisexual':
        return ctx.gender();
      default:
        return own == 'female' ? 'male' : (own == 'male' ? 'female' : ctx.gender());
    }
  }

  // ------------------------------------------------------------------ build
  /// Constrói o estado final e toca os efeitos sonoros acumulados.
  LifeEngineState build() {
    for (final s in _sfx.toSet().take(2)) {
      ctx.audio.playSfx(s);
    }
    _sfx.clear();
    return toState();
  }

  /// Estado atual sem efeitos colaterais (para avaliar progresso).
  LifeEngineState toState() {
    return LifeEngineState(
      saveId: base.saveId,
      slotName: base.slotName,
      generation: base.generation,
      character: c,
      npcs: npcs,
      properties: props,
      investments: invs,
      logs: [...newLogs.reversed, ...base.logs],
      extras: x,
      pendingEvents: pending,
      notices: notices,
      lastYearSummary: summary,
      lastOutcome: outcome,
    );
  }
}
