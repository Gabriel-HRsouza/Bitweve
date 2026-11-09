import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitweve/core/theme/app_theme.dart';
import 'package:bitweve/core/theme/game_palette.dart';
import 'package:bitweve/core/utils/format.dart';
import 'package:bitweve/features/life_engine/presentation/providers/life_engine_provider.dart';
import 'package:bitweve/features/life_engine/systems/underworld_system.dart';
import 'package:bitweve/features/relationships/models/npc_model.dart';
import 'package:bitweve/features/relationships/presentation/person_profile_sheet.dart';
import 'package:bitweve/features/school/presentation/school_sheet.dart' show ActionTile, actionGrid;
import 'package:bitweve/shared/ui/game_ui.dart';

/// Julgamento: fiança, escolha de advogado e declaração.
class TrialSheet extends ConsumerStatefulWidget {
  const TrialSheet({super.key});

  @override
  ConsumerState<TrialSheet> createState() => _TrialSheetState();
}

class _TrialSheetState extends ConsumerState<TrialSheet> {
  String _lawyer = 'public';
  String _plea = 'innocent';
  String? _verdict;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final pc = s.extras.crime.pendingCase;
    if (_verdict != null) {
      final free = !s.extras.crime.inPrison;
      return GameSheet(
        title: 'Sentença',
        icon: Icons.gavel_rounded,
        color: free ? GamePalette.green : GamePalette.red,
        body: ListView(padding: const EdgeInsets.all(20), children: [
          IconBadge(icon: free ? Icons.balance_rounded : Icons.lock_rounded, color: free ? GamePalette.green : GamePalette.red, size: 90)
              .animate()
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 900.ms),
          const SizedBox(height: 16),
          Text(_verdict!, textAlign: TextAlign.center, style: AppTheme.display(20, color: p.text)),
          const SizedBox(height: 20),
          GameButton(
            label: free ? 'Seguir a vida' : 'Ir para a prisão',
            icon: free ? Icons.directions_walk_rounded : Icons.lock_rounded,
            colors: free ? const [GamePalette.green, Color(0xFF15803D)] : const [GamePalette.red, Color(0xFF7F1D1D)],
            onTap: () {
              Navigator.of(context).maybePop();
              if (!free) showGameSheet(context, const PrisonSheet());
            },
          ),
        ]),
      );
    }
    if (pc == null) {
      return const GameSheet(
        title: 'Tribunal',
        icon: Icons.gavel_rounded,
        color: GamePalette.gold,
        body: EmptyState(icon: Icons.balance_rounded, title: 'Nenhum processo', message: 'Você não tem julgamentos pendentes.'),
      );
    }
    final priors = s.extras.crime.record.length;
    Widget lawyerOpt(String id, String title, String desc, IconData icon, Color color) {
      final cost = UnderworldSystem.lawyerCost(id, pc.severity);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GameCard(
          onTap: () => setState(() => _lawyer = id),
          accent: _lawyer == id ? color : null,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            IconBadge(icon: icon, color: color, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: p.text, fontWeight: FontWeight.w900)),
                Text('$desc · ${cost == 0 ? 'gratuito' : Fmt.money(cost)}', style: TextStyle(color: p.textMuted, fontSize: 12)),
              ]),
            ),
            if (_lawyer == id) Icon(Icons.check_circle_rounded, color: color),
          ]),
        ),
      );
    }

    return GameSheet(
      title: 'Tribunal',
      subtitle: 'Processo: ${pc.label}',
      icon: Icons.gavel_rounded,
      color: GamePalette.gold,
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
        GameCard(
          accent: GamePalette.gold,
          child: Column(children: [
            StatMeter(label: 'Força das provas', value: (pc.evidence * 100).round(), icon: Icons.fingerprint_rounded, inverted: true),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('Gravidade: ${'●' * pc.severity}${'○' * (5 - pc.severity)}', style: TextStyle(color: p.textDim))),
              Text('Antecedentes: $priors', style: TextStyle(color: priors > 0 ? GamePalette.red : p.textDim, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        if (!pc.bailPaid)
          GameButton(
            label: 'Pagar fiança · ${Fmt.money(pc.bail)}',
            caption: 'Responda em liberdade (melhora levemente a defesa)',
            icon: Icons.lock_open_rounded,
            outlined: true,
            onTap: () => ref.read(lifeEngineProvider.notifier).act((v, st) => v.payBail(st)),
          )
        else
          const Pill('Fiança paga — respondendo em liberdade', color: GamePalette.green, icon: Icons.check_rounded),
        const SectionTitle('Defesa', icon: Icons.work_rounded),
        lawyerOpt('public', 'Defensor público', 'Sobrecarregado, mas gratuito', Icons.person_rounded, const Color(0xFF64748B)),
        lawyerOpt('private', 'Advogado particular', 'Boa chance de reduzir a pena', Icons.business_center_rounded, GamePalette.blue),
        lawyerOpt('elite', 'Banca de elite', 'Os melhores do país', Icons.diamond_rounded, GamePalette.gold),
        const SectionTitle('Declaração', icon: Icons.record_voice_over_rounded),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'innocent', label: Text('Inocente'), icon: Icon(Icons.shield_rounded)),
            ButtonSegment(value: 'guilty', label: Text('Culpado(a)'), icon: Icon(Icons.front_hand_rounded)),
          ],
          selected: {_plea},
          onSelectionChanged: (v) => setState(() => _plea = v.first),
        ),
        const SizedBox(height: 6),
        Text(_plea == 'guilty'
            ? 'Confessar reduz a pena, mas garante a condenação.'
            : 'Ir a júri pode te absolver — ou render uma pena maior se as provas forem fortes.',
            style: TextStyle(color: p.textMuted, fontSize: 12)),
        const SizedBox(height: 16),
        GameButton(
          label: 'Iniciar julgamento',
          icon: Icons.gavel_rounded,
          colors: const [GamePalette.gold, Color(0xFFB45309)],
          onTap: () async {
            final v = await ref.read(lifeEngineProvider.notifier).actResult((svc, st) => svc.trial(st, _lawyer, _plea));
            if (v != null && v.isNotEmpty && mounted) setState(() => _verdict = v);
          },
        ),
      ]),
    );
  }
}

