import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bitweve/core/audio/audio_service.dart';
import 'package:bitweve/core/i18n/strings.dart';
import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/character/presentation/widgets/avatar_widget.dart';
import 'package:bitweve/features/events/presentation/widgets/event_dialog.dart';
import 'package:bitweve/features/hub/age_up_overlay.dart';
import 'package:bitweve/features/hub/modules.dart';
import 'package:bitweve/features/hub/year_summary_sheet.dart';
import 'package:bitweve/features/underworld/presentation/justice_sheets.dart';
import 'package:bitweve/features/life_engine/models/life_log.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/education_system.dart';
import 'package:bitweve/shared/ui/game_ui.dart';
import 'package:bitweve/shared/ui/log_icons.dart';
import 'package:bitweve/shared/ui/motion.dart';

class LifeScreen extends ConsumerStatefulWidget {
  const LifeScreen({super.key});

  @override
  ConsumerState<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends ConsumerState<LifeScreen> {
  bool _aging = false;
  bool _redirected = false;

  Future<void> _ageUp() async {
    if (_aging) return;
    setState(() => _aging = true);
    final notifier = ref.read(lifeEngineProvider.notifier);
    try {
      final st = await notifier.advanceYear();
      if (!mounted || st == null) return;
      final sum = st.lastYearSummary;
      if (sum != null) {
        await showAgeUpOverlay(
          context,
          age: sum.age,
          year: sum.year,
          headline: sum.headline,
          subtitle: sum.subtitle,
          avatar: st.character.avatarConfig.copyWith(
            expression: expressionFor(happiness: st.character.happiness, health: st.character.health, stress: st.character.stress),
          ),
        );
        if (!mounted) return;
        await showYearSummary(context, sum);
      }
      if (!mounted) return;
      if (!st.character.isAlive) {
        _redirected = true;
        context.go('/death');
        return;
      }
      await _resolveEvents();
    } finally {
      if (mounted) setState(() => _aging = false);
    }
  }

  Future<void> _resolveEvents() async {
    final notifier = ref.read(lifeEngineProvider.notifier);
    var guard = 0;
    while (mounted && guard++ < 5) {
      final st = ref.read(lifeEngineProvider).value;
      if (st == null || st.pendingEvents.isEmpty || !mounted) break;
      final idx = await showEventDialog(context, st.pendingEvents.first.event, balance: st.character.bankBalance);
      if (idx == null || !mounted) break;
      final after = await notifier.chooseEvent(idx);
      if (!mounted) break;
      final outcome = after?.lastOutcome;
      if (outcome != null && mounted) await showOutcomeDialog(context, outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lifeEngineProvider);
    return async.when(
      loading: () => const _Loading(),
      error: (e, _) => _ErrorView(error: e, onRetry: () => ref.invalidate(lifeEngineProvider)),
      data: (state) {
        if (state == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/main_menu');
          });
          return const _Loading();
        }
        if (!state.character.isAlive && !_aging && !_redirected) {
          _redirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/death');
          });
        }
        return LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 980;
          return Scaffold(
            body: GlowBackground(
              colors: lifeStageColors(state.character.currentAge),
              child: SafeArea(child: wide ? _wide(state) : _narrow(state)),
            ),
          );
        });
      },
    );
  }

  Widget _narrow(LifeEngineState s) {
    return Column(
      children: [
        _TopBar(state: s),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: _ProfileCard(state: s)),
        _AlertBanner(state: s),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: _StatsPanel(state: s)),
        const SizedBox(height: 6),
        Expanded(child: _Timeline(logs: s.logs)),
        _Dock(state: s, aging: _aging, onAgeUp: _ageUp),
      ],
    );
  }

  Widget _wide(LifeEngineState s) {
    return Column(
      children: [
        _TopBar(state: s),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 360,
                  child: ListView(children: [
                    _ProfileCard(state: s),
                    _AlertBanner(state: s, padding: EdgeInsets.zero),
                    const SizedBox(height: 12),
                    _StatsPanel(state: s, columns: 2),
                    const SizedBox(height: 14),
                    _AgeButton(age: s.character.currentAge, aging: _aging, onTap: _ageUp, big: true),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GameCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: Text(tr('hub.timeline'), style: AppTheme.display(18, color: context.gp.text)),
                        ),
                        Expanded(child: _Timeline(logs: s.logs)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 330,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('hub.modules'), style: AppTheme.display(18, color: context.gp.text)),
                      const SizedBox(height: 10),
                      Expanded(child: _ModuleGrid(state: s, columns: 3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================ topo
class _TopBar extends StatelessWidget {
  final LifeEngineState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu principal',
            onPressed: () => context.go('/main_menu'),
            icon: Icon(Icons.home_rounded, color: p.textDim),
          ),
          Expanded(
            child: Column(
              children: [
                Text(state.slotName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
                Text('Geração ${state.generation}', style: TextStyle(color: p.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Modo Deus',
            onPressed: () => Modules.open(context, 'godmode'),
            icon: const Icon(Icons.bolt_rounded, color: GamePalette.gold),
          ),
          IconButton(
            tooltip: tr('menu.settings'),
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_rounded, color: p.textDim),
          ),
        ],
      ),
    );
  }
}

// ============================================================================ perfil
class _ProfileCard extends StatelessWidget {
  final LifeEngineState state;
  const _ProfileCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final c = state.character;
    final x = state.extras;
    final expression = expressionFor(happiness: c.happiness, health: c.health, stress: c.stress);
    final occupation = c.currentJobTitle ??
        (x.retired
            ? tr('hub.retired')
            : (x.education.isStudying
                ? EducationSystem.stageLabel(x.education)
                : (c.currentAge < 6 ? tr('hub.child') : (c.currentAge < 18 ? tr('hub.student') : tr('hub.unemployed')))));
    final stageColors = lifeStageColors(c.currentAge);
    final avatar = Pressable(
      onTap: () => Modules.open(context, 'character'),
      semanticLabel: 'Abrir ficha do personagem',
      child: AvatarWidget(
        key: ValueKey('${c.currentAge}-${expression.name}'),
        config: c.avatarConfig.copyWith(expression: expression),
        age: c.currentAge,
        size: 84,
        ringColor: stageColors.first,
      ),
    );
    return GameCard(
      padding: const EdgeInsets.all(14),
      accent: stageColors[1],
      child: Row(
        children: [
          context.motion ? avatar.animate(key: ValueKey(c.currentAge)).scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.elasticOut) : avatar,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c.fullName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTheme.display(20, color: p.text)),
                    ),
                    _AgeBadge(age: c.currentAge, colors: stageColors),
                  ],
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.place_rounded, size: 13, color: p.textMuted),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text('${c.city}, ${c.country} · ${tr('hub.year')} ${c.year}', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 6),
                Pill(occupation, color: GamePalette.blue, icon: c.currentJobTitle != null ? Icons.work_rounded : Icons.school_rounded),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _MoneyChip(label: tr('hub.balance'), value: c.bankBalance, color: GamePalette.green, icon: Icons.account_balance_wallet_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _MoneyChip(label: tr('hub.netWorth'), value: state.netWorth, color: GamePalette.gold, icon: Icons.diamond_rounded)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeBadge extends StatelessWidget {
  final int age;
  final List<Color> colors;
  const _AgeBadge({required this.age, required this.colors});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors[0], colors[1]]),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [BoxShadow(color: colors[1].withAlpha(100), blurRadius: 10)],
      ),
      child: Text('$age ${tr('hub.years')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5)),
    );
    if (!context.motion) return badge;
    return badge.animate(key: ValueKey(age)).scale(begin: const Offset(1.4, 1.4), duration: 450.ms, curve: Curves.easeOutBack);
  }
}

class _MoneyChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _MoneyChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(p.isDark ? 30 : 24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: p.textMuted, fontSize: 9.5, fontWeight: FontWeight.w700)),
                AnimatedMoney(value, compact: true, style: TextStyle(color: value < 0 ? GamePalette.red : p.text, fontWeight: FontWeight.w900, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================ atributos
class _StatsPanel extends StatelessWidget {
  final LifeEngineState state;
  final int columns;
  const _StatsPanel({required this.state, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    final c = state.character;
    final stats = [
      (tr('stat.health'), c.health, Icons.favorite_rounded, false),
      (tr('stat.happiness'), c.happiness, Icons.sentiment_satisfied_rounded, false),
      (tr('stat.smarts'), c.smarts, Icons.psychology_rounded, false),
      (tr('stat.looks'), c.looks, Icons.face_retouching_natural_rounded, false),
      (tr('stat.energy'), c.energy, Icons.bolt_rounded, false),
      (tr('stat.stress'), c.stress, Icons.whatshot_rounded, true),
      (tr('stat.reputation'), c.reputation, Icons.verified_rounded, false),
      (tr('stat.charisma'), c.charisma, Icons.record_voice_over_rounded, false),
    ];
    final rows = <Widget>[];
    for (var i = 0; i < stats.length; i += columns) {
      rows.add(Row(
        children: [
          for (var j = i; j < i + columns && j < stats.length; j++) ...[
            if (j > i) const SizedBox(width: 12),
            Expanded(child: StatMeter(label: stats[j].$1, value: stats[j].$2, icon: stats[j].$3, inverted: stats[j].$4, compact: true)),
          ],
        ],
      ));
      if (i + columns < stats.length) rows.add(const SizedBox(height: 10));
    }
    return GameCard(padding: const EdgeInsets.fromLTRB(14, 12, 14, 12), child: Column(children: rows));
  }
}

// ============================================================================ linha do tempo
class _Timeline extends StatelessWidget {
  final List<LifeLog> logs;
  const _Timeline({required this.logs});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    if (logs.isEmpty) {
      return const EmptyState(icon: Icons.auto_stories_rounded, title: 'Sua história começa agora', message: 'Envelheça para viver o primeiro ano.');
    }
    // Agrupa por idade mantendo a ordem (mais recente primeiro)
    final items = <Object>[];
    int? lastAge;
    for (final l in logs) {
      if (l.age != lastAge) {
        items.add((l.age, l.year));
        lastAge = l.age;
      }
      items.add(l);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final it = items[i];
        if (it is (int, int)) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: lifeStageColors(it.$1).take(2).toList()),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(it.$1 == 0 ? 'Nascimento · ${it.$2}' : '${it.$1} ${tr('hub.years')} · ${it.$2}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Divider(color: p.border)),
            ]),
          );
        }
        final log = it as LifeLog;
        final tile = _LogTile(log: log);
        if (i < 6 && context.motion) {
          return tile.animate(key: ValueKey(log.id)).fadeIn(duration: 350.ms, delay: (i * 50).ms).slideX(begin: -0.04, end: 0);
        }
        return tile;
      },
    );
  }
}

