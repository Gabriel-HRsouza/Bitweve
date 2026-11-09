import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/features/character/data/character_options.dart';
import 'package:bitweve/features/character/models/avatar_config.dart';
import 'package:bitweve/features/character/presentation/widgets/appearance_editor.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/life_draft.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/motion.dart';

class CreateCharacterScreen extends ConsumerStatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  ConsumerState<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends ConsumerState<CreateCharacterScreen> {
  static const _steps = [
    ('Identidade', Icons.badge_rounded),
    ('Família', Icons.family_restroom_rounded),
    ('Personalidade', Icons.psychology_rounded),
    ('Aparência', Icons.face_retouching_natural_rounded),
    ('Ficha', Icons.assignment_ind_rounded),
  ];

  final _rng = Random();
  final _first = TextEditingController();
  final _last = TextEditingController();
  int _step = 0;
  String _gender = 'female';
  String _orientation = 'heterosexual';
  int _day = 1;
  int _month = 1;
  int _year = DateTime.now().year;
  String _countryId = 'br';
  String? _city;
  String _family = 'middle';
  int _siblings = 1;
  bool _parentsTogether = true;
  String _personality = 'balanced';
  final Set<String> _traits = {};
  late AvatarConfig _avatar;
  int _previewAge = 25;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _randomizeAll(sound: false);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  EngineContext get _names => ref.read(lifeEngineServiceProvider).ctx;

  void _randomName() {
    _first.text = _names.firstName(_gender);
    _last.text = _names.lastName();
  }

  void _randomizeAll({bool sound = true}) {
    if (sound) AudioService().playSfx(GameSfx.positiveEvent);
    setState(() {
      _gender = _rng.nextBool() ? 'male' : 'female';
      _randomName();
      _day = 1 + _rng.nextInt(28);
      _month = 1 + _rng.nextInt(12);
      _avatar = AvatarConfig.random(gender: _gender, rng: _rng);
      _personality = CharacterOptions.personalities[_rng.nextInt(CharacterOptions.personalities.length)].id;
      _traits
        ..clear()
        ..add(CharacterOptions.traits[_rng.nextInt(CharacterOptions.traits.length)].id);
      _family = ['poor', 'middle', 'middle', 'rich'][_rng.nextInt(4)];
      _siblings = _rng.nextInt(3);
    });
  }

  List<Map<String, dynamic>> get _countries => ref.read(lifeEngineServiceProvider).availableCountries;

  List<String> get _cities {
    final c = _countries.where((e) => e['id'] == _countryId).firstOrNull;
    return ((c?['cities'] as List?) ?? const []).cast<String>();
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final setup = CharacterSetup(
      firstName: _first.text,
      lastName: _last.text,
      gender: _gender,
      sexualOrientation: _orientation,
      birthDay: _day,
      birthMonth: _month,
      birthYear: _year,
      countryId: _countryId,
      city: _city,
      familyWealth: _family,
      siblings: _siblings,
      parentsTogether: _parentsTogether,
      personality: _personality,
      traits: _traits.toList(),
      avatar: _avatar.copyWith(expression: AvatarExpression.happy),
    );
    await ref.read(lifeEngineProvider.notifier).createLife(setup);
    if (mounted) context.go('/game');
  }