/// Interface da prisão.
class PrisonSheet extends ConsumerWidget {
  const PrisonSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lifeEngineProvider).value;
    if (s == null) return const SizedBox.shrink();
    final p = context.gp;
    final cs = s.extras.crime;
    if (!cs.inPrison) {
      return const GameSheet(
        title: 'Prisão',
        icon: Icons.lock_open_rounded,
        color: GamePalette.green,
        body: EmptyState(icon: Icons.lock_open_rounded, title: 'Você está livre', message: 'Mantenha-se longe de problemas!', color: GamePalette.green),
      );
    }
    final a = s.extras.actionsThisYear;
    int u(String k) => a['prison:$k'] ?? 0;
    final n = ref.read(lifeEngineProvider.notifier);
    final inmates = s.npcs.where((e) => e.isAlive && e.relationshipType == RelationshipType.inmate).toList();
    final canParole = cs.served * 2 >= cs.sentence;
    var i = 0;
    return GameSheet(
      title: cs.prisonName,
      subtitle: 'Pena: ${cs.sentence} ano(s) · cumpridos ${cs.served} · faltam ${cs.yearsLeft}',
      icon: Icons.lock_rounded,
      color: const Color(0xFF475569),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF334155), Color(0xFF0F172A)]),
          ),
          child: Stack(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (var k = 0; k < 9; k++) Container(width: 6, color: const Color(0xFF94A3B8)),
            ]),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withAlpha(170), borderRadius: BorderRadius.circular(12)),
                child: Text('${cs.yearsLeft} ano(s) restantes', style: AppTheme.display(20, color: Colors.white)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        GameCard(
          child: Column(children: [
            StatMeter(label: 'Comportamento', value: cs.behavior, icon: Icons.verified_rounded),
            const SizedBox(height: 8),
            StatMeter(label: 'Pena cumprida', value: cs.sentence == 0 ? 100 : (cs.served * 100 ~/ cs.sentence), icon: Icons.hourglass_bottom_rounded),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('Pecúlio (trabalho): ${Fmt.money(cs.prisonSavings)}', style: TextStyle(color: p.textDim, fontSize: 12))),
              Text('Condicional: ${canParole ? 'disponível' : 'após metade da pena'}', style: TextStyle(color: canParole ? GamePalette.green : p.textMuted, fontSize: 12)),
            ]),
          ]),
        ),
        const SectionTitle('Rotina', icon: Icons.schedule_rounded),
        actionGrid([
          ActionTile(index: i++, icon: Icons.fitness_center_rounded, color: GamePalette.teal, title: 'Treinar no pátio', description: '+Forma física e saúde', indicator: '${u('workout')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'workout'))),
          ActionTile(index: i++, icon: Icons.menu_book_rounded, color: GamePalette.blue, title: 'Estudar', description: 'Supletivo e biblioteca', indicator: '${u('study')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'study'))),
          ActionTile(index: i++, icon: Icons.handyman_rounded, color: GamePalette.gold, title: 'Trabalhar', description: 'Oficina: pecúlio e remição', indicator: '${u('work')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'work'))),
          ActionTile(index: i++, icon: Icons.self_improvement_rounded, color: GamePalette.green, title: 'Reabilitação', description: 'Terapia e bom comportamento', indicator: '${u('program')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'program'))),
          ActionTile(index: i++, icon: Icons.groups_rounded, color: const Color(0xFF64748B), title: 'Socializar', description: 'Conhecer outros detentos', indicator: '${u('socialize')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'socialize'))),
          ActionTile(index: i++, icon: Icons.sports_mma_rounded, color: GamePalette.red, title: 'Brigar', description: 'Péssimo para o comportamento', indicator: '${u('fight')}/2',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'fight'))),
        ]),
        const SectionTitle('Ações legais', icon: Icons.gavel_rounded),
        actionGrid([
          ActionTile(index: i++, icon: Icons.business_center_rounded, color: GamePalette.blue, title: 'Advogado: recurso', description: 'R\$ 12.000 · pode reduzir a pena', indicator: '${u('lawyer')}/1',
              onTap: () => n.act((v, st) => v.prisonAction(st, 'lawyer'))),
          ActionTile(index: i++, icon: Icons.balance_rounded, color: GamePalette.green, title: 'Audiência de condicional', description: 'Exige metade da pena e bom comportamento',
              indicator: '${u('parole')}/1', enabled: canParole, onTap: () => n.act((v, st) => v.prisonAction(st, 'parole'))),
        ]),
        const SectionTitle('Colegas de cela', icon: Icons.people_alt_rounded),
        if (inmates.isEmpty) Text('Ninguém por perto.', style: TextStyle(color: p.textMuted)),
        for (var k = 0; k < inmates.length; k++)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: PersonTile(npc: inmates[k], index: k)),
        const SizedBox(height: 8),
        Text('Envelheça para cumprir a pena. Familiares e parceiro(a) ainda podem ser contatados em Relacionamentos.',
            style: TextStyle(color: p.textMuted, fontSize: 12)),
      ]),
    );
  }
}