class _LogTile extends StatelessWidget {
  final LifeLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    final color = hexColor(log.accentColor);
    final important = log.category == 'milestone' || log.category == 'death' || log.textContent.contains('!') && log.category == 'career';
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
        decoration: BoxDecoration(
          color: p.card.withAlpha(p.isDark ? 220 : 245),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 3.5)),
          boxShadow: important ? [BoxShadow(color: color.withAlpha(60), blurRadius: 14)] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(10)),
              child: Icon(LogIcons.of(log.icon, log.category), size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(log.textContent,
                  style: TextStyle(color: p.text, fontSize: 13.5, height: 1.32, fontWeight: important ? FontWeight.w700 : FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================ dock
class _Dock extends StatelessWidget {
  final LifeEngineState state;
  final bool aging;
  final VoidCallback onAgeUp;
  const _Dock({required this.state, required this.aging, required this.onAgeUp});

  @override
  Widget build(BuildContext context) {
    final p = context.gp;
    Widget slot(String id) {
      final m = Modules.byId(id);
      return Expanded(
        child: Pressable(
          onTap: () => Modules.open(context, id),
          semanticLabel: m.label,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon: m.icon, color: m.color, size: 40),
              const SizedBox(height: 4),
              Text(m.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: p.textDim)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: p.surface.withAlpha(p.isDark ? 235 : 245),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(p.isDark ? 110 : 30), blurRadius: 24, offset: const Offset(0, -6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          slot(state.extras.crime.inPrison ? 'prison' : 'activities'),
          slot(state.extras.crime.inPrison ? 'health' : (state.character.currentAge >= 14 && !state.extras.education.isStudying ? 'jobs' : 'school')),
          _AgeButton(age: state.character.currentAge, aging: aging, onTap: onAgeUp),
          slot('relationships'),
          Expanded(
            child: Pressable(
              onTap: () => showGameSheet(context, _AllModulesSheet()),
              semanticLabel: 'Todos os módulos',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const IconBadge(icon: Icons.apps_rounded, color: GamePalette.violet, size: 40),
                  const SizedBox(height: 4),
                  Text('Menu', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: p.textDim)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final int age;
  final bool aging;
  final VoidCallback onTap;
  final bool big;
  const _AgeButton({required this.age, required this.aging, required this.onTap, this.big = false});

  @override
  Widget build(BuildContext context) {
    final colors = lifeStageColors(age + 1);
    if (big) {
      return GameButton(
        label: aging ? '...' : '${tr('hub.ageUp')} · ${age + 1} ${tr('hub.years')}',
        icon: Icons.cake_rounded,
        colors: [colors[0], colors[1]],
        height: 62,
        sfx: GameSfx.buttonTap,
        onTap: aging ? null : onTap,
      );
    }
    final size = 76.0;
    Widget btn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [colors[0], colors[1]], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: Colors.white.withAlpha(200), width: 3),
        boxShadow: [BoxShadow(color: colors[1].withAlpha(150), blurRadius: 22, spreadRadius: 1)],
      ),
      child: aging
          ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cake_rounded, color: Colors.white, size: 26),
                Text('+1', style: AppTheme.display(16, color: Colors.white)),
              ],
            ),
    );
    if (context.motion && !aging) {
      btn = btn.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1100.ms, curve: Curves.easeInOut);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Pressable(onTap: aging ? null : onTap, semanticLabel: '${tr('hub.ageUp')} para ${age + 1} anos', scale: 0.9, child: btn),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Text(tr('hub.ageUp'), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: context.gp.text)),
          ),
        ],
      ),
    );
  }
}