  void _go(int step) {
    if (step < 0 || step >= _steps.length) return;
    AudioService().playSfx(GameSfx.screenTransition);
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 900;
            final content = AnimatedSwitcher(
              duration: context.dur(280),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a), child: child),
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _stepBody(wide)),
            );
            return Column(
              children: [
                _header(),
                _stepper(),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            SizedBox(width: 340, child: _previewPanel()),
                            Expanded(child: content),
                          ],
                        )
                      : Column(
                          children: [
                            if (_step != 4) _miniPreview(),
                            Expanded(child: content),
                          ],
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(color: p.surface.withAlpha(230), border: Border(top: BorderSide(color: p.border))),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(child: GameButton(label: 'Voltar', icon: Icons.arrow_back_rounded, outlined: true, onTap: () => _go(_step - 1))),
                      if (_step > 0) const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _step < 4
                            ? GameButton(label: 'Próximo: ${_steps[_step + 1].$1}', icon: Icons.arrow_forward_rounded, onTap: () => _go(_step + 1))
                            : GameButton(
                                label: _creating ? 'Criando vida...' : 'Começar vida',
                                icon: Icons.child_friendly_rounded,
                                colors: const [GamePalette.green, GamePalette.teal],
                                sfx: GameSfx.birth,
                                onTap: _creating ? null : _create,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _header() {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 8, 0),
      child: Row(
        children: [
          IconButton(onPressed: () => context.go('/main_menu'), icon: Icon(Icons.arrow_back_rounded, color: p.text), tooltip: 'Voltar'),
          Expanded(child: Text('Criar personagem', style: AppTheme.display(22, color: p.text))),
          TextButton.icon(onPressed: _randomizeAll, icon: const Icon(Icons.casino_rounded), label: const Text('Aleatório')),
        ],
      ),
    );
  }

  Widget _stepper() {
    final p = context.gp;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: _steps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == _step;
          final done = i < _step;
          final color = active ? GamePalette.violet : (done ? GamePalette.green : p.textMuted);
          return Pressable(
            onTap: () => _go(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? GamePalette.violet.withAlpha(40) : p.card,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: color.withAlpha(active ? 255 : 90), width: active ? 2 : 1),
              ),
              child: Row(children: [
                Icon(done ? Icons.check_circle_rounded : _steps[i].$2, size: 18, color: color),
                const SizedBox(width: 6),
                Text(_steps[i].$1, style: TextStyle(color: active ? p.text : p.textDim, fontWeight: FontWeight.w800, fontSize: 13)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _previewAvatar(double size) => AvatarWidget(config: _avatar, age: _previewAge, size: size, ringColor: GamePalette.violet);

  Widget _ageSelector() {
    final p = context.gp;
    const ages = [(1, 'Bebê'), (8, 'Criança'), (15, 'Jovem'), (25, 'Adulto'), (70, 'Idoso')];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final a in ages)
          ChoiceChip(
            label: Text(a.$2),
            selected: _previewAge == a.$1,
            onSelected: (_) => setState(() => _previewAge = a.$1),
            selectedColor: GamePalette.violet.withAlpha(60),
            labelStyle: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 12),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _previewPanel() {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GameCard(
        accent: GamePalette.violet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _previewAvatar(200),
            const SizedBox(height: 12),
            Text('${_first.text} ${_last.text}'.trim().isEmpty ? 'Seu personagem' : '${_first.text} ${_last.text}',
                textAlign: TextAlign.center, style: AppTheme.display(22, color: p.text)),
            const SizedBox(height: 4),
            Text('${AvatarConfig.outfitLabel(_avatar.outfit)} · ${AvatarConfig.bodyLabel(_avatar.bodyType)}', style: TextStyle(color: p.textMuted)),
            const SizedBox(height: 12),
            Text('Prévia por idade', style: TextStyle(color: p.textDim, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _ageSelector(),
          ],
        ),
      ),
    );
  }

  Widget _miniPreview() {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: GameCard(
        padding: const EdgeInsets.all(10),
        accent: GamePalette.violet,
        child: Row(
          children: [
            _previewAvatar(_step == 3 ? 104 : 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_first.text} ${_last.text}'.trim().isEmpty ? 'Seu personagem' : '${_first.text} ${_last.text}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(17, color: p.text)),
                  Text('${AvatarConfig.outfitLabel(_avatar.outfit)} · ${CharacterOptions.personality(_personality).name}',
                      style: TextStyle(color: p.textMuted, fontSize: 12)),
                  if (_step == 3) ...[const SizedBox(height: 6), Align(alignment: Alignment.centerLeft, child: _ageSelector())],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(bool wide) {
    switch (_step) {
      case 0:
        return _identity();
      case 1:
        return _familyStep();
      case 2:
        return _personalityStep();
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AppearanceEditor(config: _avatar, previewAge: _previewAge, onChanged: (c) => setState(() => _avatar = c)),
        );
      default:
        return _sheet(wide);
    }
  }

  // --------------------------------------------------------------- etapa 1
  Widget _identity() {
    final p = context.gp;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [
        const SectionTitle('Nome', icon: Icons.edit_rounded),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _first,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _last,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Sobrenome'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(tooltip: 'Sortear nome', onPressed: () => setState(_randomName), icon: const Icon(Icons.casino_rounded, color: GamePalette.violet)),
        ]),
        const SectionTitle('Gênero', icon: Icons.wc_rounded),
        Row(children: [
          for (final g in const [('female', 'Feminino', Icons.female_rounded, GamePalette.pink), ('male', 'Masculino', Icons.male_rounded, GamePalette.blue), ('non_binary', 'Não-binário', Icons.transgender_rounded, GamePalette.violet)])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _SelectCard(
                  selected: _gender == g.$1,
                  color: g.$4,
                  icon: g.$3,
                  title: g.$2,
                  onTap: () => setState(() {
                    _gender = g.$1;
                    _avatar = _avatar.copyWith(beardStyle: g.$1 == 'female' ? BeardStyle.none : _avatar.beardStyle);
                  }),
                ),
              ),
            ),
        ]),
        const SectionTitle('Orientação', icon: Icons.favorite_rounded),
        Wrap(spacing: 8, children: [
          for (final o in const [('heterosexual', 'Heterossexual'), ('homosexual', 'Homossexual'), ('bisexual', 'Bissexual')])
            ChoiceChip(label: Text(o.$2), selected: _orientation == o.$1, onSelected: (_) => setState(() => _orientation = o.$1),
                selectedColor: GamePalette.pink.withAlpha(60), labelStyle: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
        ]),
        const SectionTitle('Data de nascimento', icon: Icons.cake_rounded),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: const InputDecoration(labelText: 'Dia'),
              items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
              onChanged: (v) => setState(() => _day = v ?? 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(labelText: 'Mês'),
              items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(CharacterOptions.months[m - 1]))],
              onChanged: (v) => setState(() => _month = v ?? 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              initialValue: _year,
              decoration: const InputDecoration(labelText: 'Ano'),
              items: [for (var y = DateTime.now().year; y >= 1950; y--) DropdownMenuItem(value: y, child: Text('$y'))],
              onChanged: (v) => setState(() => _year = v ?? DateTime.now().year),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Pill('Signo: ${CharacterOptions.zodiac(_day, _month)}', color: GamePalette.gold, icon: Icons.auto_awesome_rounded),
        const SectionTitle('Nacionalidade', icon: Icons.public_rounded),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _countries)
              Pressable(
                onTap: () => setState(() {
                  _countryId = c['id'] as String;
                  _city = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _countryId == c['id'] ? GamePalette.cyan.withAlpha(40) : p.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _countryId == c['id'] ? GamePalette.cyan : p.border, width: _countryId == c['id'] ? 2 : 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: GamePalette.cyan.withAlpha(50), borderRadius: BorderRadius.circular(6)),
                      child: Text((c['id'] as String).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: GamePalette.cyan)),
                    ),
                    const SizedBox(width: 8),
                    Text(c['name'] as String, style: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
          ],
        ),
        const SectionTitle('Cidade natal', icon: Icons.location_city_rounded),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ChoiceChip(label: const Text('Aleatória'), selected: _city == null, onSelected: (_) => setState(() => _city = null)),
          for (final city in _cities)
            ChoiceChip(label: Text(city), selected: _city == city, onSelected: (_) => setState(() => _city = city),
                selectedColor: GamePalette.cyan.withAlpha(60), labelStyle: TextStyle(color: p.text, fontWeight: FontWeight.w600)),
        ]),
      ],
    );
  }

  // --------------------------------------------------------------- etapa 2
  Widget _familyStep() {
    final p = context.gp;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [
        const SectionTitle('Condição da família', subtitle: 'Define o patrimônio dos seus pais e as heranças futuras', icon: Icons.house_rounded),
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: [
              for (final f in CharacterOptions.families)
                _SelectCard(selected: _family == f.id, color: f.color, icon: f.icon, title: f.name, subtitle: f.description, onTap: () => setState(() => _family = f.id)),
            ],
          );
        }),
        const SectionTitle('Irmãos', icon: Icons.groups_rounded),
        GameCard(
          child: Row(children: [
            const IconBadge(icon: Icons.child_care_rounded, color: GamePalette.orange, size: 42),
            const SizedBox(width: 12),
            Expanded(child: Text(_siblings == 0 ? 'Filho(a) único(a)' : '$_siblings irmão(s) mais velho(s)', style: TextStyle(color: p.text, fontWeight: FontWeight.w700))),
            IconButton(onPressed: _siblings > 0 ? () => setState(() => _siblings--) : null, icon: const Icon(Icons.remove_circle_rounded)),
            Text('$_siblings', style: AppTheme.display(20, color: p.text)),
            IconButton(onPressed: _siblings < 4 ? () => setState(() => _siblings++) : null, icon: const Icon(Icons.add_circle_rounded, color: GamePalette.violet)),
          ]),
        ),
        const SizedBox(height: 10),
        GameCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _parentsTogether,
            onChanged: (v) => setState(() => _parentsTogether = v),
            title: Text('Pais vivem juntos', style: TextStyle(color: p.text, fontWeight: FontWeight.w700)),
            subtitle: Text('Afeta a história de nascimento e eventos familiares', style: TextStyle(color: p.textMuted, fontSize: 12)),
            secondary: const IconBadge(icon: Icons.favorite_rounded, color: GamePalette.pink, size: 42),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- etapa 3
  Widget _personalityStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [
        const SectionTitle('Personalidade', subtitle: 'Modifica seus atributos iniciais', icon: Icons.psychology_rounded),
        LayoutBuilder(builder: (context, box) {
          final cols = (box.maxWidth / 170).floor().clamp(2, 5);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              for (final o in CharacterOptions.personalities)
                _SelectCard(
                  selected: _personality == o.id,
                  color: o.color,
                  icon: o.icon,
                  title: o.name,
                  subtitle: o.description,
                  footer: _statChips(o.stats),
                  onTap: () => setState(() => _personality = o.id),
                ),
            ],
          );
        }),
        const SectionTitle('Características (até 2)', icon: Icons.auto_awesome_rounded),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in CharacterOptions.traits)
              FilterChip(
                avatar: Icon(t.icon, size: 18),
                label: Text(t.name),
                tooltip: t.description,
                selected: _traits.contains(t.id),
                onSelected: (v) => setState(() {
                  if (v && _traits.length < 2) {
                    _traits.add(t.id);
                  } else {
                    _traits.remove(t.id);
                  }
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget? _statChips(Map<String, int> stats) {
    if (stats.isEmpty) return null;
    const names = {'charisma': 'Carisma', 'happiness': 'Felic.', 'discipline': 'Discipl.', 'smarts': 'Intel.', 'stress': 'Estresse', 'health': 'Saúde', 'karma': 'Karma', 'reputation': 'Reput.', 'fitness': 'Físico', 'looks': 'Aparên.'};
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: stats.entries.take(3).map((e) {
        final good = e.key == 'stress' ? e.value < 0 : e.value > 0;
        return Text('${names[e.key] ?? e.key} ${e.value > 0 ? '+' : ''}${e.value}',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: good ? GamePalette.green : GamePalette.red));
      }).toList(),
    );
  }

  // --------------------------------------------------------------- etapa 5
  Widget _sheet(bool wide) {
    final p = context.gp;
    final fam = CharacterOptions.family(_family);
    final pers = CharacterOptions.personality(_personality);
    final country = _countries.where((c) => c['id'] == _countryId).firstOrNull;
    final mods = <String, int>{...pers.stats};
    for (final t in _traits) {
      CharacterOptions.trait(t)?.stats.forEach((k, v) => mods[k] = (mods[k] ?? 0) + v);
    }
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Icon(icon, size: 18, color: GamePalette.violet),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: p.textMuted)),
            const Spacer(),
            Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: p.text, fontWeight: FontWeight.w700))),
          ]),
        );
    final card = GameCard(
      accent: GamePalette.violet,
      glow: true,
      child: Column(
        children: [
          if (!wide) _previewAvatar(150),
          if (!wide) const SizedBox(height: 10),
          Text('${_first.text} ${_last.text}'.trim().isEmpty ? 'Nome sorteado ao nascer' : '${_first.text} ${_last.text}',
              textAlign: TextAlign.center, style: AppTheme.display(24, color: p.text)),
          const SizedBox(height: 4),
          Text('Ficha do personagem', style: TextStyle(color: p.textMuted)),
          const Divider(height: 24),
          row(Icons.cake_rounded, 'Nascimento', '$_day de ${CharacterOptions.months[_month - 1]} de $_year'),
          row(Icons.auto_awesome_rounded, 'Signo', CharacterOptions.zodiac(_day, _month)),
          row(Icons.public_rounded, 'Nacionalidade', '${country?['name'] ?? 'Brasil'}${_city != null ? ' · $_city' : ''}'),
          row(Icons.house_rounded, 'Família', '${fam.name} · ${_siblings == 0 ? 'filho(a) único(a)' : '$_siblings irmão(s)'}'),
          row(Icons.psychology_rounded, 'Personalidade', pers.name),
          row(Icons.star_rounded, 'Características', _traits.isEmpty ? '—' : _traits.map((t) => CharacterOptions.trait(t)!.name).join(', ')),
          row(Icons.checkroom_rounded, 'Estilo', '${AvatarConfig.outfitLabel(_avatar.outfit)} · ${AvatarConfig.bodyLabel(_avatar.bodyType)}'),
          if (mods.isNotEmpty) ...[
            const Divider(height: 24),
            Align(alignment: Alignment.centerLeft, child: Text('Bônus de atributos', style: TextStyle(color: p.textDim, fontWeight: FontWeight.w800))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mods.entries.map((e) {
                final good = e.key == 'stress' ? e.value < 0 : e.value > 0;
                return Pill('${e.key == 'smarts' ? 'Inteligência' : e.key == 'charisma' ? 'Carisma' : e.key == 'looks' ? 'Aparência' : e.key == 'health' ? 'Saúde' : e.key == 'fitness' ? 'Físico' : e.key == 'discipline' ? 'Disciplina' : e.key == 'karma' ? 'Karma' : e.key == 'stress' ? 'Estresse' : e.key == 'reputation' ? 'Reputação' : 'Felicidade'} ${e.value > 0 ? '+' : ''}${e.value}',
                    color: good ? GamePalette.green : GamePalette.red);
              }).toList(),
            ),
          ],
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [context.motion ? card.animate().fadeIn().scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack) : card],
    );
  }
}

class _SelectCard extends StatelessWidget {
  final bool selected;
  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? footer;
  final VoidCallback onTap;

  const _SelectCard({required this.selected, required this.color, required this.icon, required this.title, this.subtitle, this.footer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(p.isDark ? 45 : 30) : p.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : p.border, width: selected ? 2.2 : 1),
          boxShadow: selected ? [BoxShadow(color: color.withAlpha(80), blurRadius: 16)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconBadge(icon: icon, color: color, size: 44),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, color: p.text, fontSize: 14)),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textMuted, fontSize: 11.5)),
            ],
            if (footer != null) ...[const SizedBox(height: 6), footer!],
          ],
        ),
      ),
    );
  }
}