class _ModuleGrid extends ConsumerWidget {
  final LifeEngineState state;
  final int columns;
  const _ModuleGrid({required this.state, required this.columns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mods = Modules.all;
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.92),
      itemCount: mods.length,
      itemBuilder: (context, i) {
        final tile = ModuleTile(module: mods[i], state: state, onTap: () => Modules.open(context, mods[i].id));
        if (!context.motion) return tile;
        return tile.animate().fadeIn(delay: (i * 25).ms, duration: 250.ms).scale(begin: const Offset(0.92, 0.92));
      },
    );
  }
}

class _AllModulesSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    return GameSheet(
      title: tr('hub.modules'),
      subtitle: 'Escolha o que fazer neste ano',
      icon: Icons.apps_rounded,
      color: GamePalette.violet,
      body: LayoutBuilder(builder: (context, c) {
        final cols = (c.maxWidth / 112).floor().clamp(3, 6);
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          child: _ModuleGrid(state: s, columns: cols),
        );
      }),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: GlowBackground(child: Center(child: CircularProgressIndicator(color: GamePalette.violet))),
      );
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GlowBackground(
          child: Center(
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              color: GamePalette.red,
              title: 'Algo deu errado',
              message: '$error',
              action: GameButton(label: 'Tentar novamente', expand: false, onTap: onRetry),
            ),
          ),
        ),
      );
}

// Exibe saldo formatado para leitores de tela em testes
String debugMoney(double v) => Fmt.money(v);

// ============================================================================ alertas
/// Faixa de alerta para prisão, julgamento pendente e liberdade condicional.
class _AlertBanner extends StatelessWidget {
  final LifeEngineState state;
  final EdgeInsets padding;
  const _AlertBanner({required this.state, this.padding = const EdgeInsets.fromLTRB(14, 8, 14, 0)});

  @override
  Widget build(BuildContext context) {
    final cs = state.extras.crime;
    final (IconData, Color, String, String, Widget)? a = cs.inPrison
        ? (Icons.lock_rounded, const Color(0xFF475569), 'Você está preso(a) em ${cs.prisonName}', 'Faltam ${cs.yearsLeft} ano(s) · toque para a rotina da prisão', const PrisonSheet())
        : cs.pendingCase != null
            ? (Icons.gavel_rounded, GamePalette.gold, 'Julgamento pendente', '${cs.pendingCase!.label} · toque para ir ao tribunal', const TrialSheet())
            : null;
    if (a == null) return const SizedBox.shrink();
    final card = Padding(
      padding: padding,
      child: GameCard(
        onTap: () => showGameSheet(context, a.$5),
        accent: a.$2,
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          IconBadge(icon: a.$1, color: a.$2, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.gp.text, fontWeight: FontWeight.w900)),
              Text(a.$4, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.gp.textMuted, fontSize: 11.5)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: context.gp.textMuted),
        ]),
      ),
    );
    if (!context.motion) return card;
    return card.animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1800.ms, color: a.$2.withAlpha(60));
  }
}
